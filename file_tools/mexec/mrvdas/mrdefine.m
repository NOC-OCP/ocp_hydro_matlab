function mrtv = mrdefine(varargin)
% function mrtv = mrdefine
% function mrtv = mrdefine('redo')
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
%
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Create definitions for mexec processing of rvdas data
%
% Examples
%
%   mrtv = mrdefine
% loads existing (previously defined) table
%
%   mrtv = mrdefine('redo')
% queries database and json files to redefine the table, and save
%

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
%save to readable (and git-friendly) .csv
tabledefcsv = fullfile(fileparts(mfilename('fullpath')),['rvtabledef_' mcruise '.csv']);
%but it doesn't load back in the same way, so also save as .mat
tabledefmat = fullfile(MEXEC_G.mexec_data_root,'rvdas',['rvtabledef_' mcruise '.mat']);

if nargin>0 && strcmp(varargin{1},'redo')

    quiet = 1; if nargin>1; quiet = varargin{2}; end

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
    mrtv = mrdef_rename_varsunits(mrtables_use);

    opt1 = 'ship'; opt2 = 'rvdas_database'; get_cropt
    header = {sprintf('RVDAS info from database %s and .json files in %s',RVDAS.database,RVDAS.jsondir);...
        sprintf('loaded by mrdefine.m on %s',datestr(now));...
        sprintf('saved in %s and %s', tabledefmat, tabledefcsv);...
        sprintf('csv copy only for information (.mat used by mrdefine)');...
        };
    fid = fopen(tabledefcsv,'w');
    fprintf(fid, '%s\n', header{:}); fprintf(fid, '\n');
    fprintf(fid, '%s', mrtv.Properties.VariableNames{1});
    fprintf(fid, ', %s', mrtv.Properties.VariableNames{2:end});
    fprintf(fid, '\n');
    fclose(fid);
    writetable(mrtv, tabledefcsv, 'Delimiter', ',', 'WriteMode', 'append');
    save(tabledefmat, 'mrtv', 'header')

else

    df = dir(tabledefmat);
    if isempty(df)
        fprintf(2,'no %s found; try running with input argument ''redo''\n',tabledefmat)
    else
        if ~isfield(MEXEC_G,'mrvdas_update_warning') || (now-MEXEC_G.mrvdas_update_warning)>1
            fprintf(1,'loading %s last saved on %s\n',tabledefmat,df.date)
            MEXEC_G.mrvdas_update_warning = now;
        end
        load(tabledefmat,'mrtv')
    end

end

%***write something to parse .csv file correctly later? .mat is kept with
%the backup of the raw data though
