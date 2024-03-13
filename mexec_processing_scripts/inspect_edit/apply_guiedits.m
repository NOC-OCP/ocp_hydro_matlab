function [d, comment] = apply_guiedits(d, xvar, edfilepat, varargin)
% [d, comment] = apply_guiedits(d, indepvar, edfilepat, redoctm)
%
% find any edits previously selected (e.g. in mctd_rawedit) and recorded in
% files with names like edfilepat (including full path), and apply to
% fields of d using variable indepvar (e.g. scan, for mctd_rawedit output)
%
% useful if you've clobbered the _raw_cleaned.nc files after running
% mctd_rawedit (for instance, if you've gone back to _noctm versions)
%
% optional 4th argument can be set [1 stnlocal] to account for the fact that if oxygen
% alignment is done in mctd_02, mctd_rawedit will have inspected aligned
% data but this step is applied before alignment, so bad scans for oxygen
% variables need to be offset
%
% optional 5th argument gives a tolerance for finding matching points
% (useful if the indepvar was not integers)

redoctm = 0;
tol = 0;
if nargin>3
    redoctm = varargin{1};
    stnlocal = redoctm(2); redoctm = redoctm(1);
    if nargin>4
        tol = varargin{2};
    end
end
if redoctm
    opt1 = 'castpars'; opt2 = 'oxy_align'; get_cropt
end

edfiles = dir(edfilepat);
if isempty(edfiles)
    comment = '';
    return
end
eddir = fileparts(edfilepat);

%get list of variables and scans to NaN
clear donan
for fno = 1:length(edfiles)
    clear varn
    efname = edfiles(fno).name;
    fid = fopen(fullfile(eddir,efname),'r');
    a = textscan(fid,'%s'); a = a{1};
    fclose(fid);
    ii = find(strcmp(a,'ot_version')) + 3;
    if isempty(ii)
        ii = find(strncmp(a,'indepvar',14))+2;
        if isempty(ii); ii = 1; end
    end
    if length(a)>ii
        for lno = ii:length(a)
            s = str2double(a{lno});
            if isempty(s) || isnan(s)
                varn = a{lno}; %variable name
                if ~exist('donan','var') || ~isfield(donan,varn)
                    donan.(varn) = []; %initialise, if we didn't have it in an earlier file
                end
            else
                if redoctm && contains(varn,'oxygen')
                    s = s+oxy_align*24; 
                end
                donan.(varn) = [donan.(varn) s]; %scan
            end
        end
    else
        warning('unexpected format in file %s',efname)
    end
end

if ~exist('donan','var')
    error('mplxyed files found but no recognised edits')
end

%apply edits
vars = fieldnames(donan);
comment = '';
for vno = 1:length(vars)
    md = min(abs(d.(xvar)(:)'-donan.(vars{vno})(:)));
    m = md<=tol;
    if sum(m)
        d.(vars{vno})(m) = NaN;
        comment = '\n saved GUI edits reapplied';
    end
end
