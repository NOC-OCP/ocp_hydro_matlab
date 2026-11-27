function adcp_process(klist, types, varargin)
%
% wrapper script for processing LADCP and/or SADCP for stations in klist
% types is {'ladcp', 'sadcp'} or a subset
% optional arguments are parameter-value pairs:
%   'ladcp_constraints' is {'GPS', 'BT', 'SADCP'} (default) or a subset
%   'ladcp_pause' is true (default) to pause after each version of ladcp
%     processing
%   'ladcp_incr' is true (default) to apply each constraint incrementally
%     (i.e. in example above run process_cast with 'GPS', with 'GPS' &
%     'BT', and with 'GPS', 'BT', & 'SADCP')
%    'ladcp_sepud' is true (default) to process the up- and down-looker
%      separately *as well as together* (ignored if there is only one
%      instrument)
%
% to process ladcp quickly after each cast, with all available constraints
% (probably will not include SADCP yet) and both down and uplooker (if both
% are available) together:  
%   adcp_process(stn, 'ladcp', 'ladcp_incr', false, 'ladcp_sepud', false, 'ladcp_pause', false)

m_common
ladcp_pause = true;
ladcp_constraints = {'GPS', 'BT', 'SADCP'};
ladcp_incr = true;
ladcp_sepud = true;
for no = 1:2:nargin-2
    eval([varargin{no} ' = varargin{no+1};'])
end

klist = klist(:)';

%vmadcp station averages first, if specified, because they may be used in
%ladcp processing
if ismember('sadcp',types)
    for stn = klist
        opt1 = 'setup';opt2 = 'm_stn_string'; run(MEXEC_G.opt_cruise)
        opt1 = 'setup'; opt2 = 'pfiles'; run(MEXEC_G.opt_cruise)
        opt1 = 'adcp_proc'; opt2 = 'sadcp_on_station'; run(MEXEC_G.opt_cruise)
        mvad_station_av(stn, SADCP_inst, 'ctd')
    end
end


%then ladcp, if specified
if ismember('ladcp',types)
    if isempty(which('getinv'))
        error('LADCP processing functions not on path; try running m_setup again')
    end

    cdir = pwd;
    if isfield(MEXEC_G,'mexec_shell_scripts')
        css = fullfile(MEXEC_G.mexec_shell_scripts,'data_to_ws','lad_syncscript.sh');
        if exist(css,'file')
            system(['bash ' css]);
        end
    end

    for no = 1:14
        cfg0.figh(no) = figure(no);
    end

    for stn = klist

        opt1 = 'setup'; opt2 = 'm_stn_string'; run(MEXEC_G.opt_cruise)
        if ismember('SADCP',ladcp_constraints)
            opt1 = 'adcp_proc'; opt2 = 'sadcp_on_station'; run(MEXEC_G.opt_cruise);
            opt1 = 'setup'; opt2 = 'pfiles'; run(MEXEC_G.opt_cruise)
            if ~exist(pfiles.sadcp_stnav,'file')
                ladcp_constraints = setdiff(ladcp_constraints, 'SADCP', 'stable');
            end
        end
        ctdnav_asc_for_ladcp(stn); %create an ascii file of 1-hz averaged CTD data
        
        opt1 = 'adcp_proc'; opt2 = 'ladcp_files'; run(MEXEC_G.opt_cruise)
        list_ladcpfiles

        if (ladcp_sepud || isempty(infiled)) && ~isempty(infileu)
            %now process, either all together or adding one constraint at a time, depending on ladcp_incr
            lconstraints_and_process('UL', stn, ladcp_constraints, ladcp_incr, ladcp_pause)
        end

        if (ladcp_sepud || isempty(infileu)) && ~isempty(infiled)
            %now process, either all together or adding one constraint at a time, depending on ladcp_incr
            lconstraints_and_process('DL', stn, ladcp_constraints, ladcp_incr, ladcp_pause)
        end

        if ~isempty(infileu) && ~isempty(infiled)
            %now process, either all together or adding one constraint at a time, depending on ladcp_incr
            lconstraints_and_process('DLUL', stn, ladcp_constraints, ladcp_incr, ladcp_pause)
        end
    end
    cd(cdir)

    %ladcp_combined_file
end

function lconstraints_and_process(subdir, stn, ladcp_constraints, ladcp_incr, ladcp_pause)

m_common; opt1 = 'setup'; opt2 = 'm_stn_string'; run(MEXEC_G.opt_cruise)
if ~contains(subdir,'DL')
    %if no downlooker no point trying to apply bottom tracking constraint
    ladcp_constraints = setdiff(ladcp_constraints,'BT','stable');
else
    opt1 = 'setup'; opt2 = 'station_lists'; run(MEXEC_G.opt_cruise)
    if isfield(stnlists, 'stns_short') && ismember(stn, stnlists.stns_short)
        %cast was not full depth
        ladcp_constraints = setdiff(ladcp_constraints,'BT','stable');
    end
end

for cno = 1:length(ladcp_constraints)
    subdir = [subdir '_' ladcp_constraints{cno}]; %add to this for each constraint
    ee = ['f.subdir = ''' subdir ''';'];
    if ladcp_incr
        %run one at a time. where to put results of
        %processing:
        process_cast(stn, 1, 0, ee);
        if ladcp_pause
            fprintf(1,['inspect ' subdir ' plots, any key to continue\n'])
            pause
        end
    end
end
if ~ladcp_incr
    %only run the combined constraints, using final ee
    process_cast(stn, 1, 0, ee)
    if ladcp_pause
        fprintf(1,['inspect ' subdir ' plots, any key to continue\n'])
        pause
    end
end


