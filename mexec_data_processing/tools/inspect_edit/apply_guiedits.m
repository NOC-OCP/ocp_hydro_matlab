function [d, comment] = apply_guiedits(d, xvar, edfilepat, varargin)
% [d, comment] = apply_guiedits(d, indepvar, edfilepat, tol, flag)
%
% find any edits previously selected (e.g. in mctd_rawedit) and recorded in
% files with names like edfilepat (including full path), and apply to
% fields of d using variable indepvar (e.g. scan, for mctd_rawedit output)
%
% useful if you've clobbered the _raw_cleaned.nc files after running
% mctd_rawedit (for instance, if you've gone back to _noctm versions)
%
% optional 4th argument gives a tolerance for finding matching points
%   (useful if the indepvar was not integers)
% optional 5th argument can be a vector giving [good_flag; bad_flag] to
%   apply values to {var}_flag instead of NaNing {var}  
% 

m_common

tol = 0;
flag = 0;
if nargin>3
    tol = varargin{1};
    if nargin>4
        flag = varargin{1};
    end
end

edfiles = dir([edfilepat]);
if isempty(edfiles)
    comment = '';
    return
end
eddir = fileparts(edfilepat);

%get list of variables and scans to NaN
clear flagit
for fno = 1:length(edfiles)
    clear varn
    efname = edfiles(fno).name;
    fid = fopen(fullfile(eddir,efname),'r');
    a = textscan(fid,'%s'); a = a{1};
    fclose(fid);
    if MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN(1)<2026
        ii = find(strcmp(a,'ot_version')) + 3;
        if isempty(ii)
            ii = find(strncmp(a,'indepvar',14))+2;
            if isempty(ii); ii = 1; end
        end
    else
        ii = find(strcmp(a,'xvar'))+2;
    end
    if length(a)>ii
        for lno = ii:length(a)
            s = str2double(a{lno});
            if isempty(s) || isnan(s)
                varn = a{lno}; %variable name
                if ~exist('flagit','var') || ~isfield(flagit,varn)
                    flagit.(varn) = []; %initialise, if we didn't have it in an earlier file
                end
            else
                flagit.(varn) = [flagit.(varn) s]; %scan
            end
        end
    else
        warning('unexpected format in file %s',efname)
    end
end

if ~exist('flagit','var')
    error('mplxyed files matching %s found, but no recognised edits',edfilepat)
end

%apply edits
vars = intersect(fieldnames(flagit),fieldnames(d));
comment = '';
for vno = 1:length(vars)
    bp = flagit.(vars{vno});
    x = d.(xvar)(:)';
    if isscalar(bp)
        md = abs(x-bp);
    elseif length(bp)>1
        md = min(abs(x-bp(:)));
    end
    m = md<=tol;
    if sum(m)
        if ~isscalar(flag)
            fn = [vars{vno} '_flag'];
            if ~isfield(d, fn)
                d.(fn) = flag(1)+zeros(size(d.(vars{vno})));
            end
            d.(fn)(m) = flag(2);
        else
            d.(vars{vno})(m) = NaN;
        end
        comment = '\n saved GUI edits reapplied';
    end
end
