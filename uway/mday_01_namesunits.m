%script containing code from previous version of mday_01_clean_av to rename
%variables and convert (or rename) some units for scs and techsas streams
%(for rvdas variable renaming is done at an earlier stage)

%%%%% change variable names (calling mheadr) %%%%%
%fields of nn are mexec short names (abbrev) for which some change to names
%is required, and nu is the same for changing units
%if multiple changes are required in one file (for different variables)
%expand row dimension of cell arrays
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
        %if strcmp(MEXEC_G.Mshipdatasystem, 'techsas')
        %    nu.met.name = {'speed'}; nu.met.unit = {'m/s'};
        %    %asf note: techsas records m/s, however, the SSDS displays values converted to knots. There is no separate record of this since SSDS is live, so all wind records should be in m/s and no conversions are needed.
        %end
    case 'rvdas'
        nn.em120.new = {'swath_depth'}; nn.em120.old = {'waterdepthmeter'};
        nn.ea600.new = {'depth_uncor'}; nn.ea600.old = {'waterdepthmeterfromsurface'};
end

if isfield(nn, abbrev)
    newnames = nn.(abbrev).new; oldnames = nn(abbrev).old;
    h = m_read_header(otfile);
    for nno = 1:size(newnames,1)
        no = 1;
        while ~sum(strcmp(newnames{nno}, h.fldnam)) & no<=length(oldnames(nno,:))
            varnum = find(strncmp(oldnames{nno,no}, h.fldnam, length(name)));
            if length(varnum)>0
                MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; sprintf('%d', varnum); newnames{nno}; ' '; '-1'; '-1'; };
                mheadr
            end
            no = no+1;
        end
    end
end

if isfield(nu, abbrev)
    name = nu.(abbrev).name; newunit = nu(abbrev).unit;
    h = m_read_header(otfile);
    for nno = 1:size(name,1)
        if sum(strcmp(name{nno}, h.fldnam))
            MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; name; ' '; newunit{nno}; '-1'; '-1'};
            mheadr
        end
    end
end