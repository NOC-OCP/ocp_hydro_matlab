function [newnames, newunits] = mtranslate_varnames(oldnames, instream)

% translate variable names using a rename template for a chosen data stream
%
% function mtranslate_varnames(hin,instream)
%
% INPUT:
%   oldnames: cell array (what would be h.fldnam in mstar file header)
%   instream: name of SCS stream that will used to choose rename table in
%             templates directory
%
% OUTPUT:
%   newnames and newunits, cell arrays same size as oldnames
%
% CALLED BY:
%   scs_to_mstar2
%
% UPDATED:
%   help comments added BAK 3 Jun 2014 on jr302

% translate the variable names from 'raw' mstar files
% assuming input var names are from scs or techsas streams
% the lookup table is built from the instream name

m_common

% resolve the stream name and remove unwanted '-' and '.' characters.
% this is also done when building the translation tables.
tstream = msresolve_stream(instream);
tunder = tstream;
tunder(strfind(tunder,'-')) = '_';
tunder(strfind(tunder,'.')) = '_';

% root_template = mgetdir('M_TEMPLATES');
fntemplatein = [MEXEC_G.mexec_source_root '/mexec_processing_scripts/varlists/' MEXEC_G.Mshipdatasystem '/'  MEXEC_G.Mshipdatasystem '_renamelist_' tunder '.csv'];

% clean up the translation table if needed. This code was lifted from
% another script but should not be needed for this application.

cellall = mtextdload(fntemplatein,',',0); % load all text

clear snamesin snamesot sunits
for kline = 1:length(cellall)
    cellrow = cellall{kline}; % unpack rows
    snamesin{kline} = m_remove_outside_spaces(cellrow{1});
    snamesot{kline} = m_remove_outside_spaces(cellrow{2});
    sunits{kline} = m_remove_outside_spaces(cellrow{3});
    if isempty(sunits{kline}); sunits{kline} = ' '; end
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

newnames = repmat({},size(oldnames));
newunits = newnames;
for k = 1:numvar
    kmatch = strcmpi(oldnames,snamesin{k});
    if sum(kmatch) % var exists in the raw file
        newnames{kmatch} = snamesot{k};
        newunits{kmatch} = sunits{k};
    end
end
