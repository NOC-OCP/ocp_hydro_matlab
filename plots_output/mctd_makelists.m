
function mctd_makelists(varargin)
%
% mctd_makelists: make lists of useful things from a CTD station
%
% This is now a function.
%
% It can be called with arguments on the command line, or arguments in
% brackets.
%
% If no arguments are given, the station number will be promoted for and
% all lists made
% If any arguments are given, the first argument must be the station
% number.
% If precisely one argument is given, all lists will be made for that
% station
%
% Use: 
%     mctd_makelists        {and then respond with station number}
%     mctd_makelists 86     {all lists made}
%     mctd_makelists 86 all {all lists made}
%     mctd_makelists 86 co2 ch4  {selected lists made}
%     mctd_makelists(86,'all')
%     mctd_makelists(86,'co2','ch4')
%
% choices of lists are 
%     {'physics' 'nutsodv' 'nuts' 'co2' 'ch4' '1hz' 'firstlast' 'cfc'}
% 
% The common syntax 
%      stn = 16; mctd_makelists;
% will no longer work.%
%
% this draft jr302. bak. 25 jun 2014
% updated to call list_bot on dy040 12 dec 2015; bak and elm

m_common

scriptname = 'mctd_makelists';

if nargin == 0 % no args: prompt for station number and make all lists
        stnlocal = input('type stn number ');
        choices = {'all'};
end

if nargin == 1 % assume first arg is station number. Make all lists
    argstn = varargin{1};
    % input type could be char, if command line was "mctd_makelists 84" or
    % numeric if command was mctd_makelists(84)
    if ischar(argstn); argstn = str2num(argstn); end
    stnlocal = argstn;
    choices = {'all'};
end

if nargin > 1
    argstn = varargin{1};
    % input type could be char, if command line was "mctd_makelists 84" or
    % numeric if command was mctd_makelists(84)
    if ischar(argstn); argstn = str2num(argstn); end
    stnlocal = argstn;
    choices = varargin(2:end);
end
    
options = {'physics' 'allpsal' 'nutsodv' 'nuts' 'co2' 'ch4' '1hz' 'firstlast' 'cfc'}; % option cfc added dy040 12 dec 2015
% option allpsal added jc159 5 march 2018
if ~isempty(strmatch('all',choices,'exact'))
    choices = options;
end

root_ctd = mgetdir('M_CTD'); 

kdone = zeros(20,1); % use this to make sure we don't do a list more than once

for kloop = 1:length(choices)
    switch choices{kloop}
        case {'physics'}
            if kdone(1) == 1; continue; end
            stn  = stnlocal; choice = 'physics'; list_bot; clear stn;
            kdone(1) = 1;
        case {'allpsal'}
            if kdone(1) == 1; continue; end
            stn  = stnlocal; choice = 'allpsal'; list_bot; clear stn;
            kdone(1) = 1;
        case {'nutsodv'}
            if kdone(2) == 1; continue; end
            stn  = stnlocal; choice = 'nutsodv'; list_bot; clear stn;
            kdone(2) = 1;
        case {'nuts'}
            if kdone(3) == 1; continue; end
            stn  = stnlocal; choice = 'nuts'; list_bot; clear stn;
            kdone(3) = 1;
        case {'co2'}
            if kdone(4) == 1; continue; end
            stn  = stnlocal; choice = 'co2'; list_bot; clear stn;
            kdone(4) = 1;
        case {'ch4'}
            if kdone(5) == 1; continue; end
            stn  = stnlocal; choice = 'ch4'; list_bot; clear stn;
            kdone(5) = 1;
        case {'1hz'}
            if kdone(6) == 1; continue; end
            stn  = stnlocal; mout_1hzasc(stn); clear stn;
            kdone(6) = 1;
        case {'firstlast'}
            if kdone(7) == 1; continue; end
            stn  = stnlocal; mctd_list_first_last; clear stn;
            kdone(7) = 1;
        case {'cfc'}
            if kdone(8) == 1; continue; end
            stn  = stnlocal; choice = 'cfc'; list_bot; clear stn;
            kdone(8) = 1;
        otherwise
    end
end


