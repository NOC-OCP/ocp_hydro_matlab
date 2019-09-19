% mout_cchdo_sam: write the sample data in sam_cruise_all.nc to CCHDO exchange file
% Use: mout_cchdo_sam        
%
% variables to be written are listed in templates/cchdo_sam_varlist.csv, 
%    a comma-delimeted list of vars to be renamed
%    The format of each column is
%    CCHDOname,CCHDOunits,mstarname
%

scriptname = 'mout_cchdo_sam';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

% resolve root directories for various file types
root_templates = mgetdir('M_TEMPLATES');
root_ctd = mgetdir('M_CTD');

prefix1 = ['sam_' mcruise '_'];
prefix2 = 'ctd_';
prefix3 = 'cchdo_';

infile1 = [root_ctd '/' prefix1 'all'];
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
ii = find(isnan(d.utemp+d.upsal)); %don't write the rows with no CTD data, they will be all NaN/9 anyway
for no = 1:length(h.fldnam)
    a = getfield(d, h.fldnam{no}); a(ii) = [];
    d = setfield(d, h.fldnam{no}, a);
end
d.den20 = sw_dens(d.upsal, repmat(20,size(d.upsal)), repmat(0,size(d.upsal)));
if isfield(d, 'silc');
   d.silc_per_kg = d.silc./d.den20*1e3;
   d.phos_per_kg = d.phos./d.den20*1e3;
   d.totnit_per_kg = d.totnit./d.den20*1e3;
   d.no2_per_kg = d.no2./d.den20*1e3;
   h.fldnam = [h.fldnam 'silc_per_kg' 'phos_per_kg' 'totnit_per_kg' 'no2_per_kg'];
   h.fldunt = [h.fldunt 'umol/kg' 'umol/kg' 'umol/kg' 'umol/kg'];
end
if 0%isfield(d, 'sf6')
   d.cfc11_per_kg = d.cfc11./d.dens*1e3;
   d.cfc12_per_kg = d.cfc12./d.dens*1e3;
   d.ccl4_per_kg = d.ccl4./d.dens*1e3;
   d.f113_per_kg = d.f113./d.dens*1e3;
   d.sf6_per_kg = d.sf6./d.dens*1e3;
   h.fldnam = [h.fldnam 'cfc11_per_kg' 'cfc12_per_kg' 'ccl4_per_kg' 'f113_per_kg' 'sf6_per_kg'];
   h.fldunt = [h.fldunt 'pmol/kg' 'pmol/kg' 'pmol/kg' 'pmol/kg' 'fmol/kg'];
end
if ~isfield(d,'ctdflag'); 
   d.ctdflag = 2+zeros(size(d.upsal)); 
   d.ctoflag = d.ctdflag; d.ctoflag(isnan(d.uoxygen)) = 4;
   h.fldnam = [h.fldnam 'ctdflag' 'ctoflag']; h.fldunt = [h.fldunt 'woce_table_4.10' 'woce_table_4.10'];
end
[n1,n2] = size(d.sampnum);
if n2==24 & n1>1
    fn = fieldnames(d);
    for n = 1:length(fn)
        d = setfield(d, fn{n}, reshape(getfield(d, fn{n})', n1*n2, 1));
    end
end
oopt = 'nocfc'; get_cropt

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
ctdflag = 2+zeros(1,maxn);

root_sum = mgetdir('M_SUM');
sumfn = [root_sum '/station_summary_' mcruise '_all.nc'];
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


