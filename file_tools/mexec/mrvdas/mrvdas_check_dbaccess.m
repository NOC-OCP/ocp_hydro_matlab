function mrvdas_check_dbaccess(RVDAS)

global MEXEC_G

hasc = 0;

%first try file with postgresql:// address(es)
if isfield(RVDAS,'loginfile') && exist(RVDAS.loginfile,'file')
    fid = fopen(RVDAS.loginfile,'r');
    c = textscan(fid,'%s\n'); c = c{1};
    fclose(fid);
    while hasc==0 && ~isempty(c)
        if contains(c{1},RVDAS.database(2:end-1)) && contains(c{1},'postgresql')
            hasc = 1; MEXEC_G.RVDAS_checked = c{1};
            ii1 = findstr(c{1},'@');
            ii2 = [findstr(c{1},':') findstr(c{1},'/')];
            ii2 = ii2(ii2>ii1); ii2 = min(ii2);
            RVDAS.machine = c{1}(ii1+1:ii2-1);
        else
            c(1) = [];
        end
    end
end

%if no loginfile, or this cruise not found in is, try user's .pgpass
if ~hasc
    if isfield(RVDAS,'machine') && isfield(RVDAS,'user')
        [stat, result] = system('ls -l ~/.pgpass');
        if stat==0 && strcmp(result(5:10),'------')
            fid = fopen('~/.pgpass','r');
            while fid>0
                tline = fgetl(fid);
                if isempty(tline)
                    fclose(fid); fid = -2;
                elseif contains(tline,RVDAS.machine) && contains(tline,RVDAS.database(2:end-1)) && contains(tline,RVDAS.user)
                    MEXEC_G.RVDAS_checked = 1;
                    fclose(fid); fid = -2;
                end
            end
        end
    end
end

if ~isfield(MEXEC_G,'RVDAS_checked') || isempty(MEXEC_G.RVDAS_checked)
    error('found no credentials for RVDAS server for this cruise')
else
    %try connecting
    [stat, ~] = system(['ping ' RVDAS.machine ' -c 1']);
    if stat~=0
        [stat, ~] = system(['ping ' RVDAS.machine ' -c 10']);
        if stat~=0
            MEXEC_G.RVDAS_checked = 0;
            error('%s not responding, cannot access RVDAS database', RVDAS.machine);
        end
    end
end
