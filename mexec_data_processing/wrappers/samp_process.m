function samp_process(ptlist, varargin)
% function samp_process(ptlist, 'restartsam', [0], 'restartusam', [0])
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
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

%parameters to try if paramlist is 'all'
params = {'sal','oxy','nut','co2','iso','cfc','chl'};
if ~iscell(ptlist) && strcmp(ptlist,'all')
    ptlist = params;
end

pd = mexec_file_locations('procfiles','samp');
restartsam = 0;
restartusam = 0;
if nargin>1
    for no = 1:2:length(varargin)
        eval([varargin{no} ' = varargin{no+1};']);
    end
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
    % find which stations have bottle firing files
    d = dir(firfile.fir);
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
% if restartusam
%     %delete sam_ucsw file
%     if exist(pd.samu,'file')
%         warning('deleting underway sam file: %s in 1 s',pd.samu)
%         pause(1)
%         delete(pd.samu)
%     end
% opt1 = 'samp_proc'; opt2 = 'files'; samtyp = 'ulog'; get_cropt
% s = readtable(uway_sample_log_file);
% %rename, merge on data from surface_ocean*
% end

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


