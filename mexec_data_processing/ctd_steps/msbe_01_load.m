function varargout = msbe_01_load(stn)
% msbe_01_load(stn)
% stns = msbe_01_load(stn)
%
% read in ctd data from SBE .cnv file (specified in opt_cruise),
% rename variables based on cruise options, and add units if not present,
% add NaN fields for variables that are not present on this cast (as set in
% opt_cruise)
% add position at bottom of cast to header
%
% output: _cnv.nc and (optionally) stns, list of stns from one yo-yo cast
% (if split_castnos_scans set in opt_cruise, ctd_proc, ctd_raw_extra)
%
% calls:
%     msbe_to_mstar
%     mheadr
%     mcalib
%

%%%%% setup %%%%%

m_common; 
opt1 = 'ctd_proc'; opt2 = 'ctd_infiles'; run(MEXEC_G.opt_cruise);
if strcmp(infiles.ctd_raw,'no_file')
    %use this for casts after the first in a yo-yo file
    varargout{1} = [];
    return
end
opt1 = 'pfiles'; run(MEXEC_G.opt_cruise);
dataname = sprintf('ctd_%s_%s',MEXEC_G.mcruise,stn_string);
infile = sprintf(infiles.ctd_raw,stn_string);
otfile = sprintf(pfiles.ctd_raw,stn_string);
if MEXEC_G.quiet<=1; fprintf(1,'converting %s to %s\n',infile,rawfile); end

% input and output files
if ~exist(infile,'file') && isfield(MEXEC_G,'mexec_shell_scripts')
    css = fullfile(MEXEC_G.mexec_shell_scripts,'data_to_ws','ctd_syncscript.sh');
    if exist(css,'file')
        system(['bash ' css]);
    end
end
if ~exist(infile,'file')
    warning(['file ' infile ' not found; make sure it''s there (and not gzipped) and return to try again, or ctrl-c to quit'])
    pause
end


%%%%% convert to mstar %%%%%

%load data
[d,h] = msbe_to_mstar(infile,'y','y');
if ~ismember(h.fldnam,'scan')
    error('scan is required for processing %s',cnvfilename)
end
if ~ismember(h.fldnam,'time')
    warning('you are missing time variable from %s, \ndid you forget to run DatCNV with time elapsed?',cnvfile)
end
if ~isempty(setdiff({'pumps','latitude','longitude'},h.fldnam))
    warning('you are missing pump status, latitude, and/or longitude from %s, \ndid you forget to export them in DatCnv?',cnvfile)
end

% extra steps for special cases:
% - different variables for this cast are in different files, but all files
%   contain the same scans; use extrasource to list files and extravars to
%   list the variables to add
% - one variable such as time elapsed needs to be calculated from another
%   such as scan; use extrasource to give the expression to be evaluated
%   and extravars to specify the new names and units
% - the cast is split across more than one file (e.g. data acquisition was
%   stopped and restarted during the cast); use append_stn_strings to
%   specify the additional files to combine, and append_scan_offsets to
%   specify the number to add to scan in each to match up 
%  - more than one cast is contained in a single file (e.g. yo-yo casts
%   where acquisition was not stopped and restarted at each shallow
%   turnaround point); use 

opt1 = 'ctd_proc'; opt2 = 'ctd_raw_extra'; run(MEXEC_G.opt_cruise)

if ~isempty(extrasource)
    %evaluate extrasource to calculate or change variables
    if MEXEC_G.quiet<=1; fprintf(1,'adding selected variables to ctd_%s_%s_raw.nc\n',mcruise,stn_string); end
    [d, h] = mctd_extra(d, h, extravars, extrasource);
end

if ~isempty(append_stn_strings)
    %load additional files, and append
    for fno = 1:length(append_stn_strings)
        addfile = sprintf(pd.ctdraw,append_stn_strings{fno});
        [dn, hn] = msbe_to_mstar(addfile,'y','y');
        if length(append_scan_offset)<fno || isnan(append_scan_offset(fno))
            %calculate from times
            append_scan_offsets(fno) = round((dn.time(1)-d.time(1))*24)+(d.scan(1)-dn.scan(1));
            warning('update comb_scan_off in opt_%s ctd_proc, ctd_raw_extra case to %d (it is also used by mfir_01_load)',mcruise,comb_scan_off(fno));
        end
        dn.scan = dn.scan + append_scan_offsets(fno);
        h.comment = [h.comment sprintf('\noffsetting ctd file %s by %d scans and appending to ctd file %s',append_stn_strings{fno},append_scan_offsets(fno),stn_string)];
        [d, h] = merge_mvars(d, h, dn, hn, 'scan', 1); %***no sort?
    end
    out.append_stns = append_stn_strings;
end

if isempty(split_castnos_scans)
    %normal, one cast per file
    mfsave(otfile, d, h)
    %add position at bottom of cast (from .cnv file if available, otherwise from underway)
    getpos_for_ctd(otfile,'write');

else

    d0 = d; h0 = h;
    if size(split_castnos_scans,2)==1
        ii = find(d0.press<10); ii = [ii(diff(ii)>24*60*5)];
        ha(1) = subplot(211); plot(d0.scan, d0.press); grid; hold on
        ha(2) = subplot(212);
        for no = 1:length(ii)-1
            iic = ii(no):ii(no+1);
            axes(ha(1)); hl = plot(d0.scan(iic),d0.press(iic),'.r');
            axes(ha(2)); plot(d0.scan(iic),d0.press(iic)); ylim([-2 15]); grid
            [x(no),y(no)] = ginput(1);
            axes(ha(1)); plot(d0.scan(d0.scan>x(no)),d0.press(d0.scan>x(no)));
            delete(hl)
        end
        delete(ha(2))
        set(ha(1),'position',[.1 .1 .85 .85])
        ylim([-2 15])
        keyboard
    end
    cb = [1; cell2mat(split_castnos_scans(:,2))];
    for fno = 1:size(split_castnos_scans,1)
        otfile = sprintf(pfiles.ctd_raw,split_castnos_scans{fno,1});        
        m = d0.scan>=cb(fno) & d0.scan<cb(fno+1);
        d = structfun(@(x) x(m), d0, 'UniformOutput', false);
        h = h0; h.comment = [h.comment sprintf('\n split from original, multi-cast %s using scan range %d to %d',infile,cb(fno),cb(fno+1))];
        %write file
        mfsave(otfile, d, h)
        %add position at bottom of cast (from file itself if available, otherwise from underway)
        getpos_for_ctd(otfile, 'write');
    end
    out.split_stns = cellfun(@(x) str2double(x), split_castnos_scans(:,1)); %***these are required to be numeric?
end

%other special cases e.g. typos in S/Ns
opt1 = 'ctd_proc'; opt2 = 'header_edits'; run(MEXEC_G.opt_cruise)

if exist('out','var')
    varargout{1} = out;
else
    varargout{1} = [];
end

function [d, h] = mctd_extra(d, h, extravars, extrasource)

m_common

d0 = d; h0 = h;
ow = intersect(h0.fldnam,extravars);
if ~isempty(ow) && MEXEC_G.quiet<=1
    warning('overwriting variables %s,',ow{:});
end
for fno = 1:length(extrasource)
    if exist(extrasource{fno},'file')
        [dn, hn] = msbe_to_mstar(extracnv{fno},'y','y');
        %don't use merge_mvars because it might keep some old data;
        %instead, merge here
        [~,i0,in] = intersect(d.scan, dn.scan, 'stable');
        for vno = 1:length(extravars)
            d.(extravars{vno}) = NaN+d.scan;
            d.(extravars{vno})(i0) = dn.(extravars{vno})(in);
            h.fldnam = [h.fldnam extravars{vno}];
        end
        [h.fldnam,~,ib] = intersect(extravars,hn.fldnam,'stable');
        h.fldunt = hn.fldunt(ib);
        if isfield(h,'fldserial')
            h.fldserial = hn.fldserial(ib);
        end
        h.comment = [h0.comment sprintf('\nwith parameters added from sbe file %s',extracnv{fno})];
    else
        eval(extrasource{fno})
        m = strcmp(extravars{1,fno},h.fldnam);
        if sum(m)
            h.fldunt{m} = extravars{2,fno};
            if size(extravars,1)>2
                h.fldserial{m} = extravars{3,fno};
            end
            h.comment = [h0.comment sprintf('\nrecalculated parameter %s',extrasource{fno})];
        else
            h.fldnam = [h.fldnam extravars(1,fno)];
            h.fldunt = [h.fldunt extravars(2,fno)];
            if size(extravars,1)>2
                h.fldserial = [h.fldserial extravars{3,fno}];
            else
                h.fldserial = [h.fldserial 'n/a'];
            end
            h.comment = [h0.comment sprintf('\nadded parameter %s',extrasource{fno})];
        end
    end
end


