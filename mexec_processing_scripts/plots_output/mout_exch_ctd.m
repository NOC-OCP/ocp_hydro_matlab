% mout_exch_ctd: write data from ctd_cruise_nnn_2db.nc to CCHDO exchange file
% Use: mout_exch_ctd        
%
% edit jc159 so that this can write a file for exch and also a file 
% containing other uncalibrated ctd variables for internal use, if 
% writeallctd exists and is set to 1. in this case it will get the template
% from all_ctd_renamelist and write to outfileall rather than outfile (both
% are set in opt_cruise)***

scriptname = 'castpars'; oopt = 'minit'; get_cropt

%%%%% load input data %%%%%

root_ctd = mgetdir('M_CTD');
infile1 = [root_ctd '/ctd_' mcruise '_' stn_string '_2db.nc'];
if exist(m_add_nc(infile1),'file') ~= 2; return; end
[d, h] = mloadq(infile1, '/');
nsamp = length(d.press);


%%%%% add some fields that don't exist (or edit), get header fields %%%%%

clear dh
scriptname = 'mout_exch'; oopt = 'woce_expo'; get_cropt
if ~exist('expocode','var')
    warning('no expocode set in opt_%s.m; skipping', mcruise)
    return
end
dh.expocode = expocode;
dh.sect_id = sect_id;
dh.statnum = stnlocal;
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
end
if ~isfield(d, 'castno')
    d.castno = ones(nsamp,1);
end

%flags default to 2 for data present but may be changed in opt_cruise
ctdflag = 9+zeros(nsamp,1); ctdflag(~isnan(d.temp+d.psal)) = 2;
ctoflag = 9+zeros(nsamp,1); ctoflag(~isnan(d.oxygen)) = 2;
if isfield(d,'fluor')
    ctfflag = 9+zeros(nsamp,1); ctfflag(~isnan(d.fluor)) = 2;
end
scriptname = 'mout_exch'; oopt = 'woce_ctd_flags'; get_cropt
d.temp_flag = ctdflag; d.psal_flag = ctdflag; 
d.oxygen_flag = ctoflag; 
if isfield(d,'fluor')
    d.fluor_flag = ctfflag;
end

%%%%% figure out which fields to write %%%%%

[vars, varsh] = m_exch_vars_list(1);
scriptname = 'mout_exch'; oopt = 'woce_vars_exclude'; get_cropt
iie = [];
for no = 1:length(vars_exclude_ctd)
    iie = [iie; find(strcmp(vars_exclude_ctd{no},vars(:,3)))];
end
for vno = 1:size(vars,1)
    if isfield(d, vars{vno,3})
        if endsWith(vars{vno,3},'_flag')
            d.(vars{vno,3})(isnan(d.(vars{vno,3}))) = 9;
            if size(d.(vars{vno,3}),1)==1
                d.(vars{vno,3}) = d.(vars{vno,3})';
            end
        else
            d.(vars{vno,3})(isnan(d.(vars{vno,3}))) = -999;
            if size(d.(vars{vno,3}),1)==1
                d.(vars{vno,3}) = d.(vars{vno,3})';
            end
        end
    else
        iie = [iie; vno];
    end
end
vars(iie,:) = [];


%%%%% write %%%%%

scriptname = 'mout_exch'; oopt = 'woce_ctd_headstr'; get_cropt
basedir = fullfile(mgetdir('sum'),[expocode '_ct1']);
if ~exist(basedir,'dir')
    mkdir(basedir)
end
fotname = fullfile(basedir, sprintf('%s_%05d_0001_ct1.csv',expocode,stnlocal));
fid = fopen(fotname, 'w');

%header
if ~isempty(headstring)
    fprintf(fid, '%s\n', headstring{:});
end

% more header
fprintf(fid, '%s %d\n', 'NUMBER_HEADERS = ', size(varsh,1)+1);
for hno = 1:size(varsh,1)
    fprintf(fid, ['%s = ' varsh{hno,4} '\n'], varsh{hno,1}, dh.(varsh{hno,3}));
end

%column headers
fprintf(fid, '%s, ', vars{1:end-1,1});
fprintf(fid, '%s\n', vars{end,1});
fprintf(fid, '%s, ', vars{1:end-1,2});
fprintf(fid, '%s\n', vars{end,2});

%data
for sno = 1:nsamp
    for cno = 1:size(vars,1)-1
        fprintf(fid, [vars{cno,4} ', '], d.(vars{cno,3})(sno,:));
    end
    fprintf(fid, [vars{end,4} '\n'], d.(vars{end,3})(sno,:));
end

%finish
fprintf(fid, '%s', 'END_DATA');
fclose(fid);
