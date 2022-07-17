%scripts to rerun after editing using mctd_rawedit, or if calibration is
%changed

root_ctd = mgetdir('M_CTD');

if ~exist('klist','var')
    if ~exist('stn','var') %prompt
        stn = input('type stn number: ');
    end
    klist = stn; clear stn
else
disp('Will process stations in klist: ')
disp(klist)
end
klistl = klist(:)'; clear klist

for kloop = klistl

    stn = kloop; mctd_02

    stn = kloop; mctd_03;
    if MEXEC_G.ix_ladcp
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
   
    %output to csv files
    stn = stnlocal; mout_exch_ctd
    
end
mout_exch_sam

%and sync
scriptname = 'batchactions'; oopt = 'output_for_others'; get_cropt


