function mutv = mudefine(varargin)
% function mutv = mudefine
% function mutv = mudefine('redo')
%
% define or load a table mapping underway data streams to mexec names and files
% used by functions called by uway_process.m
%
%   mutv = mudefine
%       loads existing (previously defined) table stored in ***
%
%   mutv = mudefine('redo')
%       queries (depending on underway data system type) data files/header
%       files/database/json files/metadatabase to redefine the table, and
%       save in ***
%
% currently contains code for rvdas,
% will have scs_nmea
% scs_nc
% techsas
% scs

m_common
%definitions will be saved to readable (and git-friendly) .csv
tabledefcsv = fullfile(fileparts(mfilename('fullpath')),['utabledef_' mcruise '.csv']);
%but it doesn't load back in the same way, so they are also saved as .mat
tabledefmat = fullfile(MEXEC_G.mexec_data_root,MEXEC_G.Mshipdatasystem,['utabledef_' mcruise '.mat']);

if nargin>0 && strcmp(varargin{1},'redo')

    quiet = 1; if nargin>1; quiet = varargin{2}; end

    switch MEXEC_G.Mshipdatasystem
        case 'rvdas'
            % mexec interface for RVDAS data acquisition
            % First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
            %
            % Evolution on that cruise by bak, ylf, pa
            % *************************************************************************
            %
            % Create definitions for mexec processing of rvdas data

            % Identify rvdas tables present in database
            mrtables = mrgetrvdascontents(quiet);
            % Limit to the tables and variables we want to load, add mstar names
            limit = [1 1];
            mrtables_use = mrdef_mstarnames(mrtables, limit);
            % Check .json files for information on units
            mrtables_use = mrdef_json(mrtables_use);
            % get a list of variables for which we want to change names when loaded
            % into mexec, and a list of tables whose variables should have _raw
            % appended
            mutv = mrdef_rename_varsunits(mrtables_use);
            %for writing
            opt1 = 'ship'; opt2 = 'rvdas_database'; get_cropt
            header = {sprintf('RVDAS info from database %s and .json files in %s',RVDAS.database,RVDAS.jsondir);...
                sprintf('loaded by mrdefine.m on %s',datestr(now));...
                sprintf('saved in %s and %s', tabledefmat, tabledefcsv);...
                sprintf('csv copy only for information (.mat used by mrdefine)');...
                };

        case 'scs_nmea'
            f = dir('MEXEC_G.MDIRLIST.M_UWAY_RAW/*.Raw');
            for no = 1:length(f)
                if strncmp(f,'USBL',4); continue; end
                if contains(f{no}.name,'GGA')
                    cols = {'date','time','msg','timestamp','latgga','latdir','longga','londir','ggaqual','sats','hdop','alt','altval','geosep','geoval','dgpsage','dgpsref_checksum'};
                elseif contains(f{no}.name,'HDT') %THS replaces this?
                    cols = {'date','time','msg','head (relative to true north)','checksum'};
                elseif contains(f{no}.name,'HDG')
                    cols = {'date','time','msg','degrees (magnetic)','deviation (degrees magnetic)','devdir (E/W)','variation (degrees magnetic)','vardir (E/W)','checksum'};
                elseif contains(f{no}.name,'ROT') %GPhve, GPatt
                    cols = {'date','time','msg','rate of turn (degrees/minute)'}
                elseif contains(f{no}.name,'VTG')
                    cols = {'date','time','msg','tmg (degrees true)','T','tmgm (degrees magnetic)','M','speed (kt)','N','sog (kph)','K','mode (A autonomous D differential E estimated M manual S simulator N not valid)'};
                elseif contains(f{no}.name,'ZDA')
                    cols = {'date','time','msg','utc','day','month','year','tzoffhrs','tzoffmins','checksum'};
                elseif contains(f{no}.name,'GLL')
                    cols = {'date','time','msg','lat (dd mm,mmmm)','latdir','lon (ddd mm,mmmm)','londir','utc (hhmmss.ss)','status (A valid V not valid)','checksum'};
                elseif contains(f{no}.name,'DBT')
                    cols = {'date','time','msg','depthft','feet','depth_below_transducer (m)','metres','depthfa','fathoms','checksum'};
                elseif contains(f{no}.name,'DBS')
                    cols = {'date','time','msg','depthft','feet','depth_below_surface (m)','metres','depthfa','fathoms','checksum'};
                elseif contains(f{no}.name,'DPT')
                    cols = {'date','time','msg','depth_below_transducer (m)','offset relative to transducer (metres)','max_range_scale','checksum'};
                elseif contains(f{no}.name,'VHW')
                    cols = {'date','time','msg','heading (nm)','T','heading (degrees magnetic)','M','speed relative to water (kt)'}
                end %VBW 
            end
            %bathy xyz files?***
    end

    %write to .csv file
    fid = fopen(tabledefcsv,'w');
    fprintf(fid, '%s\n', header{:}); fprintf(fid, '\n');
    fprintf(fid, '%s', mutv.Properties.VariableNames{1});
    fprintf(fid, ', %s', mutv.Properties.VariableNames{2:end});
    fprintf(fid, '\n');
    fclose(fid);
    writetable(mutv, tabledefcsv, 'Delimiter', ',', 'WriteMode', 'append');
    %save to .mat file
    save(tabledefmat, 'mutv', 'header')

else

    df = dir(tabledefmat);
    if isempty(df)
        fprintf(2,'no %s found; try running with input argument ''redo''\n',tabledefmat)
    else
        fprintf(1,'loading %s last saved on %s\n',tabledefmat,df.date)
        load(tabledefmat,'mutv')
    end

end

%***write something to parse .csv file correctly later? .mat is kept with
%the backup of the raw data though
