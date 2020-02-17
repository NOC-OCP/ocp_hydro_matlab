function mday_01_clean_av(abbrev,day)
%function mday_01_clean_av(abbrev,day)
%
% abbrev (char) is the mexec short name prefix for the data stream
% day (char or numeric) is the day number
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
% The function now checks for a case for the stream for types of transformations in succession
% abbrev_day_edt is the final output with all applicable corrections made
%
% The possible edits include checking for out-of-range values, but instrument calibrations,
% which may vary by ship/cruise, are applied separately
%
% revised ylf dy105 to check for various variable names (requiring similar transformations) in the header

m_common
scriptname = 'mday_01_clean_av';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

root_out = mgetdir(abbrev);

day_string = sprintf('%03d',day);
mdocshow(scriptname, ['performs any automatic cleaning/editing/averaging from ' abbrev '_' mcruise '_d' day_string '_raw.nc to ' abbrev '_' mcruise '_d' day_string '_edt.nc']);

prefix = [abbrev '_' mcruise '_d' day_string];
infile = [root_out '/' prefix '_raw'];
otfile = [root_out '/' prefix '_edt'];
wkfile = ['wk_' prefix '_' scriptname '_' datestr(now,30)];


if exist([infile '.nc']) %only if there is a raw file for this day


   %%%%% change variable names (calling mheadr) %%%%%
   %abbrev, new name, old name(s, or beginnings of)
   can = {'ash' 'head_ash' {'head'}
          'gys' 'head_gyr' {'head'}
	  'gyro_s' 'head_gyr' {'head'}
	  'gyro_pmv' 'head_gyr' {'head'}
	  'gyropmv' 'head_gyr' {'head'}
          'gpsfugro' 'long' {'lon'}
	  'sim' 'depth_uncor' {'depthm' 'depth' 'dep' 'snd'}
	  'ea600' 'depth_uncor' {'depthm' 'depth' 'dep' 'snd'}
	  'ea600m' 'depth_uncor' {'depthm' 'depth' 'dep' 'snd'}
	  'em120' 'swath_depth' {'depthm' 'dep' 'snd'}
	  'em122' 'swath_depth' {'depthm' 'dep' 'snd'}
      'tsg' 'psal' {'salinity' 'salin'}
      'met_tsg' 'psal' {'salinity' 'salin'}
         };

   ii = find(strcmp(abbrev, can(:,1))); 
   if length(ii)>0
      %work on the latest file, which may already be an edited version; always output to otfile
      if ~exist([otfile '.nc'])
         unix(['/bin/cp ' infile '.nc ' otfile '.nc']);
      end

      newname = can{ii,2};
      h = m_read_header(otfile);
      if ~sum(strcmp(newname, h.fldnam))
         for no = 1:length(can{ii,3})
            name = can{ii,3}{no};
            varnum = find(strncmp(name, h.fldnam, length(name)));
            if length(varnum)>0
               MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; sprintf('%d', varnum); newname; ' '; '-1'; '-1'; };
               mheadr
               break %only for renaming one variable per file (listed above in order of preference)
            end
         end
      end	    

   end


   %%%%% change units labels (calling mheadr) %%%%%
   switch abbrev
      case 'met' %asf note: techsas records m/s, however, the SSDS displays values converted to knots. There is no separate record of this since SSDS is live, so all wind records should be in m/s and no conversions are needed.
         if strcmp(MEXEC_G.Mshipdatasystem, 'techsas')
            MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; 'speed'; ' '; 'm/s'; '-1'; '-1'};
            mheadr
         end
   end


   %%%%% check for repeated times and backward time jumps %%%%%
   switch abbrev

      case {'ash', 'cnav', 'gp4', 'pos', 'met', 'met_light', 'met_tsg', 'tsg', 'surfmet'}
         %work on the latest file, which already be an edited version; always output to otfile
         if exist([otfile '.nc'])
            unix(['/bin/mv ' otfile '.nc ' wkfile '.nc']); infile1 = wkfile;
         else
            infile1 = infile;
         end
         MEXEC_A.MARGS_IN = {infile1; otfile; '/'; 'time'; 'y=[1 x1(2:end)-x1(1:end-1)]'; 'deltat'; 'seconds'; ' '};
         mcalc
         unix(['/bin/rm ' m_add_nc(wkfile)]);

      case {'gys', 'gyr', 'gyro_s', 'gyropmv' 'posmvpos'}
         %work on the latest file, which already be an edited version; always output to otfile
         if exist([otfile '.nc'])
            unix(['/bin/mv ' otfile '.nc ' wkfile '.nc']); infile1 = wkfile;
         else
            infile1 = infile;
         end
         wkfile2 = [prefix '_wk2'];
         % flag non-monotonic times
         MEXEC_A.MARGS_IN = {infile1; wkfile2; '/'; 'time'; 'y = m_flag_monotonic(x1);'; 'tflag'; ' '; ' '};
         mcalc
         if strcmp(abbrev, 'posmvpos')
	        varlist = '1 2 3 4 5 6 7 8 9';
         else
	        varlist = '1 2';
         end
         MEXEC_A.MARGS_IN = {wkfile2; otfile; '2'; 'tflag .5 1.5'; ' '; varlist};
         mdatpik
         unix(['/bin/rm ' m_add_nc(wkfile2)])
         unix(['/bin/rm ' m_add_nc(wkfile)]);

   end


   %%%%% apply other corrections for bad data or data labelling %%%%%
   if strcmp(abbrev, 'cnav')
      %work on the latest file, which already is an edited version; always output to otfile
      if ~exist([otfile '.nc'])
         unix(['/bin/cp ' infile '.nc ' otfile '.nc']);
      end
	  d = mload(otfile, '/'); 
      if max([d.lat(:)-floor(d.lat(:)); d.long(:)-floor(d.long(:))]*100)<=61
         MEXEC_A.MARGS_IN = {otfile; 'y'; 'lat'; 'y = cnav_fix(x)'; ' '; ' '; 'long'; 'y = cnav_fix(x)'; ' '; ' '; ' '};
         mcalib
      end
   end


   %%%%% apply carter table soundspeed correction to single-beam bathymetry %%%%%
   if sum(strcmp(abbrev, {'sim' 'ea600m' 'ea600'}))
      %work on the latest file, which may already be an edited version; always output to otfile
      if exist([otfile '.nc'])
         unix(['/bin/mv ' otfile '.nc ' wkfile '.nc']); infile1 = wkfile;
      else
         infile1 = infile;
      end

      navname = MEXEC_G.default_navstream; navdir = mgetdir(navname);
      navfile = [navdir '/' navname '_' mcruise '_d' day_string '_raw.nc'];
      if exist(navfile)
         [dn,hn] = mload(navfile,'/'); if ~isfield(dn, 'lon'); dn.lon = dn.long; end
         lon = nanmean(dn.lon); lat = nanmean(dn.lat); clear dn hn
      else
         warning(['no pos file for day ' day_string ' found, using current position to select carter area for echosounder correction'])
 	     if strcmp(MEXEC_G.Mshipdatasystem, 'techsas')
	        pos = mtlast(navname); lon = pos.long; lat = pos.lat; clear pos
	     elseif strcmp(MEXEC_G.Mshipdatasystem, 'scs')
	        pos = mslast(navname); lon = pos.long; lat = pos.lat; clear pos
         end
      end

      calcstr = ['y = mcarter(' num2str(lat) ', ' num2str(lon) ', x1); y = y.cordep;'];
      MEXEC_A.MARGS_IN = {infile1; otfile; '/'; 'depth_uncor'; calcstr; 'depth'; 'metres'; '0'};
      mcalc
   end

    
   %%%%% set data to absent outside ranges %%%%%
   %list of possible streams and fields; this should generally only be added to because extras will just be ignored
   car = {'ash' {'head_ash' 'pitch' 'roll' 'mrms' 'brms'} {'0 360' '-5 5' '-7 7' '0.00001 0.01' '0.00001 0.1'}
	  'gp4' {'long' 'lat'} {'-181 181' '-91 91'}
	  'pos' {'long' 'lat'} {'-181 181' '-91 91'}
	  'seapos' {'long' 'lat'} {'-181 181' '-91 91'}
	  'posdps' {'long' 'lat'} {'-181 181' '-91 91'}
	  'met' {'airtemp' 'humid' 'direct' 'speed'} {'-50 50' '0.1 110' '-0.1 360.1' '-0.001 200'}
	  'surfmet' {'airtemp' 'humid' 'direct' 'speed'} {'-50 50' '0.1 110' '-0.1 360.1' '-0.001 200'}
	  'met_light' {'pres' 'ppar' 'spar' 'ptir' 'stir'} {'0.01 1500' '-10 1500' '-10 1500' '-10 1500' '-10 1500'}
	  'surflight' {'pres' 'ppar' 'spar' 'ptir' 'stir'} {'0.01 1500' '-10 1500' '-10 1500' '-10 1500' '-10 1500'}
	  'tsg' {'temp_h' 'temp_r' 'temp_m' 'sstemp' 'tstemp' 'cond' 'trans'} {'-2 50' '-2 50' '-2 50' '-2 50' '-2 50' '0 10' '0 105'}
	  'met_tsg' {'temp_h' 'temp_r' 'temp_m' 'sstemp' 'tstemp' 'cond' 'trans' 'fluo' 'flow1'} {'-2 50' '-2 50' '-2 50' '-2 50' '-2 50' '0 10' '0 105' '0 10' '0 10'}
	  'ocl' {'temp_h' 'temp_r' 'temp_m' 'sstemp' 'tstemp' 'cond' 'trans'} {'-2 50' '-2 50' '-2 50' '-2 50' '-2 50' '0 10' '0 105'}
	  'sim' {'depth' 'depth_uncor'} {'20 10000' '20 10000'}
	  'ea600m' {'depth' 'depth_uncor'} {'20 10000' '20 10000'}
	  'ea600' {'depth' 'depth_uncor'} {'20 10000' '20 10000'}
	  'em120' {'swath_depth'} {'20 10000'}
	  'em122' {'swath_depth'} {'20 10000'}
      };

   ii = find(strcmp(abbrev, car(:,1))); 
   if length(ii)>0
      %work on the latest file, which may already be an edited version; always output to otfile
      if ~exist([otfile '.nc'])
         unix(['/bin/cp ' infile '.nc ' otfile '.nc']);
      end

      MEXEC_A.MARGS_IN = {otfile; 'y'};
      h = m_read_header(infile);
      for no = 1:length(car{ii,2})
         if sum(strcmp(car{ii,2}{no}, h))
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; car{ii,2}{no}; car{ii,3}{no}];
         end
      end
      if length(MEXEC_A.MARGS_IN)>2
         MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; 'y'; ' '];
         medita
      end

   end


   %%%%% median average %%%%%
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


   %%%%% compute salinity and add to tsg file %%%%%
   if sum(strcmp(abbrev, {'met_tsg' 'tsg' 'ocl'}))
      %work on the latest file, which already be an edited version; always output to otfile
      if exist([otfile '.nc'])
         unix(['/bin/mv ' otfile '.nc ' wkfile '.nc']);
      else
         unix(['/bin/cp ' infile '.nc ' wkfile '.nc']);
      end
      infile1 = wkfile;
      h = m_read_header(infile1);
      if sum(strcmp('cond', h.fldnam))
         if sum(strcmp('tstemp', h.fldnam))
            tvar = 'tstemp';
         elseif sum(strcmp('temp_h', h.fldnam))
            tvar = 'temp_h';
         elseif sum(strcmp('temp_m', h.fldnam))
            tvar = 'temp_m';
         else
            warning('no housing/pumped seawater supply temperature set')
            tvar = [];
         end
         if sum(strcmp('psal', h.fldnam))==0 & length(tvar)>0
            MEXEC_A.MARGS_IN = {infile1; otfile; '/'; ['cond ' tvar]; 'y = gsw_SP_from_C(10*x1,x2,0)'; 'psal'; 'pss-78'; ' '};
            mcalc
            unix(['/bin/rm ' m_add_nc(wkfile)]);
         elseif length(tvar)>0
            unix(['/bin/mv ' wkfile '.nc ' otfile '.nc']);
            MEXEC_A.MARGS_IN = {otfile; 'y'; 'psal'; ['cond ' tvar]; 'y = gsw_SP_from_C(10*x1,x2,0)'; '/'; 'pss-78'; ' '};
            mcalib2
         else
            unix(['/bin/rm ' m_add_nc(wkfile)]);
         end
      else %if exist(m_add_nc(wkfile),'file') % if we don't have conductivity, e.g. on Discovery, where it's in tsg but not met_tsg, don't delete the file!
         unix(['/bin/mv ' wkfile '.nc ' otfile '.nc']);
      end
   end


    %%%%% anything else specified in cruise options file %%%%%    
    get_cropt

    
end

