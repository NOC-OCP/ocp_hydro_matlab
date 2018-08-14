% mout_cchdo_ctd: write data from ctd_cruise_nnn_2db.nc to CCHDO exchange file
% Use: mout_cchdo_ctd        
%
% variables to be written are listed in templates/cchdo_ctd_varlist.csv,
%    a comma-delimeted list of vars to be renamed
%    The format of each column is
%    CCHDOname,CCHDOunits,mstarname
%
% edit jc159 so that this can write a file for cchdo and also a file 
% containing other uncalibrated ctd variables for internal use, if 
% writeallctd exists and is set to 1. in this case it will get the template
% from all_ctd_renamelist and write to outfileall rather than outfile (both
% are set in opt_cruise)

scriptname = 'mout_cchdo_ctd';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn;
clear stn % so that it doesn't persist

% resolve root directories for various file types
root_templates = mgetdir('M_TEMPLATES');
root_ctd = mgetdir('M_CTD');

prefix2 = ['ctd_' mcruise '_'];
if exist('writeallctd') & writeallctd
    prefix3 = 'all_ctd_';
else
    prefix3 = 'cchdo_ctd_';
end

infile1 = [root_ctd '/' prefix2 stn_string '_2db.nc'];
renamefile = [root_templates '/' prefix3 'varlist.csv']; % read list of var names and units for empty sam template
renamefileout = [root_templates '/' prefix3 'varlist_out.csv']; % write list of var names and units for empty sam template

cellall = mtextdload(renamefile,','); % load all text

% now make it look as though there were 3 columns and many lines, as in
% the other template files
nlines = length(cellall);
if nlines < 5 % go ahead with 'transpose' if needed
    cellnew = {};
    for kline = 1:nlines
        clear cline;
        cline = cellall{kline};
        for kl2 = 1:length(cline);
            cellnew{kl2}{kline} = cline{kl2};
        end
    end
    cellall = cellnew;
end
clear cchdonamesin mstarnamesin cchdounits exformat
for kline = 1:length(cellall)
    cellrow = cellall{kline}; % unpack rows
    cchdonamesin{kline} = m_remove_outside_spaces(cellrow{1});
    cchdounits{kline} = m_remove_outside_spaces(cellrow{2});
    if isempty(cchdounits{kline})
        cchdounits{kline} = ' ';
    end
    mstarnamesin{kline} = m_remove_outside_spaces(cellrow{3});
    exformat{kline} = m_remove_outside_spaces(cellrow{4});
end
cchdonamesin = cchdonamesin(:);
mstarnamesin = mstarnamesin(:);
cchdounits = cchdounits(:);
exformat = exformat(:);
numvar = length(cchdonamesin);

% mstarunique = unique(mstarnamesin);
% if length(mstarunique) < length(mstarnamesin)
%     m = 'There is a duplicate name in the list of variables to rename';
%     error(m)
% end

fidmcchdo01 = fopen(renamefileout,'w'); % save back to out file
for k = 1:numvar
    fprintf(fidmcchdo01,'%s%s%s%s%s%s%s\n',cchdonamesin{k},',',cchdounits{k},',',mstarnamesin{k},',',exformat{k});
end
fclose(fidmcchdo01);

if exist(m_add_nc(infile1),'file') ~= 2; return; end

[d h] = mload(infile1,'/',' ');

nsamp = length(d.press); % number of levels
nmvars = length(h.fldnam);
ncvars = length(cchdonamesin);

% determine which data to write

othernames = {
    'EXPOCODE'
    'SECT'
    'STNNBR'
    'CASTNO'
    'DATE'
    'TIME'
    'LATITUDE'
    'LONGITUDE'
    'DEPTH'
    };
    
otherform = {'%s' '%s' '%d' '%d' '%s' '%s' '%10.5f' '%10.5f' '%6.0f'};

clear otvarsdata otvars
otvars = []; otvarsdata = [];
kmatch = cell(2,ncvars);
for kvar = 1:ncvars
    cname = cchdonamesin{kvar};
    mname = mstarnamesin{kvar};
    kmatch{1,kvar} = strmatch(mname,h.fldnam,'exact');
    kmatch{2,kvar} = strmatch(cname,othernames,'exact');
    if ~isempty(kmatch{1,kvar})
       m = ['Match found for mstarname ' sprintf('%20s',mname) ' cchdo name ' cname ];
       fprintf(MEXEC_A.Mfidterm,'%s\n',m);
       otvarsdata = [otvarsdata kvar];
    end
    if ~isempty(kmatch{2,kvar})
       m = ['Including cchdo name ' cname ];
       fprintf(MEXEC_A.Mfidterm,'%s\n',m);
       otvars = [otvars kvar];
    end
end

% populate 'other' vars

ustatnums = stnlocal;
maxn = max(ustatnums);
lat = nan+ones(1,maxn);
lon = lat;
datebot = lat;
depth = lat;

root_sum = mgetdir('M_SUM');
sumfn = [root_sum '/station_summary_' mcruise '_all.nc'];
[dsum hsum] = mload(sumfn,'/');

for kcount = 1:length(ustatnums);
    kstn = ustatnums(kcount);
    kindex = find(dsum.statnum == kstn);
    lat(kstn) = dsum.lat(kindex);
    lon(kstn) = dsum.lon(kindex);
    depth(kstn) = dsum.cordep(kindex);
    datebot(kstn) = datenum(hsum.data_time_origin) + dsum.time_bottom(kindex)/86400;
end

nsamp2 = 1;
othercells = cell(nsamp2,8);

oopt = 'expo'; get_cropt

for ks = 1:nsamp2
    stn_nbr = stnlocal;
    %expocode
    othercells{ks,1} = expocode;
    %sect_id
    othercells{ks,2} = sect_id;
    %sntnbr
    othercells{ks,3} = stn_nbr;
    %castno
    othercells{ks,4} = 1;
    %date
    othercells{ks,5} = datestr(datebot(stn_nbr),'yyyymmdd');
    %time
    othercells{ks,6} = datestr(datebot(stn_nbr),'HHMM');
    %lat
    othercells{ks,7} = lat(stn_nbr);
    %lon
    othercells{ks,8} = lon(stn_nbr);
    %depth
    othercells{ks,9} = depth(stn_nbr);
end

maincells = cell(nsamp,length(otvarsdata));
mainnum = nan+ones(1,length(otvarsdata));
otnames = {};
otunits = {};
otform = {};
for kvar = 1:ncvars
    if ~isempty(kmatch{1,kvar})
        newname = cchdonamesin{kvar};
        newunits = cchdounits{kvar};
        newform = exformat{kvar};
        otnames = [otnames newname];
        otunits = [otunits newunits];
        otform = [otform newform];
        mstarname = mstarnamesin{kvar};
        cmd = ['data = d.' mstarname ';']; eval(cmd);
        data = data(:);
        if ~isempty(strfind(newname,'FLAG'))
            % flag variable; set all real numbers to 2 and nans to 9
            data = 2+0*data;
            data(isnan(data)) = 9;
            oopt = 'flags'; get_cropt %optionally change flags
        end
        for ks = 1:nsamp
            maincells(ks,length(otnames)) = {data(ks)};
        end
    end
    if ~isempty(kmatch{2,kvar})
        newname = othernames{kmatch{2,kvar}};
        newunits = {' '};
        newform = otherform{kmatch{2,kvar}};
        otnames = [otnames newname];
        otunits = [otunits newunits];
        otform = [otform newform];
        for ks = 1:nsamp
            maincells(ks,length(otnames)) = othercells(ks,kmatch{2,kvar});
        end
    end
end

oopt = 'outfile'; get_cropt
if exist('writeallctd','var') & writeallctd
    fotname = [outfileall '_' sprintf('%05d',stnlocal) '_0001.csv'];
else
    fotname = [outfile '_' sprintf('%05d',stnlocal) '_0001_ct1.csv'];
end

%%%%%% now start writing file %%%%%%
fid = fopen(fotname,'w');

% write header
oopt = 'headstr'; get_cropt
for no = 1:size(headstring, 1)
   fprintf(fid,'%s\n',headstring{no});
end

% more header
fprintf(fid, '%s %d\n', 'NUMBER_HEADERS = ', length(othernames)+1);
for kother = 1:length(othernames)
    headstring = [othernames{kother} ' = ' sprintf(otherform{kother},othercells{1,kother})];
    fprintf(fid,'%s\n',headstring);
end


ncols = size(maincells,2);
for kcol = 1:ncols-1
    fprintf(fid,'%s,',otnames{kcol});
end
fprintf(fid,'%s\n',otnames{end});
for kcol = 1:ncols-1
    fprintf(fid,'%s,',otunits{kcol});
end
fprintf(fid,'%s\n',otunits{end});

for ks = 1:nsamp
%     if maincells{ks,6} == 9; continue; end
    for kcol = 1:ncols-1
        form = [otform{kcol} ','];
        val = maincells{ks,kcol}; if isnan(val); val = -999; end
        fprintf(fid,form,val);
    end
    form = [otform{end} '\n'];
            val = maincells{ks,end}; if isnan(val); val = -999; end
    fprintf(fid,form,val);
end

fprintf(fid,'%s\n','END_DATA');
fclose(fid);
