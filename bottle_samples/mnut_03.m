% CPA 15/01/09
% Calculate organic nutrient values from total and inorganic nutrient
% values in sam file.  Flag is selected based on highest WOCE flag value.

minit; scriptname = mfilename;
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
mdocshow(scriptname, ['computes organic nutrients from total and inorganic nutrients in sam_' mcruise '_' stn_string '_raw.nc']);

if exist('stn','var')
    m = ['Running script ' scriptname ' on station ' sprintf('%03d',stn)];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
else
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
clear stn % so that it doesn't persist

root_ctd = mgetdir('M_CTD');
prefix1 = ['sam_' mcruise '_'];
infile1 = [root_ctd '/' prefix1 stn_string];

% phosphate

MEXEC_A.MARGS_IN = {
infile1
'y'
'dop'
'tp phos'
'y = x1-x2'
' '
' '
' '
};
mcalib2

MEXEC_A.MARGS_IN = {
infile1
'y'
'dop_flag'
'tp_flag phos_flag'
'y=max(cat(2,x1,x2),[],2)'
' '
' '
' '
};
mcalib2

% nitrate

MEXEC_A.MARGS_IN = {
infile1
'y'
'don'
'tn totnit'
'y = x1-x2'
' '
' '
' '
};
mcalib2

MEXEC_A.MARGS_IN = {
infile1
'y'
'don_flag'
'tn_flag totnit_flag'
'y=max(cat(2,x1,x2),[],2)'
' '
' '
' '
};
mcalib2
