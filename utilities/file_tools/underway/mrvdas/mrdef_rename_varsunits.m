 function mrtables = mrdef_rename_varsunits(mrtables)
% function mrtables = mrdef_rename_varsunits(mrtables)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% A list and/or set of find-replace for rvdas variable names and units we
% wish to rename when read into mexec, as well as those we wish to ignore
% (not read in). 
%
% The list in this script could be moved elsewhere, but is unlikely to
%   change much from cruise to cruise. It may be added to from time to
%   time.
%
% At the end of the function, ensures that all new variable names are
%   lowercase, regardless of what has been entered row by row.
%
% Examples
%
%   renametables = mrrename_varsunits;
%
% Input:
%   tables, the output of mrtables_from_json
%
% Output:
%
% renametables. A structure which is a set of rvdas table names and variables that will be
% renamed in mrload after reading into matlab and before writing to mexec.
%
% Examples of fields for renaming
%    renametables.ships_gyro_hehdt = {'headingTrue'  'degrees'  'heading' 'degrees'}
%    renametables.nmf_winch_winch = {'tension'  'newton'  'tension'  'tonnes'}


m_common

mrtables.mstarvars = mrtables.tablevars;
mrtables.mstarunts = mrtables.tableunts;

for no = 1:length(mrtables.tablenames)
    
    %change any names that don't work for mexec (mostly, shorten ones that
    %are too long)
    mvars = lower(cellfun(@(x) m_check_nc_varname(x,0), mrtables.mstarvars{no}, 'UniformOutput', false));
    munts = mrtables.mstarunts{no};
    munts(cellfun('isempty',munts)) = {' '};

    %extract units from names
    untsgrp = {'meter' 'metre'};
    [mvars, munts] = move_to_unts(mvars, munts, untsgrp, 'm');
    %***others?

    %replace units and in some cases modify names

    %latdegm
    m = strcmpi('utctime', mvars);
    munts(m) = {'hhmmss_fff'};
    untsgrp = {'degrees and decimal minutes' 'degrees, minutes and decimal minutes'};
    [munts, ~] = move_to_unts(munts, [], untsgrp, 'dddmm'); % just replace units, ignore 2nd arg
    mvars(strcmp('dddmm',munts) & strncmpi('lat',mvars,3)) = {'latdegm'};
    mvars(strcmp('dddmm',munts) & strncmpi('lon',mvars,3)) = {'londegm'};

    %typos as well as alternate forms
    untsgrp = {'degreesC' 'degC' 'degreesCelsius' 'degressCelsius' 'degrees celcius' 'degrees celsius'};
    [munts, ~] = move_to_unts(munts, [], untsgrp, untsgrp{1}); 
    untsgrp = {'longitudinalwaterspeed', 'longitudalwaterspeed'};
    [munts, ~] = move_to_unts(munts, [], untsgrp, untsgrp{1}); 
    untsgrp = {'ucsw_hoist','divalueallchannels'};
    [munts, ~] = move_to_unts(munts, [], untsgrp, untsgrp{1});
    %{'course' 'courseoverground' 'coursetrue'}
    %{'heading' 'headingtrue'}
    %{'temp_remote','remotewatertemperature','tempr'}
    %{'temp_housing','housingwatertemperature'}
    %{'speed_forward','longitudinalwaterspeed','speedfa','longitualwaterspeed'}
    %{'speed_stbd','speedps','transversewaterspeed'}
    %{'sst','seasurfacetemperature'}
    %{'temp','temperature'}
    %{'cond','conductivity'}

    %units where none supplied
    m = strcmp(' ', munts) & (strncmp('lat', mvars,3) | strncmp('lon', mvars,3));
    munts(m) = {'decimal_degrees'};
    m = strcmp(' ', munts) & (contains(mvars, 'temp') | contains(mvars, 'sst'));
    munts(m) = {'degreesC'};
    m = strcmp(' ', munts) & contains(mvars, 'sal');
    munts(m) = {'psu'};
    m = strcmp(' ', munts) & contains(mvars, 'cond');
    munts(m) = {'S_per_m'}; %***
    m = strcmp(' ', munts) & (contains(mvars, 'speed') & ~contains(mvars, 'knot'));
    munts(m) = {'m_per_second'};
    %m = strcmp(' ', munts) & contains(mvars,'head');
    %munts(m) = {'degrees_clockwise_from_N'};
    %m = strcmp(' ', munts) & contains(mvars, 'dir');
    %munts(m) = {'degrees'}; %***convention may be ship/inst specific
    m = strcmp(' ', munts) & contains(mvars, 'cab');
    munts(m) = {'m_per_second'};

    opt1 = 'ship'; opt2 = 'rvdas_units'; get_cropt

    %reassign
    mrtables.mstarvars{no} = mvars;
    mrtables.mstarunts{no} = munts;

end

% --------------------------------------------------
% subfunctions 
% --------------------------------------------------

%%%%%%%%% move_to_unts %%%%%%%%%
%
% search for elements of uoptions in vars, remove from vars, and put first
% element of uoptions into unts instead
% e.g. 
% [vars, unts] = move_to_unts(vars, unts, {'meter', 'metre'}, 'm');
% turns vars {'waterdepthmeter';'waterdepthmetrefromtransducer'} to 
% {'waterdepth';'waterdepthfromtransducer'} and units to
% {'m';'m'}
function [vars, unts] = move_to_unts(vars, unts, uoptions, unew)

if cellfun('isempty', vars)
    return
end
upat = cell2mat(cellfun(@(x) ['"' x '" | '], uoptions,...
    'UniformOutput', false));
upat = eval(['(' upat(1:end-3) ')']);
m = contains(vars, upat, 'IgnoreCase', true);
vars = replace(lower(vars), upat, '');
if isempty(unts)
    unts = [];
else
    unts(m) = repmat({unew}, sum(m), 1);
end


