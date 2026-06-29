function samp_process(ptlist, varargin)
% function samp_process(ptlist, resartsam)
%
% wrapper script for discrete sample data 
%
% to load all available data from all available parameter types and add to
%   existing sam_*_all.nc file, either:  
% samp_process({'sbe35','sal','oxy','nut','co2','iso','cfc','chl'})
%   or
% samp_process('all')
%
% to restart sam_*_all.nc file before loading all available parameter
%   types:   
% samp_process('all', 1)
%
% to load just inorganic carbon (dic, talk, ph) data and add to existing
%   sam_*_all.nc file: 
% samp_process({'co2'})
%
% for each parameter type specified, calls msam_load then msam_merge
% with second (optional) input argument set to 1, first calls mfir_to_sam
%   and get_sensor_groups 

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%parameters to try if paramlist is 'all'
params = {'sbe35','sal','oxy','nut','co2','iso','cfc','chl'};
if ~iscell(ptlist) && strcmp(ptlist,'all')
    ptlist = params;
end

%if specified, restart sam_ file and populate with CTD
if nargin>1 && varargin{1}
    %delete sam_*_all file
    root_ctd = mgetdir('M_CTD');
    otfile = fullfile(root_ctd, ['sam_' mcruise '_all.nc']);
    if exist(otfile,'file')
        warning('deleting sam file: %s in 1 s',otfile)
        pause(1)
    end
    % find which stations have bottle firing files
    d = dir(fullfile(root_ctd,['fir_' mcruise '_*.nc']));
    stns = cellfun(@(x) split(x,'_'), {d.name}, 'UniformOutput', false);
    stns = cellfun(@(x) str2double(x{3}), stns);
    stns = stns(:)';
    for stn = stns
        %re-run to freshly add CTD data to sam file
        mfir_to_sam(stn)
    end
    %add serial numbers (already saved in .mat file)
    get_sensor_groups(stns,'samonly')
end

%now start loading parameter data
for pno = 1:length(ptlist)
    msam_load(ptlist{pno})
    msam_merge(ptlist{pno})
end

opt1 = 'outputs'; opt2 = 'columndata'; get_cropt
if exist('outtypes','var')
    for ono = 1:length(outtypes)
        if exist('outparams','var') && isfield(outparams,outtypes{ono})
            mout_columns('sam',outtypes{ono},outparams.(outtypes{ono}))
        else
            mout_columns('sam',outtypes{ono})
        end
    end
end


