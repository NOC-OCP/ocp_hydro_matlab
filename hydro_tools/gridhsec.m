function [mgrid, cdata, sdata] = gridhsec(cruise, varargin)
% [mgrid, cdata, sdata] = gridhsec(cruise, varargin);
%
% wrapper, calls loadhdata, maphsec
%
% returns structures cdata and sdata containing CTD and sample data
% and structure mgrid containing gridded/mapped CTD and sample data plus derived variables (dynamic height)
%
% also saves in two files, one containing cdata and sdata, the other
% containing mgrid as well
%
% option 1: use the same gridding methods as msec_run_mgridp (formerly run_mgridp_ctd), mgridp, m_maptracer
% option 2: use something more like objective mapping, i don't even know what was being done with ctd data before, possibly nothing? possibly just interpolating to coarser depth grid in mgridp. but recently it wasn't even calling mgridp.
%
% locations of files to load, QC, and mapping parameters can be passed as
%     input arguments (see below) or set by a file 
%
% input variables:
%    cruise: string cruise name (e.g. 'dy113')
%
% optional parameter-value input variable pairs:
%    reloadc, reloads: 1 (default) to load ctd or sample data,
%        respectively, 0 to read from existing file (generated by previous
%        run of gridhsec on this cruise) and only do the gridding step
%    hsecpars_file: name of .m file on path in which to look up information
%        about cruise (default: set_hsecpars)
%    info: structure of info about cruise parameters, if not set by the
%        hsecpars_file: 
%      info.section: string specifying section in multi-section cruise
%          (e.g. 'sr1b' or 'a23') 
%      info.statind: list of station numbers to use (in order)
%    mgrid: structure of info about mapping parameters, if not set by the
%        hsecpars_file:
%      mgrid.xstatnumgrid, mgrid.zstatnumgrid: 
%
%
% e.g. to specify section for multi-section cruise: 
%     [mgrid, cdata, sdata] = gridhsec(cruise, 'info.section', 'sr1b', 'info.statind', [31:-1:2]);
% e.g. to get cruise and gridding parameters from a different file: 
%     [mgrid, cdata, sdata] = gridhsec(cruise, 'hsecpars_file', 'set_hsecpars_ezm');


%defaults
hsecpars_file = 'set_hsecpars';

clear info
info.sbadflags = [3 4 9];
info.cbadflags = [4 9];
info.ctdout = 0; 
info.samout = 0;
info.expocode = '';
readme = {};

%run through optional inputs once in case section is needed by hsecpars_file
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end
%get cruise info and mapping parameters from file
scriptname = mfilename; eval(hsecpars_file)
%run through optional inputs again to overwrite any set in hsecpars_file
for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end

if ~isfield(mgrid,'method'); mgrid.method = 'msec_maptracer'; end
if strcmp(mgrid.method,'msec_maptracer')
    readme_g = {'ctd data gridded by linear interpolation in vertical (after filling uniform mixed layer)'};
    readme_g = [readme_g; 'sample data as in m_maptracer, using CTD T,S for sigma'];
else
    readme_g = {};
end

%fill with defaults (for parameters not set)
if ~isfield(mgrid,'sam_fill')
    mgrid.sam_fill = 'smooth_nnv';
    readme_g = [readme_g; 'sample grids filled using mapping with larger radius cutoffs, and finally nearest neighbour in each profile']; %***and allow asymmetric sigma?
end
if ~isfield(mgrid,'ctd_fill')
    mgrid.ctd_fill = 'sam';
    readme_g = [readme_g; 'missing gridded ctd oxygen filled using gridded sample oxygen'];
end

%output files
if ~exist('otfile','var')
    otfile = fullfile(predir, 'mapped', [info.section '_' cruise '_' info.season]);
end
if ~exist('otfileg','var')
    otfileg = [otfile '_' mgrid.method];
end

%%%%% load and concatenate ctd and sample data %%%%%
file_listc = dir(fullfile(info.ctddir, info.ctdpat));
if ~isempty(file_listc)
   file_listc = struct2cell(file_listc); file_listc = file_listc(1,:)';
end
if isfield(info, 'samfile')
    file_lists = {};
    for no = 1:length(info.samfile)
        a = dir(fullfile(info.samdir, info.samfile{no}));
        a = struct2cell(a);
        file_lists = [file_lists; a(1)];
    end
else
    file_lists = dir(fullfile(info.samdir, info.sampat));
    if ~isempty(file_lists)
        file_lists = struct2cell(file_lists); file_lists = file_lists(1,:)';
    end
end

%if multiple ctd files, probably by station; if exchange format, try to only load the ones we need
if isfield(info, 'statind') && length(file_listc)>1
    try
        if contains(file_listc(1), '_ct1.csv')
            iiu = strfind(file_listc{1}, '_');
            ii = strfind(file_listc{1},'_ct1.csv');
            iiu = iiu(iiu<ii);
            f = cell2mat(file_listc);
            f = str2num(f(:,iiu(end-1)+1:iiu(end)-1));
        elseif contains(file_listc(1), '_cal.2db.mat')
            ii = strfind(file_listc{1}, '_cal.2db.mat');
            f = cell2mat(file_listc);
            f = str2num(f(:,ii-3:ii-1));
        end
        if ~isempty(f)
            [~,ia,ib] = intersect(f, info.statind);
            file_listc = file_listc(ia);
            info.statnum = info.statind(ib);
        end
    catch
        %fail/default to just loading full list
    end
end

coordv = {'lat' 'lon' 'press' 'statnum' 'niskin'};

%%%%% load ctd data %%%%%
if ~exist('reloadc','var'); reloadc = 1; end
if reloadc
    if isempty(file_listc); error('no ctd files'); end
    load_cdata
    save(otfile, 'cdata');
    reloads = 1; %if ctd data reloaded, also reload sample data, because ctd data used to mask
else
    load(otfile, 'cdata');
end

%%%%% load sample data %%%%%
if ~exist('reloads','var'); reloads = 1; end
if reloads
    if isempty(file_lists); error('no sample files'); end
    load_sdata
    save(otfile, '-append', 'sdata');
else
    load(otfile, 'sdata')
end

%%%%% check/convert units, check/apply calibrations/adjustments %%%%%
if reloadc || reloads
    quick_qc
    save(otfile, '-append', 'cdata', 'sdata');
end

%%%%% map both ctd and bottle data using same length scales and grid variables %%%%%

mgrid.cruise = cruise; 
mgrid.section = info.section;
mgrid = maphsec(cdata, sdata, mgrid);
readme = [readme; readme_g{:}];
save(otfileg, 'cdata', 'sdata', 'mgrid', 'info', 'readme');
