function [mgrid, cdata, sdata] = gridhsec(cruise, varargin);
% function [mgrid, cdata, sdata] = gridhsec(cruise, varargin);
%
% wrapper, calls loadhdata, maphsec
%
% returns structures cdata and sdata containing CTD and sample data
% and structure mgrid containing gridded/mapped CTD and sample data plus derived variables (dynamic height)
%
% also saves
%
% option 1: use the same gridding methods as msec_run_mgridp (formerly run_mgridp_ctd), mgridp, m_maptracer
% option 2: use something more like objective mapping, i don't even know what was being done with ctd data before, possibly nothing? possibly just interpolating to coarser depth grid in mgridp. but recently it wasn't even calling mgridp.
%
% accepts more input formats, and doesn't use mexec/mstar functions
%
% input variables:
%    cruise: string cruise name (e.g. 'dy113')
%
% optional input variables:
%    section: string e.g. 'sr1b' or 'a23'
%    statind: list of station numbers to use (in order)
%    reload: 1 (default) to load ctd and sample data, 0 to read from
%       existing file (generated by previous run of gridhsec on this
%       cruise) and only do the gridding step
%    gstart, gstop, gstep: define pressure grid [defaults set by section]
%    xstatnumgrid***


readme = {};

for no = 1:2:length(varargin)
    eval([varargin{no} ' = varargin{no+1};'])
end

set_hsecpars

otfile = fullfile(predir, [info.section '_' cruise '_' info.season]);

if ~isfield(info, 'sbadflags')
    info.sbadflags = [3 4 9];
end
if ~isfield(info, 'cbadflags')
    info.cbadflags = [4 9];
end

%%%%% load and concatenate ctd and sample data %%%%%
file_listc = dir([info.ctddir info.ctdpat]);
file_lists = dir([info.samdir info.sampat]);

if ~isempty(file_listc)
   file_listc = struct2cell(file_listc); file_listc = file_listc(1,:)';
end
if ~isempty(file_lists)
   file_lists = struct2cell(file_lists); file_lists = file_lists(1,:)';
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

%***(in load_sdata:) check units, convert umol/L to umol/kg if necessary


%%%%% map both ctd and bottle data using same length scales and grid variables %%%%%

clear mgrid
mgrid.cruise = cruise; mgrid.section = info.section;
if strcmp(cruise,'soccom25')
    mgrid.xstatnumgrid = [cdata.statnum; [1:45 [46:54]+21]];
end

mgrid.method = 'msec_maptracer'; %use defaults
readme = [readme; 'ctd data gridded by linear interpolation in vertical (after filling uniform mixed layer)'];
readme = [readme; 'sample data as in m_maptracer, using CTD T,S for sigma'];

mgrid.sam_fill = 'smooth_nnv'; 
readme = [readme; 'sample grids filled using mapping with larger radius cutoffs, and finally nearest neighbour in each profile']; %***and allow asymmetric sigma?
mgrid.ctd_fill = 'sam';
readme = [readme; 'missing gridded ctd oxygen filled using gridded sample oxygen'];

mgrid = maphsec(cdata, sdata, mgrid);
otfileg = [otfile '_' mgrid.method];
save(otfileg, 'cdata', 'sdata', 'mgrid', 'info', 'readme');
