% mctd_02a: rename SBE variable names
%
% Use: mctd_02a        and then respond with station number, or for station 16
%      stn = 16; mctd_02;
%
% The input list of variable names, example filename ctd_jr193_renamelist.csv
%    is a comma-delimeted list of vars to be renamed
%    The format of each line is
%    oldname,newname,newunits
% The set of names is parsed and written back to ctd_jr193_renamelist_out.csv
% The set of names can be prepared in any unix text editor.
% It can also be prepared in excel and saved as csv, but on BAK's
% mac this generates csv files with c/r instead of n/l. Thus the
% _out.csv file is more suitable for editing on unix.
%
% This also adds position from the underway (techsas or scs) stream to the header
%
% After mheadr, the _raw.nc file is write protected

minit; scriptname = mfilename;
mdocshow(scriptname, ['renames variables in ctd_' mcruise '_' stn_string '_raw.nc (or _raw_noctm.nc) based on templates/ctd_renamelist.csv, adds position from underway stream (if available), applies automatic edits and cellTM (if relevant)']);

% resolve root directories for various file types
root_templates = mgetdir('M_TEMPLATES');
root_ctd = mgetdir('M_CTD');

prefixt = ['ctd_'];
prefix = ['ctd_' mcruise '_'];

%if the noctm file exists, assume we should start there
%(and apply automatic edits to remove large spikes, and then apply align/ctm and save as _raw)
infile1 = [root_ctd '/' prefix stn_string '_raw_noctm'];
infile = [root_ctd '/' prefix stn_string '_raw'];
if ~exist(m_add_nc(infile1), 'file');
   doctm = 0;
else
   doctm = 1;
   unix(['/bin/cp -p ' m_add_nc(infile1) ' ' m_add_nc(infile)]);
   unix(['chmod 644 ' m_add_nc(infile1)]); % write protect raw_noctm file
end

%***this path doesn't really allow for manual removal of large spikes before celltm***
%***but that shouldn't be necessary since if they're large enough to make a difference
%the median despiker shoud get them***

renamefile = [root_templates '/' prefixt 'renamelist.csv']; % read list of var names and units
renamefileout = [root_templates '/' prefixt 'renamelist_out.csv']; % write list of var names and units

cellall = mtextdload(renamefile,','); % load all text

clear snamesin snamesot sunits
for kline = 1:length(cellall)
    cellrow = cellall{kline}; % unpack rows
    snamesin{kline} = m_remove_outside_spaces(cellrow{1});
    snamesot{kline} = m_remove_outside_spaces(cellrow{2});
    sunits{kline} = m_remove_outside_spaces(cellrow{3});
end
snamesin = snamesin(:);
snamesot = snamesot(:);
sunits = sunits(:);
numvar = length(snamesin);

sunique = unique(snamesin);
if length(sunique) < length(snamesin)
    m = 'There is a duplicate name in the list of variables to rename';
    error(m);
end

fidmctd02 = fopen(renamefileout,'w'); % save back to out file
for k = 1:numvar
    fprintf(fidmctd02,'%s%s%s%s%s\n',snamesin{k},',',snamesot{k},',',sunits{k});
end
fclose(fidmctd02);

hin = m_read_header(infile); % get var names in file

snames_units = {};
for k = 1:numvar
    vnamein = snamesin{k};
    kmatch = strmatch(vnamein,hin.fldnam,'exact');
    if ~isempty(kmatch) % var exists in the raw file
        snames_units = [snames_units snamesin{k} snamesot{k} sunits{k}];
    end
end
snames_units = snames_units(:);

MEXEC_A.MARGS_IN_1 = {
    infile
    'y'
    '8'
    };
MEXEC_A.MARGS_IN_2 = snames_units;
MEXEC_A.MARGS_IN_3 = {
    '-1'
    '-1'
    };
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3];
mheadr

% JC032: Now fix position in header; assigned position is from when press was
% equal to deepest value on cast. Use the new mtposinfo.
% find time of bottom of cast
[d h] = mload(infile,'time','press',' ');
p = d.press;
kbot = min(find(p == max(p)));
tbot = d.time(kbot);
tbotmat = datenum(h.data_time_origin) + tbot/86400; % bottom time as matlab datenum
if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
    [botlat botlon] = msposinfo(tbotmat);
else % techsas
    [botlat botlon] = mtposinfo(tbotmat);
end
latstr = sprintf('%14.8f',botlat);
lonstr = sprintf('%14.8f',botlon);

%--------------------------------
MEXEC_A.MARGS_IN = {
infile
'y'
'5'
latstr
lonstr
' '
' '
};
mheadr
%--------------------------------

%%%%%%%%% stations deeper than 6000m have fluor and trans removed %%%%%%%%%
% bak on jc191
oopt = 'absentvars'; get_cropt % set a list of absentvars by station
for kabs = 1:length(absentvars)
    absvarname = absentvars{kabs};
    % set absentvar to nan
    MEXEC_A.MARGS_IN = {
        infile
        'y'
        absvarname
        'y = x+nan'
        ' '
        ' '
        ' '
        };
    mcalib
end


%%%%%%%%% corrections %%%%%%%%%

oopt = 'corraw'; get_cropt
if doctm
  
  %edit out scans when pumps are off, plus expected recovery times
  MEXEC_A.MARGS_IN = {infile; 'y'};
  for no = 1:size(pvars,1)
      pmstring = sprintf('y = x1; pmsk = repmat([1:length(x2)], %d+1, 1)+repmat([-%d:0]'', 1, length(x2)); pmsk(pmsk<1) = 1; pmsk = sum(1-x2(pmsk),1); y(find(pmsk)) = NaN;', pvars{no,2}, pvars{no,2});
      MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; pvars{no,1}; [pvars{no,1} ' pumps']; pmstring; ' '; ' '];
      disp(['will edit out pumps off times plus ' num2str(pvars{no,2}) ' scans from ' pvars{no}])
  end
  MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
  mcalib2
  
  %scanedit (for additional bad scans)
  if length(sevars)>0
     MEXEC_A.MARGS_IN = {infile; 'y'};
      for no = 1:length(sevars)
         MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; sevars{no}; [sevars{no} ' scan']; sestring{no}; ' '; ' '];
	     disp(['will edit out scans from ' sevars{no} ' with ' sestring{no}])
      end
      MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
      mcalib2
   end

   %remove out of range values
   MEXEC_A.MARGS_IN = {infile; 'y'};
   for no = 1:size(revars,1)
      MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; revars{no,1}; sprintf('%f %f',revars{no,2},revars{no,3}); 'y'];
	  disp(['will edit values out of range [' sprintf('%f %f',revars{no,2},revars{no,3}) '] from ' revars{no,1}])
   end
   MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
   medita
   
   %despike
   nds = 2;
   while nds<=size(dsvars,2)
      MEXEC_A.MARGS_IN = {infile; 'y'};
      for no = 1:size(dsvars,1)
         MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; dsvars{no,1}; dsvars{no,1}; sprintf('y = m_median_despike(x1, %f);', dsvars{no,nds}); ' '; ' '];
         disp(['will despike ' dsvars{no,1} ' using threshold ' sprintf('%f', dsvars{no,nds})])
      end
      MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
      mcalib2
      nds = nds+1;
   end


   %apply align and celltm corrections
   MEXEC_A.MARGS_IN = {
      infile
      'y'
      'cond1'
      'time temp1 cond1'
      'y = ctd_apply_celltm(x1,x2,x3);'
      ' '
      ' '
      'cond2'
      'time temp2 cond2'
      'y = ctd_apply_celltm(x1,x2,x3);'
      ' '
      ' '
      };
   for no = 1:length(ovars)
      MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
        ovars{no}
	    ['time ' ovars{no}]
	    'y = interp1(x1,x2,x1+5);'
	    ' '
	    ' '
	    ];
   end
   MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
   mcalib2
   
end


unix(['chmod 444 ' m_add_nc(infile)]); % write protect raw file
