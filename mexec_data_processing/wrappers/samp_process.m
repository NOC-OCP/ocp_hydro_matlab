function samp_process(ptlist, varargin)
% function samp_process(ptlist, 'restartsam', [0], 'restartusam', [0])
%
% wrapper script for loading and processing sample data, from both Niskins
% and underway 
%
% to load all available data from all available parameter types and add to
%   existing sam_*_all.nc file, either:  
% samp_process({'sbe35','sal','oxy','nut','co2','iso','cfc','chl'})
%   or
% samp_process('all')
%
% to restart sam_*_all.nc file before loading all available parameter
%   types:   
% samp_process('all', 'restartsam', 1)
%
% to load just inorganic carbon (dic, talk, ph) data and add to existing
%   sam_*_all.nc file: 
% samp_process({'co2'})
%
% for each parameter type specified, calls msam_load then msam_merge
% with second (optional) input argument set to 1, first calls mfir_to_sam
%   and get_sensor_groups 

m_common

%parameters to try if paramlist is 'all'
params = {'sal','oxy','nut','co2','iso','cfc','chl'};
if strcmp(MEXEC_G.datatypes.tref,'sbe35')
    params = [params 'sbe35'];
end
if ~iscell(ptlist)
    if strcmp(ptlist,'all')
        ptlist = params;
    else
        ptlist = {ptlist};
    end
end
a = setdiff(ptlist,params);
if ~isempty(a)
    warning('bottle sample params not recognised: ')
    fprintf(1,'%s ',a{:})
    fprintf(1,'\n')
    ptlist = intersect(params,ptlist);
end

opt1 = 'samp_proc'; opt2 = 'samp_infiles'; run(MEXEC_G.opt_cruise)
opt1 = 'pfiles'; run(MEXEC_G.opt_cruise)

restartsam = 0; restartusam = 0;
if nargin>1
    for no = 1:2:length(varargin)
        eval([varargin{no} ' = varargin{no+1};']);
    end
end
if ~exist(pfiles.samp_ctd,'file')
    restartsam = 1;
end
if ~exist(pfiles.samp_uway,'file')
    restartusam = 1;
end
%if specified, restart sam_ file and populate with CTD, and samu_ file and
%populate with underway data
if restartsam
    %delete sam_*_all file
    if exist(pd.samc,'file')
        warning('deleting sam file: %s in 1 s',pd.samc)
        pause(1)
        delete(pd.samc)
    end
    %find list of stations available
    npat = sprintf(pfiles.ctd_nisk,'*');
    d = dir(npat);
    npat = split(npat,'*');
    stns = cellfun(@(x) stru2double(replace(replace(x,npat{1},''),npat{2},'')), {d.name});
    ctd_process(stns, 'niskins')
end
if restartusam
    %delete sam_ucsw file
    if exist(pd.samu,'file')
        warning('deleting underway sam file: %s in 1 s',pd.samu)
        pause(1)
        delete(pd.samu)
    end
    uway_process('samples')
    s = readtable(uway_sample_log_file); %the equivalent of a .bl file
    %rename, merge on data from surface_ocean***
end

%now start loading parameter data
for pno = 1:size(ptlist,1)
    msam_load(ptlist(pno,:))
    msam_merge(ptlist(pno,:))
end

opt1 = 'outputs'; opt2 = 'columndata'; run(MEXEC_G.opt_cruise)
if exist('outtypes','var')
    for ono = 1:length(outtypes)
        if exist('outparams','var') && isfield(outparams,outtypes{ono})
            mout_columns('sam',outtypes{ono},outparams.(outtypes{ono}))
        else
            mout_columns('sam',outtypes{ono})
        end
    end
end


