%scripts to rerun after editing using mctd_rawedit, or if calibration is
%changed

ssd0 = MEXEC_G.ssd; MEXEC_G.ssd = 1;

root_ctd = mgetdir('M_CTD');

if ~exist('klist','var')
    if ~exist('stn','var') %prompt
        stn = input('type stn number: ');
    end
    klist = stn;
else
disp('Will process stations in klist: ')
disp(klist)
end
klist = klist(:)';

for kloop = klist

    stn = kloop; mctd_02

    stn = kloop; mctd_03;
    if MEXEC_G.ix_ladcp==1
        mout_1hzasc(stnlocal);
    end
    stn = kloop; mctd_04;
    
    infile2 = fullfile(root_ctd, ['fir_' mcruise '_' stn_string]);
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
MEXEC_G.ssd = ssd0;

