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
                ofiles = dir(fullfile(root_oxy,'DY180_oxy_CTD*.xls'));
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

