%scripts to rerun after editing using mctd_rawedit, or if calibration is
%changed
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

root_ctd = mgetdir('M_CTD');

if ~exist('klist','var')
    if ~exist('stn','var') %prompt
        minit
    end
    klist = stn;
else
disp('Will process stations in klist: ')
disp(klist)
end
klist = klist(:)';

for kloop = klist
    stn = kloop; minit
    
    infile1 = [root_ctd '/ctd_' mcruise '_' stn_string '_raw'];
    if exist(m_add_nc(infile1),'file') ~= 2
        mess = ['File ' m_add_nc(infile1) ' not found'];
        fprintf(MEXEC_A.Mfider,'%s\n',mess)
        continue
    end
    stn = kloop; mctd_02b

    stn = kloop; mctd_03;
    mout_1hzasc(stnlocal);
    stn = kloop; mctd_04;
    
    infile2 = [root_ctd '/fir_' mcruise '_' stn_string];
    if exist(m_add_nc(infile2),'file') ~= 2
        mess = ['File ' m_add_nc(infile2) ' not found'];
        fprintf(MEXEC_A.Mfider,'%s\n',mess)
        continue
    end
    stn = kloop; mfir_03;
    stn = kloop; mfir_to_sam;
    
    scriptname = 'batchactions'; oopt = 'ctd'; get_cropt
    
end

scriptname = 'batchactions'; oopt = 'sam'; get_cropt
scriptname = 'batchactions'; oopt = 'syncc'; get_cropt
clear klist*
