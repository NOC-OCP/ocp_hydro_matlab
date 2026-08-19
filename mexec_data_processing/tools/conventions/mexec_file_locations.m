function varargout = mexec_file_locations(step, varargin)
%
% mexec_file_locations('mdirlist')
%
% mexec_file_locations('procfiles',type)
% where type is one of 
% 'ctd', 'fir', 'dcs', 'win', 'sadcp', 'ladcp'
%
% mexec_file_locations('procfiles','sadcp',inst,cast_select)
%
% mexec_file_locations('procfiles','samp',samtyp)
% where samtyp is one of oxy, sal, nut, co2, cfc, pig, iso, log

m_common

switch step
    case 'mdirlist'
        dirs = {
            'M_CTD' 'ctd'
            'M_CTD_CNV' fullfile('ctd','ASCII_FILES')
            'M_CTD_BOT' fullfile('ctd','ASCII_FILES')
            'M_CTD_WIN' fullfile('ctd','WINCH')
            'M_CTD_DEP' 'station_information'
            'M_BOT'     'bottle_samples'
            'M_BOT_SAL' fullfile('bottle_samples','SAL')
            'M_BOT_OXY' fullfile('bottle_samples','OXY')
            'M_BOT_NUT' fullfile('bottle_samples','NUT')
            'M_BOT_PIG' fullfile('bottle_samples','PIG')
            'M_BOT_CO2' fullfile('bottle_samples','CO2')
            'M_BOT_CFC' fullfile('bottle_samples','CFC')
            'M_BOT_CH4' fullfile('bottle_samples','CH4')
            'M_BOT_CHL' fullfile('bottle_samples','PIG')
            'M_BOT_ISO' fullfile('bottle_samples','LOGS')
            'M_SAM' 'ctd'
            'M_SBE35' fullfile('ctd','ASCII_FILES','SBE35')
            'M_SUM' 'collected_files'
            'M_VMADCP' 'vmadcp'
            'M_NAV' 'nav'
            'M_SURFMET' 'surfmet'
            'M_BATHY' 'bathy'
            }; %***change how MDIRLIST is used?
        if ~strcmp(MEXEC_G.Mshipdatasystem,'auto')
            dirs = [dirs;
                {'M_UWAY_RAW' fullfile(MEXEC_G.Mshipdatasystem,'raw_local')}];
            mutv = mudefine;
            if exist('mutv','var')
                dirs = [dirs; ...
                    [cellfun(@(x) ['M_' upper(x)], mutv.mstarpre, 'UniformOutput', false), ...
                    mutv.mstardir]];
                [~,ii] = unique(dirs(:,1),'stable');
                dirs = dirs(ii,:);
            end
        end
        if strcmp(MEXEC_G.datatypes.ladcp,'ix')
            dirs = [dirs;
                {'M_LADCP' 'ladcp'
                'M_IX' fullfile('ladcp','ix')}];
        end
        dirs(:,2) = cellfun(@(x) fullfile(MEXEC_G.mexec_data_root,x),dirs(:,2),'UniformOutput',false);
        MEXEC_G.MDIRLIST = cell2struct(dirs(:,2),dirs(:,1));
        varargout{1} = 'directories in global MEXEC_G';

    case 'procfiles'
        %.nc files for different processing stages
        type = varargin{1};

        switch type
            case 'ctd'
                pd.ctdname = ['ctd_' mcruise '_%s'];
                pd.ctdraw = fullfile(MEXEC_G.MDIRLIST.M_CTD, [pd.ctdname '_cnv.nc']);
                pd.ctdclean = fullfile(MEXEC_G.MDIRLIST.M_CTD, [pd.ctdname '_cleaned.nc']);
                pd.ctd24 = fullfile(MEXEC_G.MDIRLIST.M_CTD, [pd.ctdname '_24hz.nc']);
                pd.ctd1 = fullfile(MEXEC_G.MDIRLIST.M_CTD, [pd.ctdname '_1hz.nc']);
                pd.ctd10s = fullfile(MEXEC_G.MDIRLIST.M_CTD, [pd.ctdname '_10s.nc']);
                pd.ctd2d = fullfile(MEXEC_G.MDIRLIST.M_CTD, [pd.ctdname '_2db.nc']);
                pd.ctd2u = fullfile(MEXEC_G.MDIRLIST.M_CTD, [pd.ctdname '_2up.nc']);
                pd.edctd24 = fullfile(MEXEC_G.MDIRLIST.M_CTD,'editlogs','ctd_%s_editpoints');
                pd.sbe35name = ['sbe35_' mcruise '_all'];
                pd.sbe35 = fullfile(MEXEC_G.MDIRLIST.M_SBE35, [pd.sbe35name '.nc']);
                pd.svel = fullfile(MEXEC_G.MDIRLIST.M_BATHY, 'svel_for_echosounders', [pd.ctdname '_10s_down_svel.csv']);
                %pd.asc_forladcp_1hz
            case 'fir'
                pd.firname = ['fir_' mcruise '_%s'];
                pd.firfile = fullfile(MEXEC_G.MDIRLIST.M_CTD, [pd.firname '.nc']);
            case 'dcs'
                pd.dcsname = ['dcs_' mcruise '_%s'];
                pd.dcsfile = fullfile(MEXEC_G.MDIRLIST.M_CTD, [pd.dcsname '.nc']);
            case 'win'
                pd.winname = ['win_' mcruise '_%s'];
                pd.winfile = fullfile(MEXEC_G.MDIRLIST.M_CTD_WIN, [pd.winname '.nc']);
            case 'samp'
                pd.samc = fullfile(MEXEC_G.MDIRLIST.M_BOT,['nisksamp_' mcruise '_all.nc']);
                pd.samu = fullfile(MEXEC_G.MDIRLIST.M_BOT,['ucswsamp_' mcruise '_all.nc']);
                if nargin>2
                    pd.([varargin{2} 'name']) = [varargin{2} '_' mcruise '_all'];
                    pd.([varargin{2}]) = fullfile(MEXEC_G.MDIRLIST.(['M_BOT_' upper(varargin{2})]),[pd.([varargin{2} 'name']) '.nc']);
                end
            case 'sadcp'
                if nargin>2
                    pd.sadcpname = [varargin{2} '_' mcruise '_' varargin{3} '_%s'];
                    pd.sadcpav = fullfile(MEXEC_G.MDIRLIST.M_VMADCP, 'mproc', [pd.sadcpname '_ave.nc']);
                end
                pd.sadcpall = fullfile(MEXEC_G.MDIRLIST.VMADCP, 'postprocessing', upper(mcruise), 'proc_editing', varargin{2}, 'contour', [pd.sadcpname '.nc']);
            case 'uway'
                pd.bunav = fullfile(MEXEC_G.MDIRLIST.M_NAV,['bestnav_' mcruise '_all.nc']);
                pd.buocean = fullfile(MEXEC_G.MDIRLIST.M_SURFMET,['surface_ocean_' mcruise '_all.nc']);
                pd.buatmos = fullfile(MEXEC_G.MDIRLIST.M_SURFMET,['atmos_truwind_' mcruise '_all.nc']);
                pd.bubathy = fullfile(MEXEC_G.MDIRLIST.M_BATHY,['bathy_' mcruise '_all.nc']);
            case 'sumout'
                pd.collected = fullfile(MEXEC_G.mexec_data_root,'collected_files');
        end

        switch type
            case {'samp','ctd'}
                pd.sg = fullfile(MEXEC_G.MDIRLIST.M_CTD,'sensor_groups.mat'); %generated by get_sensor_groups, contains groups of sensors by serial number, sg, sng
                pd.sum = fullfile(MEXEC_G.MDIRLIST.M_SUM,['station_summary_' mcruise '_all.nc']);
        end

        varargout{1} = pd;

end

