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
    stn = kloop; mctd_04;
    
    if MEXEC_G.ix_ladcp
        mout_1hzasc(stnlocal);
    end
    
    infile2 = fullfile(root_ctd, ['fir_' mcruise '_' stn_string]);
    if exist(m_add_nc(infile2),'file') ~= 2
        warning('File %s not found, skipping',m_add_nc(infile2))
        continue
    end
    stn = kloop; mfir_03;
    stn = kloop; mfir_03_extra;
    stn = kloop; mfir_to_sam;

    %calculate and apply depths
    station_summary(stnlocal)
    stn = stnlocal; mdep_01
    
end

%output to csv files
mout_cchdo_exchangeform(klistl)

%and sync
opt1 = 'batchactions'; opt2 = 'output_for_others'; get_cropt
