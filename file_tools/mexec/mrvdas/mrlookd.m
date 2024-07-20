function mrlookd(varargin)
% function mrlookd(fastflag)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Run mrdfinfo through all the rvdas tables and report number of data cycles,
% first and last times.
%
% Examples
%
%   mrlookd
%
%   mrlookd f
%
% Input:
%
%   Optional fastflag set to 'f', will not count cycles for each table, 
%   but will execute faster.
%
% Output:
%
%   To screen
%   Number of cycles; start and end time of data; mexec and rvdas table name.
%   The output is in red if the last cycle is more than 5 seconds before
%   now. A cell array allows the 5 to be adjusted for tables for which
%   there is a naturally longer delay, eg em120, ea600
%   If fastflag is set, the number of cycles is left blank for tables with
%   a start and end time. The number of cycles is shown as zero for tables
%   with no data.

m_common

switch nargin
    case 0
        fastflag = '';
    case 1
        if strcmp('f',varargin{1})
            fastflag = 'f';
        else
            fprintf(MEXEC_A.Mfider,'%s %s %s\n','Unexpected flag ',varargin{1},' in mrlookd');
            return
        end
    otherwise
        cc1 = char(varargin);
        cc2 = cc1';
        cc3 = cc2(:)';
        fprintf(MEXEC_A.Mfider,'%s %s %s\n','Unexpected flags ',cc3,' in mrlookd');
        return
end


mrtv = mrdefine;
mrtables_list = mrtv.tablenames;
sortlist = sort(mrtables_list);
ntables = length(sortlist);


for kl = 1:ntables
    table = sortlist{kl};
    ktable = strcmp(table,mrtv.tablenames);
    mtable = mrtv.mstarpre{ktable};
    mtablepad = [mtable '                          '];
    mtablepad = mtablepad(1:12); % mexec table, padded to length 12;
    d = mrdfinfo(table,'q',fastflag);
    nowsave = now; % bak on dy146 13 feb 2022; save the now time which will be used as a test for whether to print in red
    dn1 = d.dn1;
    dn2 = d.dn2;
    nc = d.ncyc;
    s1 = '00/00/00';
    s2 = '000';
    s3 = '00:00:00';
    s4 = '00/00/00';
    s5 = '000';
    s6 = '00:00:00';
    
    if ~isnan(dn1)
        s1 = datestr(dn1,'yy/mm/dd');
        dv = datevec(dn1); yorg = dv(1); dorg = datenum([yorg 1 1 0 0 0]);
        doy1 = floor(dn1)-dorg+1;
        s2 = sprintf('%03d',doy1);
        s3 = datestr(d.dn1,'HH:MM:SS');
    end
    if ~isnan(dn2)
        s4 = datestr(dn2,'yy/mm/dd');
        dv = datevec(dn2); yorg = dv(1); dorg = datenum([yorg 1 1 0 0 0]);
        doy2 = floor(dn2)-dorg+1;
        s5 = sprintf('%03d',doy2);
        s6 = datestr(dn2,'HH:MM:SS');
    end
    
    fidprint = MEXEC_A.Mfidterm;
    
    % Default is 5 seconds. If time since last cycle is longer than that, print to
    % Mfider. Cell array of warning times allows defaults for some tables.
    
    warn = 5;
    warning_times = { % set other warning times in seconds, for mexec table names
        'em120' 20
        'ea600' 20
        'multib' 20
        'multib_t' 20
        'singleb' 20
        'singleb_t' 20
        'rex2_wave' 300
        'wamos' 300
        };
    if isempty(warning_times); warning_times = cell(0,2); end
    kt = find(strcmp(mtable,warning_times(:,1)));
    if ~isempty(kt)
        warn = warning_times{kt,2};
    end
    
    if nc ~= 0 && nowsave-dn2 > warn/86400
        % print to err fid if end time was more than 'warn' seconds ago. But
        % only for tables with at least some data. This limit could be set
        % differently for each table, dpeending on the expected refresh
        % rate.
        fidprint = MEXEC_A.Mfider;
    end
    
    if nc > 0
        fprintf(fidprint,'%10d   %s   %s %s  %s  %s %s   %s   %s \n',nc,s1,s2,s3,'to',s5,s6,s4,[mtablepad table]);
    elseif nc == 0
        fprintf(fidprint,'%10d   %8s   %3s %8s  %2s  %3s %8s   %8s   %s \n',nc,' ',' ',' ',' ',' ',' ',' ',[mtablepad table]);
    else
        fprintf(fidprint,'%10s   %s   %s %s  %s  %s %s   %s   %s \n',' ',s1,s2,s3,'to',s5,s6,s4,[mtablepad table]);
    end
    
    
    
end
