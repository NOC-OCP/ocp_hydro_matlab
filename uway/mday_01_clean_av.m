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

m_common
scriptname = 'mday_01_clean_av';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

root_out = mgetdir(abbrev);

day_string = sprintf('%03d',day);
mdocshow(scriptname, ['performs any automatic cleaning/editing/averaging from ' abbrev '_' mcruise '_d' day_string '_raw.nc to ' abbrev '_' mcruise '_d' day_string '_edt.nc']);

prefix = [abbrev '_' mcruise '_d' day_string];
infile = [root_out '/' prefix '_raw'];
otfile = [root_out '/' prefix '_edt'];
wkfile = [prefix '_wk_' scriptname '_' datestr(now,30)];


if exist([infile '.nc']) %only if there is a raw file for this day



   %%%%% change variable names (calling mheadr) %%%%%

   if sum(strcmp(abbrev, {'ash' 'gys' 'gyr' 'gyro_s' 'gpsfugro' 'met' 'sim' 'ea600m' 'ea600' 'em120' 'em122' 'gyropmv'}))
      %work on the latest file, which may already be an edited version; always output to otfile
      if ~exist([otfile '.nc'])
         unix(['/bin/cp ' infile '.nc ' otfile '.nc']);
      end
      switch abbrev

         case 'ash'
            newheadname = 'head_ash';
	    h = m_read_header(otfile);
            if ~sum(strcmp(newheadname, h.fldnam))
	       headvarnum = find(strncmp('head', h.fldnam, 4));
               headvarnumstr = sprintf('%d', headvarnum);
               MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; headvarnumstr; newheadname; ' '; '-1'; '-1'; };
               mheadr
            end
	    
	 case {'gys', 'gyr', 'gyro_s', 'gyropmv'}
            newheadname = 'head_gyr';
            h = m_read_header(otfile);
            if ~sum(strcmp(newheadname, h.fldnam))
               headvarnum = find(strncmp('head', h.fldnam, 4));
               headvarnumstr = sprintf('%d', headvarnum);
               MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; headvarnumstr; newheadname; ' '; '-1'; '-1'; };
               mheadr
            end
	    
         case 'gpsfugro'
            newlongname = 'long';
            h = m_read_header(otfile);
            if ~sum(strcmp(newlongname, h.fldnam))
	           lonvarnum = find(strncmp('lon', h.fldnam, 3));
	           longvarnumstr = sprintf('%d', lonvarnum);
               MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; longvarnumstr; newlongname; ' '; '-1'; '-1'};
               mheadr
         end
	    
	 case {'met'}%, 'met_tsg'} %asf note: techsas records m/s, however, the SSDS displays values converted to knots. There is no separate record of this since SSDS is live, so all wind records should be in m/s and no conversions are needed.
	    if strcmp(MEXEC_G.Mshipdatasystem, 'techsas')
               MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; 'speed'; ' '; 'm/s'; '-1'; '-1'};
               mheadr
            end
	    	
         case {'sim' 'ea600m' 'ea600'}
            newdepthname = 'depth_uncor';
            h = m_read_header(otfile);
            if ~sum(strcmp(newdepthname, h.fldnam))
	           depvarnum = find(strncmp('dep', h.fldnam, 3)); if length(depvarnum)==0; depvarnum = find(strncmp('snd', h.fldnam, 3)); elseif length(depvarnum)>1; depvarnum = find(strcmp('depthm', h.fldnam)); end
	           depvarnumstr = sprintf('%d', depvarnum);
                   MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; depvarnumstr; newdepthname; ' '; '-1'; '-1'};
	           mheadr
            end

         case {'em120', 'em122'}
            newdepthname = 'swath_depth';
            h = m_read_header(otfile);
            if ~sum(strcmp(newdepthname, h.fldnam))
               depvarnum = find(strncmp('dep', h.fldnam, 3)); if length(depvarnum)==0; depvarnum = find(strncmp('snd', h.fldnam, 3)); elseif length(depvarnum)>1; depvarnum = find(strcmp('depthm', h.fldnam)); end
               depvarnumstr = sprintf('%d', depvarnum);
               MEXEC_A.MARGS_IN = {otfile; 'y'; '8'; depvarnumstr; newdepthname; ' '; '-1'; '-1'};
	       mheadr
            end

      end
   end



   %%%%% check for repeated times and backward time jumps %%%%%
   if sum(strcmp(abbrev, {'ash' 'cnav' 'gp4' 'pos' 'met' 'met_light' 'met_tsg' 'tsg' 'gys' 'gyr' 'gyro_s' 'posmvpos' 'gyropmv' 'surfmet'}))
      %work on the latest file, which already be an edited version; always output to otfile
      if exist([otfile '.nc'])
         unix(['/bin/mv ' otfile '.nc ' wkfile '.nc']); infile1 = wkfile;
      else
         infile1 = infile;
      end
      switch abbrev

         case {'ash', 'cnav', 'gp4', 'pos', 'met', 'met_light', 'met_tsg', 'tsg', 'surfmet'}
            MEXEC_A.MARGS_IN = {infile1; otfile; '/'; 'time'; 'y=[1 x1(2:end)-x1(1:end-1)]'; 'deltat'; 'seconds'; ' '};
            mcalc

         case {'gys', 'gyr', 'gyro_s', 'gyropmv'}
            wkfile2 = [prefix '_wk2'];
            % flag non-monotonic times
            MEXEC_A.MARGS_IN = {infile1; wkfile2; '/'; 'time'; 'y = m_flag_monotonic(x1);'; 'tflag'; ' '; ' '};
            mcalc
            MEXEC_A.MARGS_IN = {wkfile2; otfile; '2'; 'tflag .5 1.5'; ' '; '1 2'};
            mdatpik
            unix(['/bin/rm ' m_add_nc(wkfile2)]);

         case 'posmvpos'
            wkfile2 = [prefix '_wk2'];
            % flag non-monotonic times
            MEXEC_A.MARGS_IN = {infile1; wkfile2; '/'; 'time'; 'y = m_flag_monotonic(x1);'; 'tflag'; ' '; ' '};
            mcalc
            MEXEC_A.MARGS_IN = {wkfile2; otfile; '2'; 'tflag .5 1.5'; ' '; '1 2 3 4 5 6 7 8 9'};
            mdatpik
            unix(['/bin/rm ' m_add_nc(wkfile2)]);
	    
      end
      unix(['/bin/rm ' wkfile '.nc']);
   end



   %%%%% other corrections for bad data or data labelling %%%%%
   if sum(strcmp(abbrev, {'cnav'}))
      %work on the latest file, which already is an edited version; always output to otfile
      if ~exist([otfile '.nc'])
         unix(['/bin/cp ' infile '.nc ' otfile '.nc']);
      end
      switch abbrev

          case 'cnav'
	     d = mload(otfile, '/'); if max([d.lat(:)-floor(d.lat(:)); d.long(:)-floor(d.long(:))]*100)<=61
                MEXEC_A.MARGS_IN = {otfile; 'y'; 'lat'; 'y = cnav_fix(x)'; ' '; ' '; 'long'; 'y = cnav_fix(x)'; ' '; ' '; ' '};
                mcalib
             end
	    
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
         [dn,hn] = mload(navfile,'/'); lon = nanmean(dn.long); lat = nanmean(dn.lat); clear dn hn
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
   if sum(strcmp(abbrev, {'ash' 'gp4' 'pos' 'met' 'met_light' 'tsg' 'met_tsg' 'sim' 'ea600m' 'ea600' 'em120' 'em122' 'surfmet'}))
      %work on the latest file, which may already be an edited version; always output to otfile
      if ~exist([otfile '.nc'])
         unix(['/bin/cp ' infile '.nc ' otfile '.nc']);
      end
      switch abbrev

         case 'ash'
            MEXEC_A.MARGS_IN = {otfile; 'y'; 'head_ash'; '0 360'; 'y'; 'pitch'; '-5 5'; 'y'; 'roll' '-7 7'; 'y'; 'mrms'; '0.00001 0.01'; 'y'; 'brms'; '0.00001 0.1'; 'y'; ' '};
            medita

         case {'gp4', 'pos'}
            MEXEC_A.MARGS_IN = {otfile; 'y'; 'long'; '-181 181'; 'y'; 'lat'; '-91 91'; 'y'; ' '};
            medita

         case {'met', 'surfmet'}
          MEXEC_A.MARGS_IN = {otfile; 'y'; 'airtemp'; '-50 50'; 'y'; 'humid'; '0.1 110'; 'y'; 'direct'; '-0.1 360.1'; 'y'; 'speed'; '-0.001 200'; 'y'; ' '};
          medita

         case 'met_light'
            MEXEC_A.MARGS_IN = {otfile; 'y'; 'pres'; '0.01 1500'; 'y'; 'ppar'; '-10 1500'; ;'y'; 'spar'; '-10 1500'; 'y'; 'ptir'; '-10 1500'; 'y'; 'stir'; '-10 1500'; 'y'; ' '};
            medita
	
         case 'tsg'
            MEXEC_A.MARGS_IN = {otfile; 'y'; 'temp_h'; '0 50'; 'y'; 'cond'; '0 10'; 'y'; ' '};
            medita

         case 'met_tsg'
            MEXEC_A.MARGS_IN = {otfile; 'y'; 'temp_h'; '0 50'; 'y'; 'temp_m'; '0 50'; 'y'; 'cond'; '0 10'; 'y'; 'fluo'; '0 10'; 'y'; 'trans'; '0 50'; 'y'; ' '};
            medita

         case {'sim' 'ea600m' 'ea600'}
            MEXEC_A.MARGS_IN = {otfile; 'y'; 'depth'; '20 10000'; 'y'; 'depth_uncor'; '20 10000'; 'y'; ' '};
            medita

         %case {'em120', 'em122'}
         %   MEXEC_A.MARGS_IN = {otfile; 'y'; 'swath_depth'; '20 10000'; 'y'; ' '};
         %   medita

      end
      unix(['/bin/rm ' wkfile '.nc']);
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
   if sum(strcmp(abbrev, {'met_tsg'}))
      %work on the latest file, which already be an edited version; always output to otfile
      if exist([otfile '.nc'])
         unix(['/bin/mv ' otfile '.nc ' wkfile '.nc']); infile1 = wkfile;
      else
         infile1 = infile;
      end
      switch abbrev
   
         case 'met_tsg' %***or check all the tsg types to see if it is already a field and if not add?***
            MEXEC_A.MARGS_IN = {infile1; otfile; '/'; 'cond temp_h'; 'y = gsw_SP_from_C(10*x1,x2,0)'; 'psal'; 'pss-78'; ' '};
            mcalc
	    
      end	 
      unix(['/bin/rm ' wkfile '.nc']);
   end


    
    get_cropt

    
end

