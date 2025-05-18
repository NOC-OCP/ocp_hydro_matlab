switch opt1

    case 'setup'
        switch opt2
            case 'setup_datatypes'
                MEXEC_G.ix_ladcp = 1;
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2024 1 1 0 0 0];
            case 'mdirlist'
                MEXEC_G.MDIRLIST{strcmp('M_BOT_SAL',MEXEC_G.MDIRLIST(:,1)),2} = fullfile('ctd','BOTTLE_SAL','AUTOSAL','Autosal Data');
                MEXEC_G.MDIRLIST = [MEXEC_G.MDIRLIST; {'M_LADCP' 'ladcp'}];
        end

    case 'ship'
        switch opt2
            case 'datasys_best'
                default_navstream = 'posmv_gpgga';
                default_hedstream = 'posmv_gphdt';
                default_attstream = 'posmv_pashr';
            case 'rvdas_database'
                RVDAS.machine = '192.168.65.51';
                %RVDAS.jsondir = '/data/pstar/mounts/mnt_cruise_data/Ship_Systems/Data/RVDAS/Sensorfiles/'; %original
                RVDAS.user = 'rvdas';
                RVDAS.database = ['"' upper(MEXEC_G.MSCRIPT_CRUISE_STRING) '"'];
        end

    case 'uway_proc'
        switch opt2
            case 'combine'
                infiles = {'met/met/surfmet_dy180_all_raw.nc';
                    'met/rad/surfmet_dy180_all_raw.nc';
                    'met/tsg/surfmet_dy180_all_raw_tsgonly.nc'};
                outfile = 'met/surfmet_dy180_all_raw.nc';
            case 'rawedit'
                ts = (datenum(2024,5,21,0,0,0)-datenum(2024,1,1))*86400;
                if strcmp(abbrev,'surfmet')
                    uopts.badtime.temph_raw = [-inf ts];
                    uopts.badtime.temp_remote_raw = [-inf ts];
                    uopts.badtime.conductivity_raw = [-inf ts];
                    uopts.badtime.salinity_raw = [-inf ts];
                    uopts.badtime.soundvelocity_raw = [-inf ts];
                    uopts.badtime.fluo = [-inf ts];
                    uopts.badtime.trans = [-inf ts];
                end
                if sum(strcmp(streamtype,{'sbm','mbm'}))
                    handedit = 1; %edit raw bathy
                    vars_to_ed = munderway_varname('depvar',h.fldnam,1,'s');
                    vars_to_ed = union(vars_to_ed,munderway_varname('depsrefvar',h.fldnam,1,'s'));
                    vars_to_ed = union(vars_to_ed,munderway_varname('deptrefvar',h.fldnam,1,'s'));
                end
                if strcmp(abbrev,'ea640')
                    d = rmfield(d,'waterdepthfromsurface');
                    h.fldunt(strcmp('waterdepthfromsurface',h.fldnam)) = [];
                    h.fldnam(strcmp('waterdepthfromsurface',h.fldnam)) = [];
                end
            case 'sensor_unit_conversions'
                switch abbrev
                    case 'surfmet'
                        so.docal.fluo = 1;
                        so.docal.trans = 1;
                        so.docal.parport = 1;
                        so.docal.parstarboard = 1;
                        so.docal.tirport = 1;
                        so.docal.tirstarboard = 1;
                        %specify calibration equation, calibrated units,
                        %and instrument-serial number with
                        %so.calstr.{variablename}.pl.{cruise},
                        %so.calunits.{variablename}, and
                        %so.instn.{variablename}
                        %e.g. so.calstr.fluo.pl.dy180, so.calunits.fluo,
                        %and so.instsn.fluo
                        so.calstr.fluo.pl.dy180 = 'dcal.fluo = 10.3*(d0.fluo-0.078);'; %or sf is nonlinear?***
                        so.instsn.fluo = 'WS3S134';
                        so.calunits.fluo = 'ug_per_l';
                        so.calstr.trans.pl.dy180 = 'dcal.trans = (d0.trans-0.017)/(4.699-0.017)*100;';
                        so.instsn.trans = 'CST-112R';
                        so.calunits.trans = 'percent';
                        so.calstr.parport.pl.dy180 = 'dcal.parport = d0.parport*(1e6/9.944);';
                        so.instsn.parport = 'SKE-510 28558';
                        so.calunits.parport = 'W_per_m2';
                        so.calstr.parstarboard.pl.dy180 = 'dcal.parstarboard = d0.parstarboard*(1e6/8.937);';
                        so.instsn.parstarboard = 'SKE-510 28561';
                        so.calunits.parstarboard = 'W_per_m2';
                        so.calstr.tirport.pl.dy180 = 'dcal.tirport = d0.tirport*(1e6/9.69);';
                        so.instsn.tirport = 'CMP-994133';
                        so.calunits.tirport = 'W_per_m2';
                        so.calstr.tirstarboard.pl.dy180 = 'dcal.tirstarboard = d0.tirstarboard*(1e6/11.31);';
                        so.instsn.tirstarboard = '994132';
                        so.calunits.tirstarboard = 'W_per_m2';
                end
            case 'tsg_cals'
                uo.docal.temp_remote = 1;
                uo.docal.salinity = 1;
                uo.docal.fluo = 0;
                uo.calstr.temp_remote.pl.dy180 = 'dcal.temp_remote = d0.temp_remote+(0.2855-2.7e-3*d0.dday);';
                uo.calstr.temp_remote.pl.msg = 'temperature offset by trend of smoothed differences from 51 3-m CTD temperatures';
                uo.calstr.salinity.pl.dy180 = 'dcal.salinity = d0.salinity+6e-4;';
                uo.calstr.salinity.pl.msg = 'salinity offset by median of smoothed differences from 53 3-m CTD salinities';
                %uo.calstr.fluo.pl.dy180 = 'dcal.fluo = d0.fluo*0.27;';
                %uo.calstr.fluo.pl.msg = 'fluorescence scaled by median of smoothed ratio to 26 night-time 3-m CTD fluorescence measurements';
            case 'avedit'
                switch datatype
                    case 'ocean'
                        %bad temp often associated with bad fluo and trans
                        uopts.badtemph.fluo = [NaN NaN];
                        uopts.badtemph.trans = [NaN NaN];
                        vars_to_ed = {'flow','fluo','trans','temph','temp_remote','salinity'};
                        vars_offset_scale.temph = [-11; 1];
                        vars_offset_scale.temp_remote = vars_offset_scale.temph;
                        vars_offset_scale.salinity = [-35; 2];
                        handedit = 0; %already done, switch off when running to apply calibration
                    case 'bathy'
                        vars_to_ed = {'waterdepth_mbm','waterdepth_sbm'};
                        %handedit = 0; %already done
                    case 'atmos'
                        vars_offset_scale.airtemperature = [-11; 1];
                        vars_to_ed = setdiff(vars_to_ed,{'truwind_spd'}); %missing data in the middle
                        %remove wind variables from combined file for now
                        m = cellfun(@(x) contains(x,'wind'),hg.fldnam);
                        dg = rmfield(dg,hg.fldnam(m));
                        hg.fldnam(m) = []; hg.fldunt(m) = []; 
                        if isfield(hg,'fldserial')
                            hg.fldserial(m) = [];
                        end
                        hg = rmfield(hg,{'alrlim','uprlim','absent','num_absent','dimsset','dimrows','dimcols','noflds'});
                        handedit = 0; %already done (not including wind)
                end
        end

    case 'castpars'
        switch opt2
            case 'minit'
                %Ti vs SS for stn_string? or don't need this because it's
                %sequential numbering and handled with cnvfilename? do need
                %it for e.g. vmadcp station av***
            case 's_choice'
                s_choice = 2; %fin sensor
            case 'o_choice'
                o_choice = 2; %fin sensor
                if ismember(stn,[2 5 10 16 20 25 33 37 43 47]) %Ti sensor 2 was swapped and in particular station 20 sensor 2 is problematic
                    o_choice = 1; %o2 (862) far offset on one profile, don't use
                end
        end

    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 1;
            case 'cnvfilename'
                cnvfile = fullfile(cdir,sprintf('%s_CTD%03dS.cnv',upper(mcruise),stn)); %try stainless first
                if ~exist(cnvfile,'file')
                    cnvfile = fullfile(cdir,sprintf('%s_CTD%03dT.cnv',upper(mcruise),stn)); %try Ti
                end
            case 'ctd_cals'
                co.docal.cond = 1;
                co.docal.oxygen = 1;
                co.calstr.cond.sn44065.dy180 = 'dcal.cond = d0.cond.*(1-0.005/35);';
                co.calstr.cond.sn44065.msg = 'calibration for cond 04c-4065 (cond1) based on up to 55 good samples (12 in low gradients) from 14 casts with stainless frame';
                co.calstr.cond.sn44138.dy180 = 'dcal.cond = d0.cond.*(1-0.008/35);';
                co.calstr.cond.sn44138.msg = 'calibration for cond 04c-4138 (cond2) based on up to 55 good samples (12 in low gradients) from 14 casts with stainless frame';
                co.calstr.oxygen.sn2722.dy180 = 'dcal.oxygen = d0.oxygen.*interp1([0 1100],[1 1.005],d0.press).*interp1([1 52],[1.05 1.07],d0.statnum);';
                co.calstr.oxygen.sn2722.msg = 'calibration for oxy 2722 (oxygen2) based on up to 245 good samples (169 in low gradients) from 26 casts with stainless frame';
                co.calstr.oxygen.sn431882.dy180 = 'dcal.oxygen = d0.oxygen.*interp1([0 1100],[1 1.005],d0.press).*interp1([1 52],[1.020 1.030],d0.statnum);'; %1.025
                co.calstr.oxygen.sn431882.msg = 'calibration for oxy 43-1882 (oxygen1) based on up to 245 good samples (169 in low gradients) from 26 casts with stainless frame';
                co.calstr.cond.sn42165.dy180 = 'dcal.cond = d0.cond.*(1-0.004/35);';
                co.calstr.cond.sn42165.msg = 'adjustment to cond 04c-2165 (cond1) based on comparison of 10 profiles with nearby profiles from calibrated stainless frame sensors (comparisons below 600 m and in surface mixed layer)';
                co.calstr.cond.sn43873.dy180 = 'dcal.cond = d0.cond.*(1-0.005/35);';
                co.calstr.cond.sn43873.msg = 'adjustment to cond 04c-3873 (cond2) based on comparison of 10 profiles with nearby profiles from calibrated stainless frame sensors (comparisons below 600 m and in surface mixed layer)';
                co.calstr.oxygen.sn430619.dy180 = 'dcal.oxygen = d0.oxygen.*1.025;';
                co.calstr.oxygen.sn430619.msg = 'adjustment to oxygen 43-0619 (oxygen1) based on comparison in theta-oxygen space with calibrated stainless frame sensors';
                if stn==20
                    co.calstr.oxygen.sn862.dy180 = 'dcal.oxygen = 1.15*(0.65*d0.oxygen-30)+2;';
                    co.calstr.oxygen.sn862.msg = 'oxygen 0862 on cast 20 first adjusted to match other 0862 oxygens (original coefficients may be wrong) then adjusted based on comparison in theta-oxygen space with calibrated stainless frame sensors';
                else
                    co.calstr.oxygen.sn862.dy180 = 'dcal.oxygen = 1.15*d0.oxygen+2;';
                    co.calstr.oxygen.sn862.msg = 'adjustment to oxygen 0862 (oxygen2) based on comparison of 6 profiles, in theta-oxygen space, with calibrated stainless frame sensors;';
                end
                co.calstr.oxygen.sn709.dy180 = 'dcal.oxygen = d0.oxygen*1.02+8;';
                co.calstr.oxygen.sn709.msg = 'adjustment to oxygen 0709 (oxygen 2) based on comparison of 4 profiles, in theta-oxygen space, with calibrated stainless frame sensors;';
            case 'rawedit_auto'
                if stnlocal==35
                    co.rangelim.press = [-1 8000];
                end
        end

    case 'nisk_proc'
        switch opt2
            case 'blfilename'
                blinfile = fullfile(root_botraw,sprintf('%s_CTD%03dS.bl', upper(mcruise), stn));
                if ~exist(blinfile,'file')
                    blinfile = fullfile(root_botraw,sprintf('%s_CTD%03dT.bl', upper(mcruise),stn));
                end
        end

    case 'ladcp_proc'
        if ismember(stnlocal,[38 39])
            cfg.dnpat = sprintf('%s_LADCP_CTD038M and 039M.000',upper(mcruise));
            cfg.uppat = sprintf('%s_LADCP_CTD038S and 039S.000',upper(mcruise));
        else
            cfg.dnpat = sprintf('%s_LADCP_CTD%03dM*.000',upper(mcruise),stnlocal);
            cfg.dnpat = sprintf('%s_LADCP_CTD%03dS*.000',upper(mcruise),stnlocal);
        end
        if contains(cfg.stnstr,'_')
            [dd,hd] = mloadq(fullfile(mgetdir('ctd'),sprintf('dcs_%s_%03d',mcruise,stnlocal)),'time_start time_end ');
            dd.dnum_start = m_commontime(dd,'time_start',hd,'datenum');
            dd.dnum_end = m_commontime(dd,'time_end',hd,'datenum');
            cfg.p.time_start_force = round(datevec(dd.dnum_start-2/60/24));
            cfg.p.time_end_force = round(datevec(dd.dnum_end+2/60/24));
        end
        if stnlocal==23
            isul = 0;
        end
        cfg.rawdir = fullfile(mgetdir('ladcp'),'rawdata');
        cfg.p.vlim = 4; %rather than ambiguity vel, match this to LV
        sfile = fullfile(spath, sprintf('os150nb_edited_xducerxy_%s_ctd_%03d_forladcp.mat',mcruise,stn)); %75kHz was bad much of the cruise
        SADCP_inst = 'os150nb';

    case 'samp_proc'
        switch opt2
            case 'files'
                switch samtyp
                    case 'chl'
                        files = {fullfile(root_in,'DY180_Chlorophyll a data_master.xlsx')};
                        sopts.DateLocale = "en_GB";
                    case 'oxy'
                        files = dir(fullfile(root_in,'DY180_oxy_CTD*.xls'));
                    case 'sal'
                        salfiles = dir(fullfile(root_sal,'DY180*.csv'));
                end
            case 'parse'
                switch samtyp
                    case 'chl'
                        %create cast from cast_number
                        ds.cast = nan(size(ds.cast_number));
                        mc = strncmp('CTD',ds.cast_number,3);
                        ds.cast(mc) = cellfun(@(x) str2double(extract(x,digitsPattern(1,3))), ds.cast_number(mc));
                        %times*** need to be added, only dates!
                        ddlim = datenum([2024 5 21; 2024 6 27])-datenum(2024,1,1);
                        ds.dday = datenum(ds.date_day_month_year)-datenum(2024,1,1);
                        ds = ds(ds.dday>=ddlim(1) & ds.dday<=ddlim(2),:);
                        %and temporarily (?) use dday to fill cast as in
                        %msal_01
                        ds.cast(isnan(ds.cast)) = -ds.dday(isnan(ds.cast))*1e2; %so sampnum will be ddd0000
                        %add flags based on notes
                        ds.flag = 2+zeros(size(ds,1),1);
                        ds.flag(cellfun(@(x) contains(x,["broken","assume","Wrong","Check"]),ds.notes)) = 3; %questionable
                        ds.flag(ds.chlorophyll_dil_x_r_adj_x_fl_bl_x_ace_per_sampl==0) = 5; %not reported
                        ds.flag(~isfinite(ds.chlorophyll_dil_x_r_adj_x_fl_bl_x_ace_per_sampl)) = 5; %not reported
                        %variables to rename (or to keep and write to file without renaming)
                        varmap.dday = {'dday'};
                        varmap.statnum = {'cast'};
                        varmap.position = {'niskin_bottle'};
                        varmap.chl = {'chlorophyll_dil_x_r_adj_x_fl_bl_x_ace_per_sampl'};
                        varmap.chl_flag = {'flag'};
                        varmap.chl_inst = {'fluorometer_id_816_or_black_1'};
                        keepothervars = 0;
                        addcomment = '\nchlorophyll units assumed';
                    case 'sal'
                        cellT = 21;
                        ssw_k15 = 0.99993;
                        ssw_batch = 'P168';
                    case 'oxy'
                        labT = [];
                        varmap.statnum = {'number'};
                        varmap.position = {'bottle_number'};
                        varmap.vol_blank = {'titre_mls'};
                        varmap.vol_std = {'vol_mls'};
                        varmap.vol_titre_std = {'titre_mls_1'};
                        varmap.fix_temp = {'temp_c'};
                        varmap.bot_vol_tfix = {'at_tfix_mls'};
                        varmap.sample_titre = {'titre_mls_2'};
                end
            case 'calc'
                switch samtyp
                    case 'sal'
                        salin_off = -1.5e-5; %constant
                end
            case 'check'
                %checksam.chl = 1;
                checksam.oxy = 1;
                checksam.sal = 0;
                checksam.sbe35 = 0;
            case 'flags' %flags before replicate averaging and after replicate averaging***
                switch samtyp
                    case 'sal'
                        % outliers in readings: 402 second low, 1205 third low,
                        % 2413 and 5209 second and third low and high, 5217 first
                        % low. none far enough out to discard. flag averages as 3?
                        % bad averaged samples (much farther off than could be
                        % explained by background gradients/variability):
                        m = ismember(ds_sal.sampnum,[1403 1406 1408 1501]);
                        ds_sal.flag(m) = 4;
                    case 'oxy'
                        %sampnum, a flag, b flag, c flag
                        flr = [1201 3 3 9; ...
                            2703 3 3 9; ...
                            2707 2 2 4; ...
                            3903 9 3 4; ...
                            3906 3 3 9; ...
                            4403 2 2 4; ...
                            5203 3 4 4; ... % to be further evaluated later
                            5223 2 2 2; ...
                            ];
                        [~,ifl,id] = intersect(flr(:,1),d.sampnum);
                        d.botoxya_flag(id) = max(d.botoxya_flag(id),flr(ifl,2));
                        d.botoxyb_flag(id) = max(d.botoxyb_flag(id),flr(ifl,3));
                        d.botoxyc_flag(id) = max(d.botoxyc_flag(id),flr(ifl,4));
                        % outliers relative to profile/CTD (not replicates)
                        flag4 = [1207 2716 2720 2722 2724 2705 3909 5206 5210 5214 5216 5218]';
                        d.botoxya_flag(ismember(d.sampnum,flag4)) = 4;
                        flag4b = [1501 2720]; %both a and b high, maybe bad niskin closure
                        d.botoxya_flag(ismember(d.sampnum,flag4b)) = 4;
                        d.botoxyb_flag(ismember(d.sampnum,flag4b)) = 4;
                end
        end

    case 'outputs'
        switch opt2
            case 'summary'
                snames = {'nsal' 'noxy' 'nnut' 'nco2'};
                sgrps = {{'botpsal'} {'botoxy'} {'silc' 'phos' 'nitr'} {'dic' 'talk'}};
            case 'ladcp'
                if stnlocal==38 || stnlocal==39
                    cfg.stnstr = '038_039';
                end
            case 'bodc'
                %skip par? or keep?
                %change siteID to the convention they're using
                %(CTsomething?)
                %how to include , in a field ([+N,-S] etc.)
                %add bottle chl
                %
                %out.vars_blank = units{strcmp('Water Depth',out.vars_units(:,1)),3} = 'fillval'; %no water depth info (reliable) at the moment*** don't know if casts were full-depth
                %vars_exclude = {'CTDSIG0';'BOTSIG0'}; %exclude these even if they do correspond to fields in sam file
            case 'exch'
                ns = 43; nt = 10;
                expocode = '74EQ20240522';
                sect_id = 'Bio-Carbon';
                submitter = 'OCPNOCYLF'; %group institution person
                common_headstr = {'#SHIP: RRS Discovery';...
                    '#Cruise DY180; Bio Carbon spring';...
                    '#Region: subpolar north Atlantic';...
                    ['#EXPOCODE: ' expocode];...
                    '#DATES: 20240522 - 20240628';...
                    '#Chief Scientist: S. Henson (NOC)';...
                    '#Supported by grants from the UK Natural Environment Research Council.'}; %***
                if strcmp(in.type,'ctd')
                    out.header = {['CTD,' datestr(now,'yyyymmdd') submitter]};
                    out.header = [out.header; common_headstr;
                        {sprintf('#%d stations with 24-place stainless-steel rosette',ns);...
                        sprintf('#%d stations with 24-place trace metal clean rosette',nt);...
                        '#CTD: Who - Y. Firing and T. Petit (NOC); Status - final.';...
                        '#The CTD PRS; TMP data are all good.';...
                        '#The CTD SAL; OXY data from stations 1 3 4 6-9 11-15 17-19 21-24 26-32 34-36 38-42 44-46 48-53 are all calibrated using bottle sample data and good.';...
                        '#The CTD SAL; OXY data from stations 2 5 10 16 20 25 33 37 43 47 are all calibrated by comparison with above stations and good.';...
                        '# DEPTH_TYPE   : COR';...
                        '# DEPTH_TYPE   : TBA';...
                        }];
                else
                    out.header = {['BOTTLE,' datestr(now,'yyyymmdd') submitter]};
                    out.header = [out.header; common_headstr;
                        {sprintf('#%d stations with 24-place stainless-steel rosette',ns);...
                        sprintf('#%d stations with 24-place trace metal clean rosette',nt);...
                        '#CTD: Who - Y. Firing and T. Petit (NOC); Status - final';...
                        '#Notes: Includes CTDSAL, CTDOXY, CTDTMP';...
                        '#The CTD PRS; TMP data are all good.';...
                        '#The CTD SAL; OXY data from stations 1 3 4 6-9 11-15 17-19 21-24 26-32 34-36 38-42 44-46 48-53 are all calibrated using bottle sample data and good.';...
                        '#The CTD SAL; OXY data from stations 2 5 10 16 20 25 33 37 43 47 are all calibrated by comparison with above stations and good.';...
                        '# DEPTH_TYPE   : TBA';...
                        '#Salinity: Who - Y. Firing (NOC); Status - final; SSW batch P168.';...
                        '#Oxygen: Who - E. Mawji (NOC); Status - final.';...
                        %'#Nutrients: Who - E. Mawji (NOC); Status - .';...
                        %'#DIC and Talk: Who - ??? (NOC); Status - .';...
                        %'#***';...
                        }];
                end
        end

end

