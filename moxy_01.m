% moxy_01: read in bottle oxy data from csv file
%
% Use: moxy_01        and then respond with station number, or for station 16
%      stn = 16; moxy_01;
%
% The input data are in comma-delimited files suitable for loading as a database, with
%    fields/headers including either:
%        option 1:
%            statnum, niskin, botoxytempa, botoxya, botoxyflaga, botoxytempb, botoxyb, botoxyflagb
%            where units are degC, umol/l, and woce flag
%        or
%        option 2:
%            statnum, niskin, oxy_bot, oxy_temp, oxy_titre
%            in the second case moxy_ccalc will be called to compute oxygen concentrations
%            using parameters set in opt_cruise, to and match up botoxya and botoxyb
%            flags will also be set in opt_cruise

scriptname = 'moxy_01';
minit
mdocshow(scriptname, ['loads bottle oxygens from file specified in opt_' mcruise ', optionally calls moxy_ccalc to compute concentration from titration, and writes to oxy_' mcruise '_' stn_string '.nc']);

% resolve root directories for various file types
root_oxy = mgetdir('M_BOT_OXY');



%%%%%%%%%%%%%%%%%% load %%%%%%%%%%%%%%%%%%

oopt = 'oxycsv'; get_cropt %filename
if ~exist(infile, 'file'); warning(['file ' infile ' not found']); return; end

%%%%%%%%% first try loading as dataset; check for required fields %%%%%%%%%
try %first try treating as dataset with required fields

   ds_oxy = dataset('File', infile, 'Delimiter', ',');

   %test for required fields
   ds_oxy_fn = ds_oxy.Properties.VarNames;
   if sum(strcmp(mcruise, ds_oxy_fn)) %***perhaps this should be more general
      me = MException('myfile:notdataset:obeexcel', '%s is obe excel file', infile);
      throw(me)
   elseif ~(sum(strcmpi('sampnum', ds_oxy_fn))+sum(strcmpi('station', ds_oxy_fn))+sum(strcmpi('cast', ds_oxy_fn)))
      me = MException('myfile:notdataset:unknown', 'check %s format, columns, header', infile);
      throw(me)
   end


%%%%%%%%% if not, try loading as obe excel file, and putting into dataset %%%%%%%%%
catch me

   if strcmp(me.identifier, 'myfile:notdataset:unknown')
      error(me.message)
   else
      disp(me.message) %probably fine to load as an obe excel file, but display message just for info
   end

   warning('off', 'stats:dataset:subsasgn:DefaultValuesAdded')

   %load as text
   indata = mtextdload(infile, ',');

   %parse to find column header rows and data rows
   nrows = length(indata);
   ltype = zeros(nrows,1); iiss = []; iiss0 = 1;
   k = 1;
   while k<nrows
      iiss = find(strncmp('Cast', indata{k}, 4) & strncmp('Number', indata{k+1}, 6));
      if ~isempty(iiss)
         ltype(k) = 1; %column header
         iiss0 = iiss;
	 k = k+2; %next two rows are also part of the column header
      elseif length(indata{k})>=iiss0 & ~isempty(str2num(indata{k}{iiss0}))
         ltype(k) = 2; %data
      end
      ltype(nrows) = 2; %assume ends with data
   end

   %initalise dataset
   ds_oxy = dataset;
   loxy = 0;

   %put into dataset
   iih = [find(ltype==1); nrows];

   %for every block separated by headers
   for cno = 1:length(iih)-1
   
      %find the relevant columns for this block
      issta = strncmpi('Cast', indata{iih(cno)}, 4);
      isnis = strcmpi('Niskin', indata{iih(cno)});
      isbot = strncmpi('Bottle', indata{iih(cno)}, 6) & strncmpi('no', indata{iih(cno)+2}, 2);
      isvol = strncmpi('Bottle', indata{iih(cno)}, 6) & strncmpi('mls', indata{iih(cno)+2}, 2);
      isblk = strncmpi('Blank', indata{iih(cno)}, 5);
      isstv = strncmpi('Std', indata{iih(cno)}, 3) & strncmpi('vol', indata{iih(cno)+1}, 3);
      isstd = strcnmpi('Standard', indata{iih(cno)}, 8) & strncmpi('titre', indata{iih(cno)+1}, 5);
      istem = strncmpi('Fixing', indata{iih(cno)}, 6) & strncmpi('temp', indata{iih(cno)+1}, 4);
      isoti = strncmpi('Sample', indata{iih(cno)}, 6) & strncmpi('titre', indata{iih(cno)+1}, 5);
      isiod = strncmpi('Iodate', indata{iih(cno)}, 6);
      isno2 = strncmpi('n(O2)', indata{iih(cno)}, 5) & strcnmpi('mol', indata{iih(cno)+2}, 3);
      isco2 = strncmpi('C(O2)', indata{iih(cno)}, 5) & strncmpi('umol', indata{iih(cno)+2}, 4);
      isflg = strcnmpi('flag', indata{iih(cno)}, 4);

      %find the sample lines for this block
      iis = find(ltype==2); iis = iis(iis>iih(cno) & iis<iih(cno+1));

      %append sample rows %***possibly this could be done faster with
      %cell2mat? or possibly not
      for sno = 1:length(iis)
         loxy = loxy+1;
         ds_oxy.statnum(loxy,1) = str2num(indata{iis(sno)}{issta});
         ds_oxy.niskin(loxy,1) = str2num(indata{iis(sno)}{isnis});
         ds_oxy.oxy_bot(loxy,1) = str2num(indata{iis(sno)}{isbot});
         ds_oxy.bot_vol(loxy,1) = str2num(indata{iis(sno)}{isvol});
	 ds_oxy.oxy_temp(loxy,1) = str2num(indata{iis(sno)}{istem});
         ds_oxy.vol_blank(loxy,1) = str2num(indata{iis(sno)}{isblk});
	 ds_oxy.vol_std(loxy,1) = str2num(indata{iis(sno)}{isstv});
	 ds_oxy.vol_titre_std(loxy,1) = str2num(indata{iis(sno)}{isstd});
	 ds_oxy.mol_std(loxy,1) = str2num(indata{iis(sno)}{isiod});
	 ds_oxy.oxy_titre(loxy,1) = str2num(indata{iis(sno)}{isoti});
	 ds_oxy.concO2(loxy,1) = str2num(indata{iis(sno)}{isco2});
	 ds_oxy.flag(loxy,1) = str2num(indata{iis(sno)}{isflg});
      end	 
   end
   
end %end try/catch


%%%%%%%%%%%%%%%%%% now operate on dataset %%%%%%%%%%%%%%%%%%

ds_oxy_fn = ds_oxy.Properties.VarNames;

%rename/create dataset fields if necessary
if sum(strcmp('statnum', ds_oxy_fn))==0
   if sum(strcmp('sampnum', ds_oxy_fn))
      ds_oxy.statnum = floor(ds_oxy.sampnum/100);
   else
      oopt = 'sampnum_parse'; get_cropt
   end
end
ds_oxy_fn = ds_oxy.Properties.VarNames;

%find this station
iig = find(ds_oxy.statnum==stnlocal);
if length(iig)==0; warning(['no oxy data for station ' stn_string]); return; end
ds_oxy = ds_oxy(iig,:);


%optionally calculate concentrations
if sum(strcmp('oxy_titre', ds_oxy_fn)) & sum(strcmp('oxy_temp', ds_oxy_fn)) & sum(strcmp('oxy_bot', ds_oxy_fn)+strcmp('oxy_vol', ds_oxy_fn)) %necessary information is in file
   ds_oxy = moxy_ccalc(ds_oxy); %compute concentrations from titre, temperature, and other parameters
end

oopt = 'oxybotnisk'; get_cropt

sampnum = ds_oxy.statnum*100 + ds_oxy.niskin;
position = ds_oxy.niskin;
statnum = ds_oxy.statnum;
botoxya_per_l = ds_oxy.botoxya_per_l; botoxyflaga = ds_oxy.botoxyflaga; botoxytempa = ds_oxy.botoxytempa;
botoxyb_per_l = ds_oxy.botoxyb_per_l; botoxyflagb = ds_oxy.botoxyflagb; botoxytempb = ds_oxy.botoxytempb;

%edit flags
botoxyflaga(botoxyflaga == -999) = 9; %sample not drawn
botoxyflagb(botoxyflagb == -999) = 9;
botoxyflaga(botoxyflaga~=9 & isnan(botoxya_per_l)) = 5; %not reported
botoxyflagb(botoxyflagb~=9 & isnan(botoxyb_per_l)) = 5; 
oopt = 'flags'; get_cropt

otfile = [root_oxy '/oxy_' mcruise '_' stn_string];
dataname = ['oxy_' mcruise '_' stn_string];

varnames = {'position','statnum','sampnum','botoxytempa','botoxya_per_l','botoxyflaga','botoxytempb','botoxyb_per_l','botoxyflagb'};
varunits = {'number','number','number','degC','umol/l','woceflag','degC','umol/l','woceflag'};
nvars = length(varnames);

varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];

%save
MEXEC_A.MARGS_IN_1 = {
    otfile
};
MEXEC_A.MARGS_IN_2 = varnames(:);
MEXEC_A.MARGS_IN_3 = {
' '
' '
'1'
dataname
'/'
'2'
MEXEC_G.PLATFORM_TYPE
MEXEC_G.PLATFORM_IDENTIFIER
MEXEC_G.PLATFORM_NUMBER
'/'
'4'
timestring
'/'
'8'
};
MEXEC_A.MARGS_IN_4 = varnames_units(:);
MEXEC_A.MARGS_IN_5 = {
'-1'
'-1'
};
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3; ...
                    MEXEC_A.MARGS_IN_4;MEXEC_A.MARGS_IN_5];
msave

if 0
%edit out of range values
MEXEC_A.MARGS_IN = {
otfile
'y'
'botoxytempa'
'-10 100'
'y'
'botoxya_per_l'
'0 500'
'y'
'botoxytempb'
'-10 100'
'y'
'botoxyb_per_l'
'0 500'
'y'
' '
};
medita
end
