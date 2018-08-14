% mctd_02: rename SBE variable names
%
% Use: mctd_02        and then respond with station number, or for station 16
%      stn = 16; mctd_02;
%
% The input list of variable names, example filename ctd_jr193_renamelist.csv
%    is a comma-delimeted list of vars to be renamed
%    The format of each line is
%    oldname,newname,newunits
% The set of names is parsed and written back to ctd_jr193_renamelist_out.csv
% The set of names can be prepared in any unix text editor.
% It can also be prepared in excel and saved as csv, but on BAK's
% mac this generates csv files with c/r instead of n/l. Thus the
% _out.csv file is more suitable for editing on unix.
%
% After mheadr, the _raw.nc file is write protected, and copied to _24hz.nc which
% becomes the working copy.
% gdm di346: 23 jan 2010; cut into two parts. part a renames sbe var names to
% mstar var names; part b calculates oxygen hysteresis adjustment from old
% variable 'oxygen_sbe' to new variable 'oxygen'. This allows us to select
% our own hysteresis correction parameters. The _24hz file is now generated
% from _raw in part b.
%
% bak on dy040 noctm version for when we read in data before align and ctm
%

scriptname = 'mctd_02a_noctm'; % dy040 noctm

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stn_local = stn; % carry station number into script
clear stn % so that it doesn't persist

% resolve root directories for various file types
mcsetd('M_TEMPLATES'); root_templates = MEXEC_G.MEXEC_CWD;
mcd('M_CTD'); % change working directory

prefix = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

infile = [prefix stn_string '_noctm']; % dy040 noctm
otfile2 = [prefix stn_string '_24hz'];
renamefile = [root_templates '/' prefix 'renamelist.csv']; % read list of var names and units for empty sam template
renamefileout = [root_templates '/' prefix 'renamelist_out.csv']; % write list of var names and units for empty sam template

cellall = mtextdload(renamefile,','); % load all text

clear snamesin snamesot sunits
for kline = 1:length(cellall)
    cellrow = cellall{kline}; % unpack rows
    snamesin{kline} = m_remove_outside_spaces(cellrow{1});
    snamesot{kline} = m_remove_outside_spaces(cellrow{2});
    sunits{kline} = m_remove_outside_spaces(cellrow{3});
end
snamesin = snamesin(:);
snamesot = snamesot(:);
sunits = sunits(:);
numvar = length(snamesin);

sunique = unique(snamesin);
if length(sunique) < length(snamesin)
    m = 'There is a duplicate name in the list of variables to rename';
    error(m)
end

fidmctd02 = fopen(renamefileout,'w'); % save back to out file
for k = 1:numvar
    fprintf(fidmctd02,'%s%s%s%s%s\n',snamesin{k},',',snamesot{k},',',sunits{k});
end
fclose(fidmctd02);

hin = m_read_header(infile); % get var names in file

snames_units = {};
for k = 1:numvar
    vnamein = snamesin{k};
    kmatch = strmatch(vnamein,hin.fldnam);
    if ~isempty(kmatch) % var exists in the raw file
        snames_units = [snames_units snamesin{k} snamesot{k} sunits{k}];
    end
end
snames_units = snames_units(:);

%--------------------------------
% 2009-01-26 07:48:13
% mheadr
% input files
% Filename ctd_jr193_016_24hz.nc   Data Name :  sbe_ctd_rawdata <version> 51 <site> bak_macbook
% output files
% Filename ctd_jr193_016_24hz.nc   Data Name :  ctd_jr193_016 <version> 12 <site> bak_macbook
MEXEC_A.MARGS_IN_1 = {
    infile
    'y'
    '8'
    };
MEXEC_A.MARGS_IN_2 = snames_units;
MEXEC_A.MARGS_IN_3 = {
    '-1'
    '-1'
    };
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3];
mheadr
%--------------------------------

% JC032: Now fix position in header; assigned position is from when press was
% equal to deepest value on cast. Use the new mtposinfo.
% find time of bottom of cast
[d h] = mload(infile,'time','press',' ');
p = d.press;
kbot = min(find(p == max(p)));
tbot = d.time(kbot);
tbotmat = datenum(h.data_time_origin) + tbot/86400; % bottom time as matlab datenum
if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
    [botlat botlon] = msposinfo(tbotmat);
else % techsas
    [botlat botlon] = mtposinfo(tbotmat);
end
latstr = sprintf('%14.8f',botlat);
lonstr = sprintf('%14.8f',botlon);

%--------------------------------
MEXEC_A.MARGS_IN = {
infile
'y'
'5'
latstr
lonstr
' '
' '
};
mheadr
%--------------------------------

% di346, adcp, fluor and trans off for some stations greater than 6000
% metres

if strcmp(MEXEC_G.MSCRIPT_CRUISE_STRING,'di346')
    stn_list = [64 200 65 66 67 68 69 ];
    kmat = find(stn_list == stn_local);
    if ~isempty(kmat)
        % for these stations on this cruise we set fluor and trans to absent
        %--------------------------------
        % 2010-01-23 12:57:58
        % mcalib
        % calling history, most recent first
        %    mcalib in file: mcalib.m line: 91
        % input files
        % Filename gash.nc   Data Name :  ctd_di346_064 <version> 23 <site> di346_atsea
        % output files
        % Filename gash.nc   Data Name :  ctd_di346_064 <version> 24 <site> di346_atsea
        MEXEC_A.MARGS_IN = {
            infile
            'y'
            'fluor'
            'y = x+nan'
            ' '
            ' '
            'transmittance'
            'y = x+nan'
            ' '
            ' '
            ' '
            };
        mcalib
        %--------------------------------
    end
end

cmd = ['!chmod 444 ' m_add_nc(infile)]; eval(cmd) % write protect raw file




