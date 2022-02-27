% mtsg_medav_clean_cal: clean and calibrate SBE45 tsg data
%
% Use: mtsg_medav_clean_cal
%
% runs on appended cruise file. This draft bak on jc069
% first reduce data to 1-minute bins, using median rather than mean;
% then apply cleanup and calibration using mcalib2, using function
% mtsg_cleanup, which can be constructed for each cruise. This function can
% discard data when the pumps were off, apply adjustments, etc.
%
% modded bak jr302 second SST

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

scriptname = 'ship'; oopt = 'ship_data_sys_names'; get_cropt
% bak jc211 ship_data_sys_names sets metpre and tsgpre

mdocshow(mfilename, ['averages to 1 minute and calls mtsg_cleanup to remove bad times from appended tsg file, producing ' tsgpre '_' mcruise '_01_medav_clean.nc'])
mdocshow(mfilename, ['calls m_apply_calibration to apply sal and temp calibrations set in opt_' mcruise ', writing to ' tsgpre '_' mcruise '_01_medav_clean_cal.nc'])

root_dir = mgetdir(tsgpre);
infile1 = fullfile(root_dir, [tsgpre '_' mcruise '_01']);
otfile1 = fullfile(root_dir, [tsgpre '_' mcruise '_01_medav_clean']); % 1-minute median data
otfile2 = fullfile(root_dir, [tsgpre '_' mcruise '_01_medav_clean_cal']); % 1-minute median data

if ~exist(m_add_nc(infile1),'file')
    error(['no tsg file ' infile1])
    return
end

scriptname = mfilename; oopt = 'tsg_editvars'; get_cropt
scriptname = mfilename; oopt = 'tsg_badlims'; get_cropt
h = m_read_header(infile1);
editvars = intersect(editvars, h.fldnam);

scriptname = 'ship'; oopt = 'avtime'; get_cropt
avtsg = round(avtsg);

if ~isempty(kbadlims) && ~isempty(editvars)
    
    %average
    MEXEC_A.MARGS_IN = {
        infile1
        otfile1
        ' '
        'time'
        sprintf('%d 1e10 60',avtsg)
        'b'
        };
    mavmed
    
    %remove badtimes and save
    [d,h] = mloadq(otfile1, '/');
    torg = datenum(h.data_time_origin);
    d.time = m_commontime(d.time,h.data_time_origin,0)/86400; %convert to matlab datenum
    clear dnew hnew
    hnew.fldnam = {}; hnew.fldunt = {}; hnew.comment = 'TSG bad time ranges removed';
    iib = [];
    if iscell(kbadlims)
        for kb = 1:size(kbadlims,1)
            iib = [iib find(d.time>=datenum(kbadlims{kb,1}) & d.time<=datenum(kbadlims{kb,2}))];
        end
    else
        for kb = 1:size(kbadlims,1)
            iib = [iib find(d.time>=kbadlims(kb,1) & d.time<=kbadlims(kb,2))];
        end
    end
    for vno = 1:length(editvars)
        dnew.(editvars{vno}) = d.(editvars{vno});
        dnew.(editvars{vno})(iib) = NaN;
        hnew.fldnam = [hnew.fldnam editvars{vno}];
        thisvar = strcmp(editvars{vno}, h.fldnam);
        hnew.fldunt = [hnew.fldunt h.fldunt(thisvar)];
    end
    %***necessary to calculate salinity using temp_housing?
    mfsave(otfile1, dnew, hnew, '-addvars');
    
else
    disp('no editvars found in file or no kbadlims set; skipping')
    return
end


%get calibrations to use
scriptname = mfilename; oopt = 'tsgcals'; get_cropt
%if found, apply
if isfield(tsgopts, 'calstr')
    calstr = select_calibrations(tsgopts.docal, tsgopts.calstr);
    if ~isempty(calstr)
        %load data
        [d,h] = mloadq(otfile1, '/');
        %apply calibrations
        [dcal, hcal] = apply_calibrations(d, h, calstr);
        if ~isempty(hcal.fldnam)
            %rename
            for vno = 1:length(hcal.fldnam)
                ii = strfind('_raw',hcal.fldnam{vno});
                if isempty(ii)
                    hcal.fldnam{vno} = [hcal.fldnam{vno} '_cal'];
                else
                    hcal.fldnam{vno} = hcal.fldnam{vno}(1:ii-1);
                end
            end
            if ~exist(m_add_nc(otfile2), 'file')
                mfsave(otfile2, d, h);
            end
            %recalculate salinity? probably not going to be able to
            %calibrate housing temperature
            %sometimes need to calculate salinity at earlier stage
            %(scs)?***
            if 0
                condvar = munderway_varname('condvar', h.fldnam, 1);
                tempvar = munderway_varname('tempvar', h.fldnam, 1);
                if ~isempty(condvar) && ~isempty(tempvar)
                    dt.psal = gsw_SP_from_C(10*dt.(condvar),dt.(tempvar),0)'; %we have S/m, gsw wants mS/cm
                    ht.fldnam = [ht.fldnam 'psal'];
                    ht.fldunt = [ht.fldunt 'pss-78'];
                end
            end
            mfsave(otfile2, dcal, hcal, '-addvars');
        end
    end
end

