%script called by set_mexec_defaults (which is called by get_cropt in msam_load, moxy_)01, etc.)
%
%should make this group-specific

clear varmap

switch samtyp

    case 'chl'
        %no established defaults?

    case 'oxy'
        calcoxy = 1; %calculate from titre vol etc.
        %rename variables (if necessary)
        varmap.statnum = {'cast_number'};
        varmap.position = {'niskin_bottle'};
        varmap.conc_o2 = {'c_o2_','c_o2'};
        varmap.vol_blank = {'blank_titre'};
        varmap.vol_std = {'std_vol'};
        varmap.vol_titre_std = {'standard_titre'};
        varmap.fix_temp = {'fixing_temp'};
        varmap.oxy_bottle = {'bottle no'};
        %varmap.sample_titre = {'sample_titre'};
        varmap.date_titre = {'dnum'}; %***
        varmap.bot_vol_tfix = {'botvol_at_tfix'};
        keepothervars = 0; %after renaming, remove anything without an entry in varmap***

    case 'nut'
        %parse to get sampnum, set flags, and change variable names
        varmap.statnum = {'cast_number'};
        varmap.position = {'niskin_bottle'};
        varmap.totnit_per_l = {'nitrate_plus_nit','no3_plus_no2'};
        varmap.nitrite_per_l = {'nitrite','no2'};
        varmap.nitrate_per_l = {'nitrate','no3'};
        varmap.silc_per_l = {'silicate'};
        varmap.phos_per_l = {'phosphate'};
        varmap.amon_per_l = {'ammonium'};
        varmap.totnit_flag = {'flag'};
        varmap.nitrate_flag = {'flag'};
        varmap.nitrite_flag = {'flag'};
        varmap.silc_flag = {'flag'};
        varmap.phos_flag = {'flag'};
        varmap.amon_flag = {'flag'};
        keepothervars = 0; %after renaming, remove anything without an entry in varmap

    case 'sal'
        calcsal = 1; %calculate from cond ratio and temperature
        keepothervars = 1; %keep original names by default

end

