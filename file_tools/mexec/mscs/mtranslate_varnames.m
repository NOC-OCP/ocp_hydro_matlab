function mtranslate_varnames(infile,instream)

% translate a filename using a rename template for a chosen data stream
%
% function mtranslate_varnames(infile,instream)
%
% INPUT:
%   infile: mstar file to have variable names translated
%   instream: name of SCS stream that will used to choose rename table in
%             templates directory
%
% OUTPUT:
%   output file is same as input file
%
% EXAMPLES:
%   mtranslate_varnames('pos_jr302_d148_raw.nc','seatex-gll')
%
% UPDATED:
%   help comments added BAK 3 Jun 2014 on jr302

% translate the variable names from 'raw' mstar files
% assuming input var names are from scs or techsas streams
% the lookup table is built from the instream name

m_common

scriptname = 'mtranslate_varnames';

% resolve the stream name and remove unwanted '-' and '.' characters.
% this is also done when building the translation tables.
tstream = msresolve_stream(instream);
tunder = tstream;
tunder(strfind(tunder,'-')) = '_';
tunder(strfind(tunder,'.')) = '_';

root_template = mgetdir('M_TEMPLATES');
fntemplatein = [root_template '/' MEXEC_G.Mshipdatasystem '_renamelist_' tunder '.csv'];
fntemplateot = [root_template '/' MEXEC_G.Mshipdatasystem '_renamelist_' tunder '_out.csv'];

% clean up the translation table if needed. This code was lifted from
% another script but should not be needed for this application.

cellall = mtextdload(fntemplatein,','); % load all text

clear snamesin snamesot sunits
for kline = 1:length(cellall)
    cellrow = cellall{kline}; % unpack rows
    snamesin{kline} = m_remove_outside_spaces(cellrow{1});
    snamesot{kline} = m_remove_outside_spaces(cellrow{2});
    sunits{kline} = m_remove_outside_spaces(cellrow{3});
    if length(sunits{kline})==0; sunits{kline} = ' '; end
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
% skip writing of duplicate output bak 2009-sep-17
% % % fidot = fopen(fntemplateot,'w'); % save back to out file
% % % for k = 1:numvar
% % %     fprintf(fidot,'%s%s%s%s%s\n',snamesin{k},',',snamesot{k},',',sunits{k});
% % % end
% % % fclose(fidot);

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

