stn1 = input('type stn number from which to run');
stn2 = input('type stn number to which to run');
stn1_string = sprintf('%03d',stn1);
stn2_string = sprintf('%03d',stn2);

for stnlocal = stn1:stn2;

clear stn % so that it doesn't persist

stn = stnlocal; 
os   = 75;
cast  = 'ctd';
mcod_03;


stn = stnlocal
os   = 75
cast  = 'ctd'

mcod_stn_out(cast,stn,75);

end
