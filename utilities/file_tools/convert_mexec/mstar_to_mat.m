% mstar_to_mat: load CTD data from mstar netcdf files and export
% them to matlab format.  This uses the _1hz.nc files (for now).
%
% Use: mstar_to_mat    and then respond with station number, or for station 16
%      stn = 16; mstar_to_mat;

% ZBS, D344 22.10.09 - This was only briefly written for CTD data,
% but it can be readily extended for other formats or etc.  The
% _1hz.nc file has time in seconds, which isn't very practical, so
% it's converted into a couple of different formats here (year,
% month, day, hour, minute, second; and yearday)

scriptname = 'mstar_to_mat';

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
if exist('MEXEC_G','var') && isfield(MEXEC_G,'opt_cruise') && exist(MEXEC_G.opt_cruise,'file')
    opt1 = 'setup'; opt2 = 'm_stn_string'; run(MEXEC_G.opt_cruise)
else
    stn_string = sprintf('%03d',stn);
end
stnlocal = stn;
clear stn % so that it doesn't persist

mcd('M_CTD'); % change working directory

prefix1 = ['ctd_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];


infiles = {[prefix1 stn_string '_1hz'],...
           [prefix1 stn_string '_24hz'],...
           [prefix1 stn_string '_2db']};
otfiles = {[prefix1 stn_string '_1hz.mat'],...
           [prefix1 stn_string '_24hz.mat'],...
           [prefix1 stn_string '_2db.mat']};


timunt = ['seconds since ' MEXEC_G.data_time_origin_string];
timunty = ['days since ' MEXEC_G.data_time_origin_string '-01-01 00:00:00'];
for ii = 1:length(infiles)
  
  infilei = infiles{ii};
  otfilei = otfiles{ii};

  [d, h] = mload(infilei,'/');
  [d.time, h.fldunt(strcmp('time',h.fldnam))] = m_commontime(d, 'time', h, timunt);
  
  vars = fieldnames(d);
  for ii = 1:length(vars)
    var = vars{ii};
    eval([var ' = getfield(d,''' var ''');']);
  end

  dday = m_commontime(d.time, timunt, timunty);

  disp(['saving data to ' otfilei])
  try
    save(otfilei,'time','scan','pumps','time_bin_average','press','temp','temp2',...
         'cond','cond2','t2_minus_t1','c2_minus_c1','pressure_temp','altimeter',...
         'nbf','flag','data_time_origin','dday','h')
  catch
    save(otfilei,'time','scan','pumps','time_bin_average','press','temp','temp2',...
         'cond','cond2','t2_minus_t1','c2_minus_c1','pressure_temp','altimeter',...
         'data_time_origin','dday','h')
  end
  
end


% provide a mechanism to disable transfering files, to avoid
% needing operator input for the passwords.
if ~exist('nofiletransfer','var') | nofiletransfer==0
  
  disp(['copying mat files to rapid.discovery (192.168.62.101), ',...
        'enter password twice . . .'])
  eval(['!scp -p ' otfiles{1} ' ' otfiles{2} ' ' otfiles{3} ' '...
        infiles{1} '.nc ' infiles{2} '.nc ' infiles{3} '.nc ' ...
        'rapid:/local/users/pstar/Data/rpdmoc/cruises/d344/ctd/'])
  
  rawfiles = {['ASCII_FILES/' prefix1 stn_string '.cnv'],...
              ['ASCII_FILES/' prefix1 stn_string '_ctm.cnv'],...
              ['ASCII_FILES/' prefix1 stn_string '.ros']};

  eval(['!scp -p ' rawfiles{1} ' ' rawfiles{2} ' ' rawfiles{3} ' '...
        'rapid:/local/users/pstar/Data/rpdmoc/cruises/d344/ctd/ASCII_FILES/'])
end
  