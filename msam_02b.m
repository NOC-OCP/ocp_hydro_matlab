% msam_02b: adjust sample flags in sam_cruise_nnn files
% 1) as specified in file ctd/ASCII_FILES/bottle_data_flags.m
% 2) to be consistent with niskin flags
%
% for efficiency, after flags from bottle_data_flags.m are applied,
% bottle_data_flags.m is rewritten with these lines commented out
%
% Use: msam_02b        and then respond with station number, or for station 16
%      stn = 16; msam_02b;

scriptname = 'msam_02b';
minit
mdocshow(scriptname, ['changes (where necessary) sample value flags in sam_' mcruise '_' stn_string '.nc, 1) as specified in bottle_data_flags.txt; 2) so they are consistent with Niskin flags']);

root_ctd = mgetdir('M_CTD');
root_asc = mgetdir('M_CTD_CNV');

prefix1 = ['sam_' mcruise '_'];
infile1 = [root_ctd '/' prefix1 stn_string];
infile2 = [root_asc '/bottle_data_flags.txt']; %not making this name a cruise option because it needs to be a m-file


%%%%%%%%%
if exist(infile2)

   fid = fopen(infile2, 'r'); 
   a = textscan(fid, '%s %d %d %d', 'delimiter', ','); 
   fclose(fid); 
   vfnames = a{1};
   sampnums = double(a{2});
   flags0 = double(a{3});
   flags = double(a{4});
   
   iis = find(floor(sampnums/100)==stnlocal & flags~=flags0 & ~strncmp('%', vfnames, 1));

   if length(iis)>0
      vfnames = vfnames(iis); sampnums = sampnums(iis); 
      flags0 = flags0(iis); flags = flags(iis);
      stns = floor(sampnums/100); nisks = sampnums-stns*100;

      MEXEC_A.MARGS_IN = {
         infile1
    	 'y'
	     };

      flds = unique(vfnames);

      for fno = 1:length(flds)
         iisf = find(strcmp(flds{fno}, vfnames));
         %check for duplicate lines
         [samps,ia,ic] = unique(sampnums(iisf), 'last');
         if length(samps)<length(iisf)
            warning(['duplicate lines for ' flds{fno} ' station ' stn_string '; applying last'])
	        %keyboard
	        iisf = iisf(ia);
         end
      
         %make a string of all the positions to change for this flag
	     calstr = ['y = x2; '];
	     for sno = 1:length(iisf)
	        calstr = [calstr sprintf('y(x1==%d) = %d; ', nisks(iisf(sno)), flags(iisf(sno)))];
         end

         %append to MEXEC_A.MARGS_IN
	     MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN
	        flds{fno}
	        sprintf('position %s', flds{fno})
	        calstr
	        ' '
	        ' '
	        ];
      end
      
      %apply modifications
      MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN
         ' '
	     ];
      mcalib2

      %re-write file with lines for this station commented out (all of them, not just the ones applied)
      fid = fopen(infile2, 'r');
      a = 'start'; flines = {};
      while length(a)>1
         a = fgetl(fid);
	     flines = [flines; a];
      end
      flines = flines(1:end-1);
      fclose(fid); 
      fid = fopen(infile2, 'w');
      for no = 1:length(flines)
         if ismember(no, iis)
            fprintf(fid, '%%%s\n', flines{no}); %comment out
         else
	        fprintf(fid, '%s\n', flines{no}); %unchanged
	     end
      end
      fclose(fid);
      
   end
   
end

%%%%%%%%% make flags match niskin flags %%%%%%%%%

h = m_read_header(infile1);
%index for bottle quality flag
bflagind = find(strcmp('bottle_qc_flag', h.fldnam));
%indices for bottle sample flags
flaginds = [];
for no = 1:length(h.fldnam)
   if length(strfind(h.fldnam{no}, 'flag'))>0 & ~strcmp(h.fldnam{no}, 'sbe35flag')
      flaginds = [flaginds no];
   end
end
flaginds = setdiff(flaginds, bflagind);

%set sample flags to be consistent with niskin flags
%nflagstr = 'y = x2; y((x1==4 | x1==3) & (x2==2 | x2==3 | x2==6)) = 4; y(x1==9) = 9;';
nflagstr = 'y = x2; y((x1==4) & (x2==2 | x2==3 | x2==6)) = 4; y((x1==3) & (x2==2 | x2==3 | x2==6)) = 3; y(x1==9) = 9;'; %ylf on jr18002, to facilitate checking for importance of niskin leaks first

MEXEC_A.MARGS_IN = {infile1; 'y'};
if 0
   %temporary jc159: do something special for this one
   flaginds = setdiff(flaginds, 'del18o_bgs_flag'); 
   MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; 
       'del18o_bgs_flag'; 
       'bottle_qc_flag del18o_bgs_flag botpsalflag'
       ['y = x2; y(x3<5) = 1; ' nflagstr(8:end)] %first set d18o flags to 1 where sal sample was taken
       ' '
       ' '
       ];
end
for no = 1:length(flaginds)
   MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN
   h.fldnam{flaginds(no)}
   sprintf('bottle_qc_flag %s', h.fldnam{flaginds(no)})
   nflagstr
   ' '
   ' '
    ];
end
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
mcalib2
