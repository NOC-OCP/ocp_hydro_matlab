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
            mutv = mrdefine;

            %for writing
            opt1 = 'uway_proc'; opt2 = 'rvdas_database'; get_cropt
            header = {sprintf('RVDAS info from database %s and .json files in %s',RVDAS.database,RVDAS.jsondir);...
                sprintf('loaded by mrdefine.m on %s',datestr(now));...
                sprintf('saved in %s and %s', tabledefmat, tabledefcsv);...
                sprintf('csv copy only for information (.mat used by mrdefine)');...
                };


        case 'scs_ascii'
            %used to set MEXEC_G.MDIRLIST
            mutv = {'seapath','nav','pos','Seapath*.Raw';...
                'simrad','nav','pos','Simrad*.Raw';...
                'mru','nav','att','MRU*.Raw';...
                'gyro','nav','head','Gyro*.Raw';...
                'es18','bathy','sbm','*ES18*.XYZ';...
                'es38','bathy','sbm','*ES38*.XYZ';...
                'em2040','bathy','mbm','*EM2040*.XYZ';...
                'em340','bathy','mbm','*EM340*.XYZ';...
                'fluor','ocean','tsg','Fluorometer*.Raw';...
                'sbe21','ocean','tsg','SBE21*.Raw';...
                'smartguard','ocean','tsg','SooGuard*.Raw';...
                'windtrue','met','wind','Gill-WindDir*.Raw';...
                'met','met','met','CR6*.Raw';...
                };
            mutv = cell2table(mutv,'VariableNames',{'mstarpre','mstardir','paramtype','scsfilepat'});
            header = {' '};

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
