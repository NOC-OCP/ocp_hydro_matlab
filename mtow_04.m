% mtow_04: extract data from psal file using index information in towyo_limits_xxxxx file; 
%          sort, average to 2dbar, interpolate gaps and recalculate potemp.
%          BAK for jc044. Towyo files contain multiple casts and part
%          casts. Instead of using dcs file, presently set up to use a
%          plain text file containing details of towyo 'profile number', ctd
%          file number from which data are to be extracted, and range of
%          scan numbers to be included in the towyo profile. 
%          On jc044, format of towyo_limits_ file is 
%           003001 1.37405e+04 1.66308e+05
%           003002 1.66308e+05 1e10
%           004001 0 2.40125e+04
%          The first number on each line is an index of the profile. 
%          The index number is (CTD_file_number*1000)+profile_number, eg
%          13003 for ctd_file 013, sequential_profile 3.
%          The next two numbers are the lower and upper limits of
%          scan_nmber to be extracted.
%
%          The scan number range is used by datpik to extract scans within
%          the range. Thus to extract from 'start of file' you can use scan
%          number zero, and to extract to 'end of file' you can use a large
%          number, such as 1e10.
%
%          Edited from mctd_04 by BAK 8 April 2010; revised 9 April 2010.
%
% Use: mtow_04        and then respond with ctd/towyo profile number, or for
%          profile 1 in ctd file 5
%      stn = 5001; mtow_04;

scriptname = 'mtow_04';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%06d',stn);
stnlocal = stn;
clear stn % so that it doesn't persist

root_ctd = mgetdir('M_CTD');

prefix1 = ['ctd_' mcruise '_'];
prefix2 = ['dcs_' mcruise '_'];

lims_fn = ['towyo_limits_' mcruise];
tow_lims = load(lims_fn);
tow_stns = tow_lims(:,1);
k1 = find(tow_stns == stnlocal);
if length(k1) ~= 1
    m1 = ['Problem in ' lims_fn ' unique match for station number not found'];
    fprintf(MEXEC_A.Mfider,'%s\n',m1);
    return
else
    stn_ctd = floor(stnlocal/1000); % ctd 'station' file number
    stn_seq = round(stnlocal-1000*stn_ctd); % sequential towyo profile within ctd station file
    stn_string_ctd = sprintf('%03d',stn_ctd); % ctd station string
    seq_string = sprintf('%03d',stn_seq); % string for sequential towyo profile within ctd file
    scan1 = tow_lims(k1,2);
    scan2 = tow_lims(k1,3);
    % range of scan numbers to select for this profile
    datpik_str = ['scan ' sprintf('%12.0f',floor(scan1)) ' ' sprintf('%12.0f',ceil(scan2))];
end

infile1 = [root_ctd '/' prefix1 stn_string_ctd '_psal'];
infile2 = [root_ctd '/' prefix2 stn_string];
otfile1 = [root_ctd '/' prefix1 stn_string_ctd seq_string '_2db'];
otfile2 = ['wk_' scriptname '_' datestr(now,30)];
otfile3 = ['wk2_' scriptname '_' datestr(now,30)];
otfile4 = ['wk3_' scriptname '_' datestr(now,30)];

%--------------------------------
% 2010-04-08 09:36:51
% mdatpik
% calling history, most recent first
%    mdatpik in file: mdatpik.m line: 274
% input files
% Filename ctd_jc044_013_psal.nc   Data Name :  ctd_jc044_013 <version> 31 <site> jc044_atsea
% output files
% Filename ctd_jc044_631_2db.nc   Data Name :  ctd_jc044_013 <version> 32 <site> jc044_atsea
MEXEC_A.MARGS_IN = {
infile1
otfile2
'2'
datpik_str
'/'
'/'
};
mdatpik
%--------------------------------


%--------------------------------
% 2009-01-28 16:27:33
% msort
% input files
% Filename wk_20090128T162509.nc   Data Name :  ctd_jr193_016 <version> 40 <site> bak_macbook
% output files
% Filename wk2_20090128T162509.nc   Data Name :  ctd_jr193_016 <version> 41 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile2
otfile3
'press'
};
msort
%--------------------------------

%--------------------------------
% 2009-01-28 16:34:31
% mavrge
% input files
% Filename wk2_20090128T162509.nc   Data Name :  ctd_jr193_016 <version> 41 <site> bak_macbook
% output files
% Filename wk3_20090128T163406.nc   Data Name :  ctd_jr193_016 <version> 45 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile3
otfile4
'/'
'press'
'0 10000 2'
'b'
};
mavrge
%--------------------------------

%--------------------------------
% 2009-01-28 16:36:34
% mintrp
% input files
% Filename wk3_20090128T163406.nc   Data Name :  ctd_jr193_016 <version> 45 <site> bak_macbook
% output files
% Filename wk3_20090128T163406.nc   Data Name :  ctd_jr193_016 <version> 46 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile4
'y'
'/'
'press'
'0'
'0'
};
mintrp
%--------------------------------

%--------------------------------
% 2009-01-28 16:38:18
% mcalc
% input files
% Filename wk3_20090128T163406.nc   Data Name :  ctd_jr193_016 <version> 46 <site> bak_macbook
% output files
% Filename ctd_jr193_016_2db.nc   Data Name :  ctd_jr193_016 <version> 47 <site> bak_macbook
MEXEC_A.MARGS_IN = {
otfile4
otfile1
'scan time press pressure_temp temp cond temp1 cond1 temp2 cond2 altimeter oxygen fluor transmittance EH LSS BBRTD psal psal1 psal2/'
'press'
'y = sw_dpth(x1,h.latitude)'
'depth'
'metres'
'psal temp press'
'y = sw_ptmp(x1,x2,x3,0)'
'potemp'
'degc90'
'psal1 temp1 press'
'y = sw_ptmp(x1,x2,x3,0)'
'potemp1'
'degc90'
'psal2 temp2 press'
'y = sw_ptmp(x1,x2,x3,0)'
'potemp2'
'degc90'
' '
};
mcalc
%--------------------------------


unix(['/bin/rm ' otfile2 '.nc ' otfile3 '.nc ' otfile4 '.nc']);
