%this is a script to apply edits (i.e. NaN-ing data) selected in
%mctd_rawedit GUI and recorded in mplxyed_* text files. you only need to
%use it if you've clobbered the _raw_cleaned.nc files since. it will apply
%all edits to a given station file (i.e. from multiple mplxyed_* files
%generated at multiple times/passes of the mctd_rawedit GUI)

scriptname = 'castpars'; oopt = 'minit'; get_cropt

root_ctd = mgetdir('CTD');
edfiles = dir(fullfile(root_ctd,['mplxyed_*_ctd_' mcruise '_' stn_string]));
if isempty(edfiles)
    if MEXEC_G.quiet<=1; fprintf(1, 'no recorded edits to apply to ctd_%s_%s_raw_cleaned.nc\n', mcruise, stn_string); end
    return
else
   if MEXEC_G.quiet<=1; fprintf(1, 'applying recorded edits to ctd_%s_%s_raw_cleaned.nc\n', mcruise, stn_string); end
end

otfile = fullfile(root_ctd,['ctd_' mcruise '_' stn_string '_raw_cleaned.nc']);
if ~exist(otfile,'file')
    infile = fullfile(root_ctd,['ctd_' mcruise '_' stn_string '_raw.nc']);
    if ~exist(infile,'file')
        error('must run mctd_01 first to generate ctd_%s_%s_raw.nc',mcruise,stn_string)
    end
    copyfile(infile,otfile);
    system(['chmod 644 ' otfile]);
end

%get list of variables and scans to NaN
clear donan
for fno = 1:length(edfiles)
    efname = edfiles(fno).name;
    fid = fopen(fullfile(root_ctd,efname),'r');
    a = textscan(fid,'%s'); a = a{1};
    fclose(fid);
    ii = find(strcmp(a,'ot_version')) + 3;
    if length(a)>ii
        for lno = ii:length(a)
            s = str2double(a{lno});
            if isempty(s)
                var = a{lno}; %variable name
                if ~exist('donan','var') || ~isfield(donan,var)
                    donan.(var) = []; %initialise
                end
            else
                donan.(var) = [donan.(var) s]; %scan
            end
        end
    else
        warning('unexpected format in file %s',efname)
    end
end

if ~isstruct(donan)
    error('mplxyed files found but no recognised edits')
end

%load relevant variables
vars = fieldnames(donan);
varlist = sprintf('%s ',vars{:});
if MEXEC_G.quiet<=1; fprintf(1,'edits to: %s\n', varlist); end
[d,h] = mloadq(otfile, ['scan ' varlist ' /']);

%apply edits
for vno = 1:length(vars)
    d.(vars{vno})(ismember(d.scan,donan.(vars{vno}))) = NaN;
end
d = rmfield(d,'scan');

%save
clear hnew
[hnew.fldnam,ia,~] = intersect(fieldnames(d),h.fldnam,'stable');
hnew.fldunt = h.fldunt(ia);
hnew.comment = 'saved GUI edits reapplied';
mfsave(otfile, d, hnew, '-addvars');

%propagate through
stn = stnlocal; ctd_all_postedit

