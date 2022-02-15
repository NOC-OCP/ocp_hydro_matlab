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
stn_string = sprintf('%03d',stn);
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


for i = 1:length(infiles)
  
  infilei = infiles{i};
  otfilei = otfiles{i};

  [d h] = mload(infilei,'/');


  vars = fieldnames(d);
  for i = 1:length(vars)
    var = vars{i};
    eval([var ' = getfield(d,''' var ''');']);
  end

  data_time_origin = h.data_time_origin;
  date = datevec(datenum(data_time_origin) + time/3600/24);

  year = date(:,1);
  month = date(:,2);
  day = date(:,3);
  hour = date(:,4);
  minute = date(:,5);
  sec = date(:,6);

  yday = datenum(date) - datenum(2009,1,1)+1; % 01 Jan 1200 is yearday 1.5


  disp(['saving data to ' otfilei])
  try
    save(otfilei,'time','scan','pumps','time_bin_average','press','temp','temp2',...
         'cond','cond2','t2_minus_t1','c2_minus_c1','pressure_temp','altimeter',...
         'nbf','flag','data_time_origin','date','year','month','day',...
         'hour','minute','sec','yday','h')
  catch
    save(otfilei,'time','scan','pumps','time_bin_average','press','temp','temp2',...
         'cond','cond2','t2_minus_t1','c2_minus_c1','pressure_temp','altimeter',...
         'data_time_origin','date','year','month','day',...
         'hour','minute','sec','yday','h')
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
  