% mctd_02a: rename SBE variable names
%
% Use: mctd_02a        and then respond with station number, or for station 16
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
% This also adds position from the underway (techsas or scs) stream to the header
%
% After mheadr, the _raw.nc file is write protected

scriptname = 'mctd_02a';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['renames variables in ctd_' cruise '_' stn_string '_raw.nc based on templates/ctd_' cruise '_renamelist.csv, and adds position from underway stream (if available)']);

% resolve root directories for various file types
root_templates = mgetdir('M_TEMPLATES');
root_ctd = mgetdir('M_CTD');

prefix = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

infile = [root_ctd '/' prefix stn_string '_raw'];
renamefile = [root_templates '/' prefix 'renamelist.csv']; % read list of var names and units
renamefileout = [root_templates '/' prefix 'renamelist_out.csv']; % write list of var names and units

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
    kmatch = strmatch(vnamein,hin.fldnam,'exact');
    if ~isempty(kmatch) % var exists in the raw file
        snames_units = [snames_units snamesin{k} snamesot{k} sunits{k}];
    end
end
snames_units = snames_units(:);

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

oopt = 'corraw'; get_cropt

cmd = ['!chmod 444 ' m_add_nc(infile)]; eval(cmd) % write protect raw file




