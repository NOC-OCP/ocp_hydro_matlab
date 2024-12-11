function [mt, varargout] = mrdef_dirs_tables
% [mt, skips] = mrdef_dirs_tables
% create lookup table mt for potential types of instrument-message
% combinations that we might (sometimes) want to load
%
% you can add new types of lines to the table, or add instruments and/or
% messages to an existing line. each instrument-message combination must
% occur only once in mt. splitting the instrument-message combinations that
% will be read into a given directory (dir) over multiple lines of mt, and
% specifying type (typ), is for human-reading convenience (e.g. position
% messages are listed on separate lines from heading messages even where
% they come from the same instrument and will be read into the same
% directory and files).  
%
% for backwards compatibility it may be helpful to add new lines using a
% test on MEXEC_G.mdefault_data_time_origin or similar ...
%
% optionally, also output skips, a structure listing tables/sentences,
% messages, and variables or patterns in variables to skip from this
% ship (set below) or cruise (opt_cruise rvdas_skip case)
% sentences/messages with no definition in mt do not need to be added to
% skips
%

m_common

%%%% define lookup table mt %%%%

n = 0;

% heading
n = n+1; mt(n).dir = 'nav'; mt(n).typ = 'head'; 
mt(n).inst = {'phins','posmv','seapathpos','shipsgyro'}; 
mt(n).msg = {'hehdt','gphdt','inhdt'}; %'pashr'
% roll, pitch, heave
n = n+1; mt(n).dir = 'nav'; mt(n).typ = 'att'; 
mt(n).inst = {'phins','posmv','seapathatt'};
mt(n).msg = {'pashr','pixseatitud','prdid','psxn23','kmatt','psmcv','psmbc','pixseheave0'}; 
% lat, lon
n = n+1; mt(n).dir = 'nav'; mt(n).typ = 'pos';
mt(n).inst = {'cnav','fugro','phins','posmv','seapathpos'}; %seapathatt
mt(n).msg = {'gpgga','gpggk','gpgll','pixsegpsin0','gngga','ingga','gngll','pixsepositi'};
% ship speed, course
n = n+1; mt(n).dir = 'nav'; mt(n).typ = 'shipmov'; 
mt(n).inst = {'cnav','fugro','posmv','seapathpos'};
mt(n).msg = {'gpvtg','gnvtg','invtg','pixsespeed0'}; 

% surface ocean remote/drop keel T measurements
n = n+1; mt(n).dir = 'met'; mt(n).typ = 'sst'; 
mt(n).inst = {'sbe38','sbe38dk'};
mt(n).msg = {'sbe38','psbsst1','phsst'}; 
% UCSW T, C, flow, fluo, trans
n = n+1; mt(n).dir = 'met'; mt(n).typ = 'tsg'; 
mt(n).inst = {'sbe45','surfmet'};
mt(n).msg = {'nanan','psbtsg1','pvsv1','pwltran1','pwlfluor1','plmflow1','sfuwy','pc4rhoist1'};
% pressure, humidity, air temp
n = n+1; mt(n).dir = 'met'; mt(n).typ = 'met'; 
mt(n).inst = {'surfmet'};
mt(n).msg = {'pcfrs','pvtnh2','pvbar','pmdew','sfmet'}; %pressure, humidity, precip n = n+1;
% radiation
n = n+1; mt(n).dir = 'met'; mt(n).typ = 'rad'; 
mt(n).inst = {'surfmet'};
mt(n).msg = {'pkpyrge','pkpyran','pspar','sflgt'}; %radiometers
% wind
n = n+1; mt(n).dir = 'met'; mt(n).typ = 'wind'; 
mt(n).inst = {'surfmet','windsonic','truewind'};
mt(n).msg = {'iimwv','wimwv','pmwind','gpxsm','truewind'};
% waves
% n = n+1; mt(n).dir = 'met'; mt(n).typ = wav; 
% mt(n).inst = {'wav'}; 
% mt(n).msg = {'pwam1','pramr','pwam'}; 

%singlebeam
n = n+1; mt(n).dir = 'bathy'; mt(n).typ = 'sbm'; 
mt(n).inst = {'ea640'}; 
mt(n).msg = {'sddpt','sddbs','sdalr','sddbk','sddbs','sddpt','dbdbt','sddbt'}; %'pskpdpt',
%multibeam (centre beam)
n = n+1; mt(n).dir = 'bathy'; mt(n).typ = 'mbm'; 
mt(n).inst = {'em122'}; 
mt(n).msg = {'kidpt','kodpt'}; 

%surface/near surface water speed
n = n+1; mt(n).dir = 'other'; mt(n).typ = 'log'; 
mt(n).inst = {'skipperlog','adcp'}; 
mt(n).msg = {'vmvbw','vdvbw'};
%winch
n = n+1; mt(n).dir = 'other'; mt(n).typ = 'winch'; 
mt(n).inst = {'winch'};
mt(n).msg = {'winch','sdawinch'}; 
%live ctd data***
n = n+1; mt(n).dir = 'other'; mt(n).typ = 'ctd'; 
mt(n).inst = {'ctd'}; 
mt(n).msg = {'smctd'}; 
%lat, lon, depth
n = n+1; mt(n).dir = 'other'; mt(n).typ = 'usbl'; 
mt(n).inst = {'ranger2usbl'};
mt(n).msg = {'psonlld'};
%lab conditions
n = n+1; mt(n).dir = 'other'; mt(n).typ = 'lab'; 
mt(n).inst = {'autosal','salrmtemp'}; 
mt(n).msg = {'autosal','salin'};

mt = struct2table(mt);


%%%% define skips %%%%

if nargout>1

    % first defaults
    skips.sentence = {};
    skips.sentence_pat = {};
    skips.sentence_var = {}; %***add to mrmstarnames parsing (for sda)
    skips.msg = {'glgsv', ...
        'gndtm', 'gngsa', 'gngst', 'gnzda', ...
        'gpdtm', 'gpgsa', 'gpgst', 'gpgsv', ...
        'gprmc', 'gpzda', ...
        'heths', 'inzda', 'ppnsd', ...
        'pcrfs', 'pctnh'}; %these might not be needed (at least as defaults), if they are never defined in mrmstarnames***
    skips.pat = {'unitsOf', 'unitOf', 'Unit', 'des', 'geoid', 'dgnss', 'type', ...
        'magvar', 'status', 'vbw', 'depthfeet', 'fathom', 'messagecounter' 'pointselected' ...
        'magnetic' 'flag' 'hdop' 'ggaqual' 'version' 'device' 'header' ...
        'factor' 'decimals' 'totalflow' 'flowratepulses' 'quality' 'accuracy' ...
        };
    skips.var = {'winchDatum' 'undefined' 'celsiusFlag' 'maxrangescale' ...
        'geoid' 'diffcAge' 'UTCDate' 'maxrange' 'trueheading' ...
        'truecourse' 'positioningmode' 'ggaqual' 'numsat' 'hdop' 'gllqual' ...
        'selftest' 'testmode' 'spare' 'checksum' 'syncbyte2' ...
        'identity' 'serialnumber' ...
        'flowratedecimals' 'flowratekfactordecimals' 'speedknots' 'speedkmph'};
    switch MEXEC_G.Mship
        case {'discovery','cook'} %should now be the same at least by default!
            skips.sentence = [skips.sentence, 'surfmet_gpxsm']; %exists with all the variables but no data?
        case 'sda'
            %         sentence_skip = [sentence_skip, 'singlebeam_skipper_gds_102_sddpt', 'singlebeam_skipper_gds102_sddbs',...
            %             'singlebeam_skipper_gds102_sddbk', 'singlebeam_skipper_gds102_pskpdpt', 'singlebeam_skipper_gds102_sdalr',...
            %             'gnss_saab_r5_supreme_gnrmc']; %skipped at mrnames stage
            skips.sentence_var = [skips.sentence_var, 'sd025_transmissometer_wetlabs_cstar_ucsw1_pwltran1_reference', ...
                'sd025_transmissometer_wetlabs_cstar_ucsw1_pwltran1_signal', 'sd025_transmissometer_wetlabs_cstar_ucsw1_pwltran1_correctedsignal'];
        otherwise
    end
    opt1 = 'ship'; opt2 = 'rvdas_skip'; get_cropt

    varargout{1} = skips;
end
