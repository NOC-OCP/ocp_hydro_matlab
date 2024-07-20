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

    stn = kloop; mctd_02(stn)

    stn = kloop; mctd_03(stn);
    stn = kloop; mctd_04(stn);
    
    if MEXEC_G.ix_ladcp
        mout_1hzasc(stn);
    end
    
    infile2 = fullfile(root_ctd, sprintf('fir_%s_%03d',mcruise,stn));
    if exist(m_add_nc(infile2),'file') ~= 2
        warning('File %s not found, skipping',m_add_nc(infile2))
        continue
    end
    stn = kloop; mfir_03(stn);
    %stn = kloop; mfir_03_extra;
    stn = kloop; mfir_to_sam(stn);

    %calculate and apply depths
    station_summary(stn)
%     stn = stnlocal; mdep_01
    
end
msbe35_01(max(klistl)) %read sbe35 data, if not already done up 

%output to csv files
mout_cchdo_exchangeform(klistl)

%and sync
opt1 = 'batchactions'; opt2 = 'output_for_others'; get_cropt
