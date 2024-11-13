switch opt1

    case 'mstar'
        docf = 1;

    case 'ctd_proc'
        switch opt2
            case 'redoctm'
                redoctm = 0; %start from _align_CTM
            case 'cnvfilename'
                cnvfile = fullfile(cdir, sprintf('%s_CTD%03d_align_CTM.cnv',upper(mcruise),stn));
            case 'track_serials'
                sa = {'t090C' 't190C'; 'c0mS/cm' 'c1mS/cm'; 'sbeox0Mm/L' 'sbeox1Mm/L'};
            case 'ctdvars'
                ctdvarmap = [ctdvarmap;...
                    {'sbeox0Mm_slash_L','oxygen_sbe1','umol/L'};...
                    {'sbeox1Mm_slash_L','oxygen_sbe2','umol/L'};...
                    ];
            case 'raw_corrs'
                co.dooxyhyst = 0; %already done
            case 'oxy_align'
                oxyunit = 'umol/l';
            case 'ctd_cals'
                co.docal.cond = 1;
                co.docal.oxygen = 1;
                co.calstr.cond.pl1.jc260 = 'dcal.cond = d0.cond.*(1+interp1([0 800 1500 4500],[.0028 .0027 .002 .0047],d0.press)/35);';
                co.calstr.cond.pl1.msg = 'bottle salinity comparison and CTD1-CTD2 comparison';
                co.calstr.cond.pl2.jc260 = 'dcal.cond = d0.cond.*(1+interp1([0 800 1500 4500],[.0022 .0027 .0021 .0028],d0.press)/35);';
                co.calstr.cond.pl2.msg = 'bottle salinity comparison and CTD1-CTD2 comparison';
                co.calstr.oxygen.pl1.jc260 = 'dcal.oxygen = d0.oxygen.*(interp1([0 4020],[1.024 1.062],d0.press));';
                co.calstr.oxygen.pl1.msg = 'bottle oxygen comparison';
                co.calstr.oxygen.pl2.jc260 = 'dcal.oxygen = d0.oxygen.*(interp1([0 4020],[1.026 1.068],d0.press));';
                co.calstr.oxygen.pl2.msg = 'bottle oxygen comparison';
        end

    case 'nisk_proc'
        switch opt2
            case 'blfilename'
                blinfile = fullfile(mgetdir('M_CTD_CNV'),sprintf('%s_CTD%03d.btl', upper(mcruise), stn));
        end

    case 'setup'
        switch opt2
            case 'time_origin'
                MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN = [2023 1 1 0 0 0];
            case 'setup_datatypes'
                use_ix_ladcp = 'no';
            case 'mdirlist'
                MEXEC_G.MDIRLIST{strcmp('M_CTD_CNV',MEXEC_G.MDIRLIST(:,1)),2} = 'CTD_Processed';
                MEXEC_G.MDIRLIST{strcmp('M_CTD',MEXEC_G.MDIRLIST(:,1)),2} = 'Proc_At_NOC';
                MEXEC_G.MDIRLIST{strcmp('M_SAM',MEXEC_G.MDIRLIST(:,1)),2} = 'Proc_At_NOC';
                MEXEC_G.MDIRLIST{strcmp('M_BOT_OXY',MEXEC_G.MDIRLIST(:,1)),2} = 'DO_data';
                MEXEC_G.MDIRLIST{strcmp('M_BOT_SAL',MEXEC_G.MDIRLIST(:,1)),2} = 'Autosal_Data';

        end

    case 'botpsal'
        switch opt2
            case 'sal_files'
                salfiles = dir(fullfile(root_sal,'JC260*.csv'));
            case 'sal_parse'
                cellT = 27;
                ssw_k15 = 0.99988;
                ssw_batch = 'P167';
            case 'sal_calc'
                 salin_off = 1e-5; %constant
            case 'sal_flags'
                % m = ismember(ds_sal.sampnum,[1403 1406 1408 1501]);
                % ds_sal.flag(m) = 4;
        end

    case 'botoxy'
        switch opt2
            case 'oxy_files'
                ofiles = dir(fullfile(root_oxy,'JC260_oxy_2*.xlsx'));
                %hcpat = {'Niskin';'Bottle'};
                %chrows = 1:2;
                %chunits = 3;
                hcpat = {'Bottle';'Number'}; %Flag is on 2nd line so start here
                chrows = 1;
                chunits = 2;
            case 'oxy_parse'
                calcoxy = 1;
                labT = [];
                varmap.statnum = {'number'};
                varmap.position = {'bottle_number'};
                varmap.vol_blank = {'titre_mls'};
                varmap.vol_std = {'vol_mls'};
                varmap.vol_titre_std = {'titre_mls_1'};
                varmap.fix_temp = {'temp_c'};
                varmap.bot_vol_tfix = {'at_tfix_mls'};
                varmap.sample_titre = {'titre_mls_2'};
            case 'oxy_flags'
                d.botoxya_flag(d.sampnum==417) = 4;
        end

    case 'outputs'
        out.type = 'mstar';
        out.time_units = 'days since 2023-01-01';
        out.header = {'processed using ocp_hydro_matlab branch jc260';...
            'calibrated CTD salinity and oxygen;'; ...
            'CTD1 (temp1 cond1 oxygen1) is preferred and has been copied to (temp cond oxygen)'};
                in.type = 'ctd';
        out.csvpre = fullfile(mgetdir('M_CTD'),'csv_files','jc260_CTD_data_calibrated_');
        in.type = 'ctd';
        status = mout_csv(in,out);
        out.header = [out.header; 
            'bot stands for bottle sample. '; ...
            'potemp = potential temperature. psal = practical salinity.'];
        in.type = 'sam';
        out.csvpre = fullfile(mgetdir('M_CTD'),'csv_files','jc260_Niskin_data_calibrated');
        status = mout_csv(in,out);

end

