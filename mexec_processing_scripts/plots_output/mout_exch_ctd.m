% mout_exch_ctd: write data from ctd_cruise_nnn_2db.nc to CCHDO exchange file
% Use: mout_exch_ctd        
%
% edit jc159 so that this can write a file for exch and also a file 
% containing other uncalibrated ctd variables for internal use, if 
% writeallctd exists and is set to 1. in this case it will get the template
% from all_ctd_renamelist and write to outfileall rather than outfile (both
% are set in opt_cruise)***

opt1 = 'castpars'; opt2 = 'minit'; get_cropt

opt1 = 'mout_exch'; opt2 = 'woce_expo'; get_cropt
if ~exist('expocode','var')
    warning('no expocode set in opt_%s.m; skipping', mcruise)
    return
end

clear in out
in.type = 'ctd'; in.stnlist = stnlocal;
out.type = 'exch';

%which vars to write
[vars, varsh] = m_exch_vars_list(1);
opt1 = 'mout_exch'; opt2 = 'woce_vars_exclude'; get_cropt
[~,ia] = setdiff(vars(:,1),vars_exclude_ctd);
out.vars_units = vars(ia,:);

%header
opt1 = 'mout_exch'; opt2 = 'woce_ctd_headstr'; get_cropt
out.header = [headstring; sprintf('%s %d', 'NUMBER_HEADERS = ', size(varsh,1)+1)];
dh.expocode = expocode;
dh.sect_id = sect_id;
dh.stnnbr = stnlocal;
dh.castno = 1;
sumfn = [mgetdir('M_SUM') '/station_summary_' mcruise '_all.nc'];
iis = [];
if exist(sumfn,'file')
    [dsum, hsum] = mloadq(sumfn,'/');
    iis = find(dsum.statnum==stnlocal);
end
if length(iis)==1
    dh.latitude = dsum.lat(iis);
    dh.longitude = dsum.lon(iis);
    dh.depth = dsum.cordep(iis);
    dn = datenum(hsum.data_time_origin) + dsum.time_bottom(iis)/86400;
    dh.date = datestr(dn,'yyyymmdd');
    dh.time = datestr(dn,'HHMM');
else
    dh.latitude = -999; dh.longitude = -999; dh.depth = -999;
    dh.date = ''; dh.time = '';
end
for hno = 1:size(varsh,1)
    out.header = [out.header; sprintf(['%s = ' varsh{hno,4}], varsh{hno,1}, dh.(varsh{hno,3}))];
end

%output file prefix
basedir = fullfile(mgetdir('sum'),[expocode '_ct1']);
if ~exist(basedir,'dir')
    mkdir(basedir)
end
out.csvpre = fullfile(basedir, sprintf('%s_%05d_0001_ct1',expocode,stnlocal));

status = mout_csv(in, out);
