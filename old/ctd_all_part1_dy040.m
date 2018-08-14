scriptname = 'ctd_all_part1';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);

stnlocal = stn;

clear stn % so that it doesn't persist

mcd('M_CTD'); % change working directory

% notes added bak and ylf at start of jr306 jan 2015
% stn = stnlocal; msam_01; % also consider using msam_01b; see help notes in that script.
% % % % % to create a set of empty sam files at the start of the cruise, use for example
% % % % for kl = 1:30
% % % %     stn = kl; msam_01b % after making template as per instructions in msam_01b
% % % % end

%bak on dy040 15 dec 2015
% test to see if sam and dcs files exist for this station and create either of them if not

prefix1 = ['sam_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix2 = ['dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

mcd('M_SAM'); % change working directory

temfile1 = [prefix1 'template'];
samfile1 = [prefix1 stn_string];
if exist(m_add_nc(samfile1),'file') ~=2
    % sam file not present; create it
    if exist(m_add_nc(temfile1),'file') == 2
        stn = stnlocal; msam_01b; % use template if it exists because that is quicker
    else
        stn = stnlocal; msam_01;
    end
end

% end of extra code to create sam file if needed

% test to see if dcs file exists for this station and create it if not

mcd('M_CTD'); % change working directory

dcsfile1 = [prefix2 stn_string];
if exist(m_add_nc(dcsfile1),'file') ~=2
    % dcs file not present; create it
        stn = stnlocal; mdcs_01;
end

% end of extra code to create sdcsam file if needed

cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;



mcd('M_CTD'); % change working directory


switch cruise
    case 'dy040'
        switch stnlocal
            % actually, we could just apply cleanedit and scanedit on all noctm
            % stations; there will be no action where none is required by
            % those scripts. in dy040, soem scan edits are applied in
            % mctd_03; from now on, apply scan editing for pumps off in the raw file instead.
            case {39} % cleanedita on noctm; station 039 requires cleanedit to remove P spike and scanedit to remove data with pumps off.
                stn = stnlocal; mctd_01_noctm; % makes _noctm
                stn = stnlocal; mctd_02a_noctm; % renames vars in _noctm
                mctd_cleanedita(stnlocal,'noctm'); % range lim edit on _noctm; make _noctm_original and _noctm_cleaned
                mctd_scanedit(stnlocal,'noctm'); % set CTD vars to nan for range of scans
                stn = stnlocal; mctd_celltm; % applies align and celltm from _noctm to _raw
            case {51 54 98} % cleanedita on noctm
                stn = stnlocal; mctd_01_noctm; % makes _noctm
                stn = stnlocal; mctd_02a_noctm; % renames vars in _noctm
                mctd_cleanedita(stnlocal,'noctm'); % range lim edit on _noctm; make _noctm_original and _noctm_cleaned
                stn = stnlocal; mctd_celltm; % applies align and celltm from _noctm to _raw
            case {91} % scanedit on noctm; set range of scans inside mctd_scanedit
                stn = stnlocal; mctd_01_noctm; % makes _noctm
                stn = stnlocal; mctd_02a_noctm; % renames vars in _noctm
                mctd_scanedit(stnlocal,'noctm'); % set CTD vars to nan for range of scans
                stn = stnlocal; mctd_celltm; % applies align and celltm from _noctm to _raw
            case {87} % scanedit on raw; set range of scans inside mctd_scanedit
                stn = stnlocal; mctd_01; 
                stn = stnlocal; mctd_02a; 
                mctd_scanedit(stnlocal,'raw'); % set CTD vars to nan for range of scans; CTD landed on seabed
            otherwise % normal station on dy040
                stn = stnlocal; mctd_01;
                stn = stnlocal; mctd_02a;
        end
    otherwise
        stn = stnlocal; mctd_01;
        stn = stnlocal; mctd_02a;
end

stn = stnlocal; mctd_02b;

% stn = stnlocal; senscal = 1; mctd_tempcal % bak jr302, introduced after stn 116
% stn = stnlocal; senscal = 2; mctd_tempcal 

stn = stnlocal; senscal = 1; mctd_condcal;% elm+bak dy040 introduced after station 058 25 Dec 2015
stn = stnlocal; senscal = 2; mctd_condcal;
% stn = stnlocal; mctd_oxycal;

%     before dy040 : stn = stnlocal; mctd_oxycal; 
%     after dy040 use senscal = 0 if the variable is just
%     called 'oxygen'. This is an untested attempt at backwards
%     compatibility. Recommend oxygen variable should be called oxygen1,
%     even when there is only one oxygen. bak dy040 7 jan 2016.

stn = stnlocal; senscal = 1; mctd_oxycal % oxygen1 sensor elm+bak dy040 introduced after station 058 25 Dec 2015
stn = stnlocal; senscal = 2; mctd_oxycal % oxygen2 sensor


stn = stnlocal; mctd_03;

stn = stnlocal; msam_putpos; % jr302 populate lat and lon vars in sam file

% stn = stnlocal; mdcs_01; % on dy040 make at start of script if needed
stn = stnlocal; mdcs_02;




