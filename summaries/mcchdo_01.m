% mcchdo_01: write CCHDO exchange file for sample data
% Use: mcchdo_01        
%
% The input list of variable names, example filename cchdo_varlist.csv
%    is a comma-delimeted list of vars to be renamed
%    The format of each column is
%    CCHDOname,CCHDOunits,mstarname
% The set of names is parsed and written back to cchdo_varlist_out.csv
% The set of names can be prepared in any unix text editor.
% It can also be prepared in excel and saved as csv, but on BAK's
% mac this generates csv files with c/r instead of n/l. Thus the
% _out.csv file is more suitable for editing on unix.
%

scriptname = 'mcchdo_01';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

% resolve root directories for various file types
root_templates = mgetdir('M_TEMPLATES');
root_ctd = mgetdir('M_CTD');

prefix1 = ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix2 = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix3 = ['cchdo_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

infile1 = [root_ctd '/' prefix1 'all_doxygen'];
infile1 = [root_ctd '/' prefix1 'all'];
otfile1 = [root_ctd '/' prefix3 'exchange.csv'];
renamefile = [root_templates '/' prefix3 'varlist.csv']; % read list of var names and units for empty sam template
renamefileout = [root_templates '/' prefix3 'varlist_out.csv']; % write list of var names and units for empty sam template

cellall = mtextdload(renamefile,','); % load all text

% now make it look as thought there were 3 columns and many lines, as in
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


[d h] = mload(infile1,'/',' ');

nsamp = length(d.sampnum); % number of samples
nmvars = length(h.fldnam);
ncvars = length(cchdonamesin);

% determine which data to write

othernames = {
    'EXPOCODE'
    'SECT_ID'
    'CASTNO'
    'DATE'
    'TIME'
    'LATITUDE'
    'LONGITUDE'
    'DEPTH'
    };
    
otherform = {'%s' '%s' '%d' '%s' '%s' '%10.5f' '%10.5f' '%6.0f'};

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

ustatnums = unique(d.statnum);
maxn = max(ustatnums);
lat = nan+ones(1,maxn);
lon = lat;
datebot = lat;
depth = lat;

cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

sumfn = ['station_summary_' cruise '_all.nc'];
[dsum hsum] = mload(sumfn,'/');

for kcount = 1:length(ustatnums);
    kstn = ustatnums(kcount);
    kindex = find(dsum.statnum == kstn);
    if isempty(kindex); continue; end
    lat(kstn) = dsum.lat(kindex);
    lon(kstn) = dsum.lon(kindex);
    depth(kstn) = dsum.cordep(kindex);
    datebot(kstn) = datenum(hsum.data_time_origin) + dsum.time_bottom(kindex)/86400;
end

othercells = cell(nsamp,8);
oopt = 'expo'; get_cropt

for ks = 1:nsamp
    stn_nbr = d.statnum(ks);
    %expocode
    othercells{ks,1} = expocode;
    %sect_id
    othercells{ks,2} = sect_id;
    %castno
    othercells{ks,3} = 1;
    %date
    if isfinite(datebot(stn_nbr))
        othercells{ks,4} = datestr(datebot(stn_nbr),'yyyymmdd');
    else
        othercells{ks,4} = '00000000';
    end
    %time
    if isfinite(datebot(stn_nbr))
        othercells{ks,5} = datestr(datebot(stn_nbr),'HHMM');
    else
        othercells{ks,5} = '00000000';
    end
    %lat
    othercells{ks,6} = lat(stn_nbr);
    %lon
    othercells{ks,7} = lon(stn_nbr);
    %depth
    othercells{ks,8} = depth(stn_nbr);
end

maincells = cell(nsamp,length(otvarsdata)+length(otvars));
mainnum = nan+ones(1,length(otvarsdata)+length(otvars));
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
fid = fopen([outfile '_hy.csv'], 'w');

% write header
oopt = 'headstr'; get_cropt
for no = 1:size(headstring, 1)
   fprintf(fid,'%s\n',headstring{no});
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

botflagindex = strmatch('BTLNBR_FLAG_W',otnames,'exact');

for ks = 1:nsamp
    if ~isempty(botflagindex)
        if maincells{ks,botflagindex} == 9; continue; end % don't write a line if the bottle flag was 9, ie no bottle closed
%         if maincells{ks,botflagindex} == 999; continue; end % di346 temporary, ennsure all bottles written out for CFC team
    end
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


