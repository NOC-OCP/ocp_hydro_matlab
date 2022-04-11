%script containing code from previous version of mday_01_clean_av to rename
%variables and convert (or rename) some units for scs and techsas streams
%(for rvdas much variable renaming is done at an earlier stage)

%%%%% change variable names (calling mheadr) %%%%%
%fields of nn are mexec short names (abbrev) for which some change to names
%is required, and nu is the same for changing units
%if multiple changes are required in one file (for different variables)
%expand row dimension of cell arrays
clear nn nu
nn.junk = []; nu.junk = [];
switch MEXEC_G.Mshipdatasystem
    case {'techasas' 'scs'}
        
        nn.ash.new = {'head_ash'}; nn.ash.old = {'head'};
        nn.gys = nn.ash; nn.gys_s = nn.ash; nn.gyro_pmv = nn.ash; nn.gyropmv = nn.ash;
        nn.gpsfugro.new = {'long'}; nn.gpsfugro.old = {'lon'};
        nn.sim.new = {'depth_uncor'}; nn.sim.old = {'depthm' 'depth' 'dep' 'snd'};
        
        nn.ea600 = nn.sim; nn.ea600m = nn.sim;
        nn.em120.new = {'swath_depth'}; nn.em120.old = {'depthm' 'dep' 'snd'};
        nn.em122 = nn.em120;
        
        nn.tsg.new = {'psal'}; nn.tsg.old = {'salinity' 'salin'};
        nn.met_tsg = nn.tsg;
        nn.met.old = {'wind_speed_ms','direct','wind_dir'}; nn.met.new = {'relwind_spd','relwind_dirship','relwind_dirship'};
        nu.met.name = {'relwind_dirship'}; nu.met.unit = {'degrees relative to ship 0 = from bow'};
        
    case 'rvdas'
        
        nn.em120.new = {'swath_depth'}; nn.em120.old = {'waterdepth'};
        nn.ea600.new = {'depth_uncor'}; nn.ea600.old = {'waterdepth'};
        nn.multib.new = {'swath_depth'}; nn.multib.old = {'waterdepth'};
        nn.singleb.new = {'depth_uncor'}; nn.singleb.old = {'waterdepth'};
        
        nn.surfmet.old = {'windspeed_raw';'winddirection_raw'}; nn.surfmet.new = {'relwind_spd_raw';'relwind_dirship_raw'};
        nu.surfmet.name = {'relwind_dirship'}; nu.surfmet.unit = {'degrees relative to ship 0 = from bow'};
        
end

if isfield(nn, abbrev)
    newnames = nn.(abbrev).new; oldnames = nn.(abbrev).old;
    h = m_read_header(otfile);
    for nno = 1:size(newnames,1)
        no = 1;
        while ~sum(strcmp(newnames{nno}, h.fldnam)) && no<=length(oldnames(nno,:))
            name = oldnames{nno,no};
            varnum = find(strncmp(name, h.fldnam, length(name)));
            if ~isempty(varnum)
                MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; sprintf('%d', varnum); newnames{nno}; ' '; '-1'; '-1'; };
                mheadr
            end
            no = no+1;
        end
    end
end

if isfield(nu, abbrev)
    name = nu.(abbrev).name; newunit = nu.(abbrev).unit;
    h = m_read_header(otfile);
    for nno = 1:length(name)
        if sum(strcmp(name{nno}, h.fldnam))
            warning(['changing units of ' name ' to ' newunit{nno}]);
            MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; name{nno}; ' '; newunit{nno}; '-1'; '-1'};
            mheadr
        end
    end
end