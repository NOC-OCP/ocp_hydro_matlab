%scripts to rerun after editing using mctd_rawedit
scriptname = 'smallscript';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';

root_ctd = mgetdir('M_CTD');
    
if ~exist('klist'); oopt = 'klist'; get_cropt; end

disp('Will process stations in klist: ')
disp(klist)
okc = input('OK to continue (y/n)?','s');
if okc == 'n' | okc == 'N'
	return
end
	
for kloop = klist
    stn = kloop;
    stn_string = sprintf('%03d',stn);
    
    prefix1 = ['ctd_' cruise '_'];
    infile1 = [root_ctd '/' prefix1 stn_string '_raw'];
    
    if exist(m_add_nc(infile1),'file') ~= 2
        mess = ['File ' m_add_nc(infile1) ' not found'];
        fprintf(MEXEC_A.Mfider,'%s\n',mess)
        continue
    end

    stn = kloop; mctd_02b
    stn = kloop; mctd_03;
    stn = kloop; mctd_04;
    
    prefix2 = ['fir_' cruise '_'];
    infile2 = [root_ctd '/' prefix2 stn_string '_time'];
    if exist(m_add_nc(infile2),'file') ~= 2
        mess = ['File ' m_add_nc(infile2) ' not found'];
        fprintf(MEXEC_A.Mfider,'%s\n',mess)
        continue
    end

    stn = kloop; mfir_03;
    stn = kloop; mfir_04;

end
