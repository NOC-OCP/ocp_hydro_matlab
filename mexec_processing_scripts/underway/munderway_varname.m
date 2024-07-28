function output = munderway_varname(varargin)
% function output = munderway_varname();
% function output = munderway_varname(varname_try, varnames_avail, flag)
%
% function for looking up underway variable names
%
% no input arguments: returns list of variable categories
%
% with one or more input arguments: 
% first input varname_try, a string:
%     returns list of variable names in category either specified by or
%     containing varname_try, as a cell array of strings
% first input varname_try, a cell array of strings:
%     as above but returns cell array containing a cell array of strings
%     for each element in varname_try
%
% with two or more input arguments: 
% second input varnames_avail, a cell array of strings:
%     returns subset(s) of above list(s) that is(are) also found in
%     varnames_avail
% second input empty matrix or cell: 
%     ignores this
%
% with three or more input arguments:
% subsequent input 1 (and non-empty varnames_avail):
%     returns only the first element in each component of output array
%     (first in the lookup table contained in this script, not necessarily
%     first in varnames_avail)
% subsequent input 's':
%     returns output as single concatenated (row) cell array of strings
%
%
% examples (which may not correspond to present state of lookup table in
%     code): 
%
% >> munderway_varname
% returns
% {'cabvar' 'salvar' 'tempvar' 'sstvar' 'condvar' 'flowvar' 'windsvar' ...}
%
% >> munderway_varname('condvar')
% returns
% {'conductivity' 'cond' 'conductivity_raw'}
%
% >> munderway_varname('cond')
% returns
% {'conductivity' 'cond' 'conductivity_raw'}
%
% >> munderway_varname({'salinity' 'cond'})
% returns
% {{'salinity' 'psal' 'salinity_raw' 'sal_cal'} {'conductivity' 'cond' 'conductivity_raw'}}
%
% >> munderway_varname({'salinity' 'cond'}, [], 's')
% returns
% {'salinity' 'psal' 'salinity_raw' 'sal_cal' 'conductivity' 'cond' 'conductivity_raw'}
%
% >> munderway_varname({'salinity' 'cond'}, [], 's', 1)
% returns
% {'salinity' 'conductivity'}
%
% >> munderway_varname('cond', {'time' 'temp_housing_raw' 'conductivity_raw' 'temp_remote_raw'})
% returns
% {{'conductivity_raw'}}
%
% >> munderway_varname('condvar', {'time' 'conductivity_raw' 'conductivity'})
% returns
% {'conductivity_raw' 'conductivity'}
%
% >> munderway_varname('condvar', {'time' 'conductivity_raw' 'conductivity'}, 1)
% returns
% {'conductivity'}
%
% >> munderway_varname({'lat' 'lon' 'junk'}, {'time' 'latitude' 'longitude' 'heading'})
% returns
% {{'latitude' 'longitude'}}
%
% >> munderway_varname({'lat' 'lon' 'junk'}, {'time' 'latitude' 'longitude' 'heading'}, 's')
% returns
% {'latitude' 'longitude'}
%


%add new names, or lists of names, as necessary. includes misspellings
%encountered in databases. 

varnames.timvar = {'time' 'measureTS' 'utctime' 'dnum'};

varnames.salvar = {'sal_cal' 'salinity_calibrated' 'salinity_cal' 'salinity' 'psal' 'salinity_raw'};
varnames.tempvar = {'housingtemp' 'temp_h' 'tstemp' 'temp_raw' 'temph_raw' 'temp_m' 'temp_housing_cal' 'temp_housing' 'temp_housing_raw' 'temperature' 'temp' 'temph'};
varnames.sstvar = {'remotetemp' 'temp_r' 'sstemp' 'temp_remote' 'temp_remote_raw' 'seasurfacetemperature' 'remotewatertemperature' 'tempr' 'sst'};
varnames.condvar = {'conductivity_calibrated' 'conductivity' 'cond' 'conductivity_raw' 'cond_raw'};
varnames.svelvar = {'sndspeed' 'soundvelocity' 'soundvelocity_raw'};
varnames.flowvar = {'flow' 'flow1' 'flowrate'};

varnames.airtempvar = {'airtemp' 'airtemperature'};
varnames.humidvar = {'humid' 'humidity'};
varnames.airpresvar = {'airpressure' 'pres'};
varnames.pparvar = {'ppar' 'parport'};
varnames.sparvar = {'spar' 'parstarboard'};
varnames.pparvar = {'ptir' 'tirport'};
varnames.sparvar = {'stir' 'tirstarboard'};

varnames.rwindsvar = {'windspeed_raw' 'relwind_spd_raw' 'windspeed'};
varnames.rwinddvar = {'winddirection_raw' 'relwind_dirship_raw' 'winddirection'};
varnames.rwindvvar = {'xcomponent' 'ycomponent' 'zcomponent'}; %***
varnames.twindsvar = {'windspeed' 'wind_speed_ms' 'truwind_spd'};
varnames.twinddvar = {'direct' 'wind_dir' 'truwind_dir' 'winddirection'};
varnames.twindvvar = {'truwind_e' 'truwind_n' 'truwind_u' 'truwind_v'};

varnames.latvar = {'lat' 'latitude' 'seatex_gll_lat'};
varnames.lonvar = {'lon' 'long' 'longitude' 'seatex_gll_lon'};
varnames.headvar = {'head' 'heading' 'head_gyr' 'heading_av_corrected' 'heading_av' 'headingtrue'};
varnames.cogvar = {'course' 'courseoverground' 'coursetrue'};

varnames.multibvar = {'em120' 'em122' 'multib' 'multib_t'};
varnames.singlebvar = {'ea600' 'sim' 'singleb' 'singleb_t'};
varnames.depvar = {'depth' 'waterdepth' 'water_depth_metres' 'waterdepth_meters' 'waterdepthmetre'};
varnames.depsrefvar = {'waterdepthfromsurface','waterdepthsurface'};
varnames.deptrefvar = {'waterdepth_below_transducer','waterdepthtransducer','waterdepthfromtransducer'};
varnames.xducerdepvar = {'transduceroffset' 'xduceroffset' 'xducer_offset' 'transducer_offset'};

varnames.fspdvar = {'speed_forward' 'longitudinalwaterspeed' 'longitudalwaterspeed' 'speedfa'};
varnames.pspdvar = {'speed_port' 'transversewaterspeed' 'speedps'}; %***port or stbd?

varnames.cabvar = {'cableout' 'cab' 'cable' 'wireout' 'winch_cable_out' 'out' 'mfctdcablelengthout' 'ctdcablelengthout'};
varnames.ucswivar = {'ucsw_hoist' 'divalueallchannels'};

cats = fieldnames(varnames);

first = 0; singlecell = 0;
if isempty(varargin)
    %just wanted the list of variable categories
    output = cats;
    return
    
else
    
    varname_try = varargin{1};
    if ~iscell(varname_try)
        varname_try = {varname_try};
    end
    
    if length(varargin)>1 && ~isempty(varargin{2})
        fldnams = varargin{2};
        
        for no = 3:length(varargin)
            if isnumeric(varargin{no})
                first = varargin{no};
            elseif strncmp('s', varargin{no}, 1)
                singlecell = 1;
            end
        end
        
    end
    
end

if singlecell
    output = {};
else
    output = cell(size(varname_try));
end

for tno = 1:length(varname_try)
    
    cat = intersect(varname_try(tno), cats); %maybe it is one of the category names
    if isempty(cat)
        %look in the list of names to find which category it belongs to
        if ~exist('allvars', 'var')
            %create concatenated list
            allvars = {}; allcats = {};
            for cno = 1:length(cats)
                allvars = [allvars varnames.(cats{cno})];
                allcats = [allcats repmat(cats(cno),1,length(varnames.(cats{cno})))];
           end
        end
        ia = find(strcmp(varname_try{tno}, allvars));
        if isempty(ia)
            %not found; leave this output empty
            continue
        else
            cat = allcats{ia};
        end
    else
        cat = cat{1};
    end
    
    if exist('fldnams', 'var')
        %return the variable names in this category that are in fldnams
        %(second input)
        data = intersect(varnames.(cat), fldnams);
        if isempty(data)
            return
        end
        if first
            data = data{1};
        end
        if singlecell
            output = [output data];
        else
            output{tno} = data;
        end
    else
        %just return all of the names in this category (first does not
        %apply)
        if singlecell
            output = [output varnames.(cat)];
        else
            output{tno} = varnames.(cat);
        end
    end
    
end

if tno==1 && first && singlecell && ~isempty(output) && iscell(output(1))
    output = output{1};
end
