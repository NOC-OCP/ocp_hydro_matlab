function mday_01_clean_av(abbrev,day)
%function mday_01_clean_av(abbrev,day)
%
% abbrev (char) is the mexec short name prefix for the data stream
% day (char or numeric) is the day number
%
% the output with all edits and calibrations applied goes to 
% abbrev_day_edt.nc
%
% updated by bak for jr195 2009-sep-17 for scs/techsas interface
% extensively revised by bak at noc aug 2010; hopefully integrates
% SCS&techsas streams with suitable switches and traps
%
% Created by efw to organise mday_00_clean.m to be (a little) more
% like mday_00_get_all.m
%
% Revised ylf jc145 to remove redundancy and cases for streams with no action
% and to add additional cases, incorporating actions formerly in m${stream}_01 files
%
% The possible edits include checking for out-of-range values, but
% instrument calibrations, which may vary by ship/cruise, are applied
% separately***
%
% revised ylf dy105 to check for various variable names (requiring similar transformations) in the header
%
% revised epa dy113 to apply factory calibrations to uncalibrated underway
% variables, as specified in the option file. On Discovery, this applies to
% fluorometer and transmissometer in met_tsg, and all radiometers in surflight

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

root_out = mgetdir(abbrev);

day_string = sprintf('%03d',day);
mdocshow(mfilename, ['performs any automatic cleaning/editing/averaging from ' abbrev '_' mcruise '_d' day_string '_raw.nc to ' abbrev '_' mcruise '_d' day_string '_edt.nc']);

prefix = [abbrev '_' mcruise '_d' day_string];
infile = [root_out '/' prefix '_raw'];
otfile = [root_out '/' prefix '_edt'];
wkfile = ['wk_' prefix '_' mfilename '_' datestr(now,30)];


if exist([infile '.nc']) %only if there is a raw file for this day

    % edit names and units
    mday_01_namesunits %***needs rvdas ones added

    % do things to techsas and scs files, hopefully unnecessary for rvdas
    if sum(strcmp(MEXEC_G.Mshipdatasystem,{'scs' 'techsas'}))
        mday_01_fixtimes
        if strcmp(abbrev,'cnav')
            mday_01_cnavfix %this re-parses degrees/minutes, hasn't been necessary since ***
        end
    end
   
   % apply factory calibrations to uncalibrated (still in voltage units) underway sensors
   % from cruise option file (introduced dy113)
   mday_01_fcal %***variable names? 

   % apply carter table soundspeed correction to single-beam bathymetry
   if sum(strcmp(abbrev, {'sim' 'ea600m' 'ea600'}))
       mday_01_cordep
   end
    
   % set data to absent outside ranges
   mday_01_rangeedit %***needs rvdas variable names

   % median average %***only bathymetry?
   if sum(strcmp(abbrev, {'sim' 'ea600m' 'ea600' 'em120' 'em122'}))
      %work on the latest file, which may already be an edited version; always output to otfile
      if exist([otfile '.nc'])
         unix(['/bin/mv ' otfile '.nc ' wkfile '.nc']); infile1 = wkfile;
      else
         infile1 = infile;
      end
      switch abbrev
         case {'sim', 'ea600m' 'ea600' 'em120', 'em122'}
            MEXEC_A.MARGS_IN = {infile1; otfile; '/'; 'time'; '-150,1e10,300'; '/'};
            mavmed
      end
      unix(['/bin/rm ' wkfile '.nc']);
   end

   % compute salinity and add to tsg file
   if sum(strcmp(abbrev, {'met_tsg' 'tsg' 'ocl'}))
       mday_01_tsgsal %***selection of temperature variable to use?
   end
   
    
end

