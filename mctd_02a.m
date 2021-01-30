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

minit;
mdocshow(mfilename, ['renames variables in ctd_' mcruise '_' stn_string '_raw.nc (or _raw_noctm.nc) based on templates/ctd_renamelist.csv, adds position from underway stream (if available), applies automatic edits and cellTM (if selected)']);

% resolve root directories for various file types
root_templates = mgetdir('M_TEMPLATES');
root_ctd = mgetdir('M_CTD');

prefix = ['ctd_' mcruise '_'];

%if the noctm file exists, assume we should start there
%(and apply automatic edits to remove large spikes, and then apply
%align/ctm and save as _raw)***reapplying align necessary???***
infile1 = [root_ctd '/' prefix stn_string '_raw_noctm'];
infile = [root_ctd '/' prefix stn_string '_raw'];
if ~exist(m_add_nc(infile1), 'file');
    redoctm = 0;
else
    redoctm = 1;
    unix(['/bin/cp -p ' m_add_nc(infile1) ' ' m_add_nc(infile)]);
    unix(['chmod 644 ' m_add_nc(infile1)]); % write protect raw_noctm file
end

%change variable names and add units

%get list of names and units
renamefile = [root_templates '/ctd_renamelist.csv']; 
dsv = dataset('File', renamefile, 'Delimiter', ',');
scriptname = mfilename; oopt = 'ctdvars'; get_cropt
dsv.sbename = [dsv.sbename; ctdvars_add(:,1)];
dsv.varname = [dsv.varname; ctdvars_add(:,2)];
dsv.varunit = [dsv.varunit; ctdvars_add(:,3)];
if length(unique(dsv.sbename))<length(dsv.sbename)
    error(['There is a duplicate name in the list of variables to rename; use ctdvars_replace rather than ctdvars_add in opt_' mcruise]);
end
[varnames, junk, iiv] = mvars_in_file(dsv.sbename, infile);
dsv = dsv(iiv,:);
varnames_units = [];
for vno = 1:length(dsv)
    iir = find(strcmp(ctdvars_replace(:,1), dsv.sbename{vno}));
    if length(iir)==0
        varnames_units = [varnames_units; dsv.sbename{vno}; dsv.varname{vno}; dsv.varunit{vno}];
    else
        varnames_units = [varnames_units; dsv.sbename{vno}; ctdvars_replace{vno,2}; ctdvars_replace{vno,3}];
    end
end

%edit file names and units in header
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

% Use the mtposinfo/msposinfo to find position at bottom of cast time and
% update header
[d h] = mload(infile,'time','press',' ');
p = d.press;
kbot = min(find(p == max(p)));
tbot = d.time(kbot);
tbotmat = datenum(h.data_time_origin) + tbot/86400; % bottom time as matlab datenum
if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
    [botlat botlon] = msposinfo(tbotmat);
elseif strcmp(MEXEC_G.Mshipdatasystem,'techsas')
    [botlat botlon] = mtposinfo(tbotmat);
else
    botlat = []; botlon = [];
end
if length(botlat>0)
    latstr = sprintf('%14.8f',botlat);
    lonstr = sprintf('%14.8f',botlon);
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
end

%%%%%%%%% NaN variables that are in mcvars_list but not present for this station %%%%%%%%%
scriptname = mfilename; oopt = 'absentvars'; get_cropt
if length(absentvars)>0
    MEXEC_A.MARGS_IN = {infile; 'y'};
    for kabs = 1:length(absentvars)
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
            absentvars{kabs}
            'y = x+nan'
            ' '
            ' '];
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalib
end


%%%%%%%%% automatic edits %%%%%%%%%
if redoctm
    
    scriptname = mfilename; oopt = 'prectm_rawedit'; get_cropt
    
    %edit out scans when pumps are off, plus expected recovery times
    if length(pvars)>0
        MEXEC_A.MARGS_IN = {infile; 'y'};
        for no = 1:size(pvars,1)
            pmstring = sprintf('y = x1; pmsk = repmat([1:length(x2)], %d+1, 1)+repmat([-%d:0]'', 1, length(x2)); pmsk(pmsk<1) = 1; pmsk = sum(1-x2(pmsk),1); y(find(pmsk)) = NaN;', pvars{no,2}, pvars{no,2});
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; pvars{no,1}; [pvars{no,1} ' pumps']; pmstring; ' '; ' '];
            disp(['will edit out pumps off times plus ' num2str(pvars{no,2}) ' scans from ' pvars{no}])
        end
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
        mcalib2; end
    
    %scanedit (for additional bad scans)
    if length(sevars)>0
        MEXEC_A.MARGS_IN = {infile; 'y'};
        for no = 1:length(sevars)
            sestring = sprintf('y = x1; y(x2>=%d & x2<=%d);', sevars{no,2}, sevars{no,3});
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; sevars{no,1}; [sevars{no,1} ' scan']; sestring; ' '; ' '];
            disp(['will edit out scans from ' sevars{no,1} ' with ' sestring])
        end
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
        mcalib2
    end
    
    %remove out of range values
    if length(revars)>0
        MEXEC_A.MARGS_IN = {infile; 'y'};
        for no = 1:size(revars,1)
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; revars{no,1}; sprintf('%f %f',revars{no,2},revars{no,3}); 'y'];
            disp(['will edit values out of range [' sprintf('%f %f',revars{no,2},revars{no,3}) '] from ' revars{no,1}])
        end
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
        medita
    end
    
    %despike
    if length(dsvars)>0
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
