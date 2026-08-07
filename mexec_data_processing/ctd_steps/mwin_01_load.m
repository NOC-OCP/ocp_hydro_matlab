function mwin_01_load(stn)

% mwin_01_load(stn)
% read in winch data corresponding to a CTD station
%
% Original version for JC031/032 accesses data 
% Revised version by BAK for di344 Oct 2009
% Further revision by BAK 15 Nov 2009 intended to make it work equally well
% on SCS (JCR) and Techsas (Discovery/Cook) files
%
% Assumes file ctd_cruise_stn_psal.nc exists. Times taken from this file,
% with an extra 600 seconds added at each end
%
% Script includes mcalc and datpik to ensure data are properly monotonic in
% time. Presumably BAK found some files sometime that were not monotonic.
%
% Additional option introduced by bak on jc159 15 April 2018 in opt_jc159 so that
% times can be specified to enable winch data to be read in when there are
% no ctd data, or to override times derived from ctd files. If no cruise and station-specific
% case is provided, times are taken from ctd file as usual.

m_common
if MEXEC_G.quiet<=1; fprintf(1,'adding winch data to %s\n',sprintf(winfile.win,stn_string)); end

% resolve root directories for various file types
pd = mexec_file_locations('procfiles','ctd');
infile1 = sprintf(pd.ctd1,stn_string);
pd = mexec_file_locations('procfiles','win');
winfile = sprintf(pd.winfile,stn_string);
wkfile3 = fullfile(MEXEC_G.MDIRLIST.M_CTD_WIN, ['wk_' opt1 '_' datestr(now,30)]);
dataname = pd.winname;


%--------------------------------
% create rvs starts and end times
time_window = [-600 800];
winch_time_start = nan;
winch_time_end = nan;
opt1 = mfilename; opt2 = 'winchtime'; get_cropt;

% bak on jc159 15 april 2018: need to be able to read in some winch data 
% on swivel test stations where there are no ctd files; new cruise opt to set
% winch_time_start and winch_time_end; example in opt_jc159
% this option can also be used to set winch start and end times different
% from ctd times, eg if CTD comms are lost when termination fails.
if exist('winch_time_start','var') && ~isnan(winch_time_start) && ~isnan(winch_time_end)
    t_start = datenum(winch_time_start);
    t_end = datenum(winch_time_end);
else
    h_in=m_read_header(infile1);
    k_time=find(strcmp('time',h_in.fldnam));
    if isempty(h_in.data_time_origin)
        t_start=m_commontime(h_in.alrlim(k_time),h_in.fldunt{k_time},'datenum')+time_window(1)/86400;
        t_end=m_commontime(h_in.uprlim(k_time),h_in.fldunt{k_time},'datenum')+time_window(2)/86400;
    else
        t_start=datenum(h_in.data_time_origin)  + (h_in.alrlim(k_time)+time_window(1))/86400;
        t_end=datenum(h_in.data_time_origin)+(h_in.uprlim(k_time)+time_window(2))/86400;
    end
end

t_start_vec=datevec(t_start);
t_end_vec=datevec(t_end);

daynum_start=t_start-datenum([t_start_vec(1) 1 1 0 0 0]);
daynum_start=1+floor(daynum_start);

daynum_end=t_end-datenum([t_end_vec(1) 1 1 0 0 0]);
daynum_end=1+floor(daynum_end);

switch MEXEC_G.Mship
    case 'sda'
        rvsstreamname = 'winch_sda';
    otherwise
        rvsstreamname='winch';
end
datapupflags='';
yy_start =t_start_vec(1)-2000;
yy_end = t_end_vec(1)-2000;
timestart = t_start_vec(4)*10000+t_start_vec(5)*100;
timeend = t_end_vec(4)*10000+t_end_vec(5)*100;
daystart = daynum_start;
dayend = daynum_end;

instream = rvsstreamname; % this should be set in m_setup and picked up from a global var so that it doesn't have to be edited for each cruise/ship
flags = datapupflags;
varlist = '-';

switch MEXEC_G.Mshipdatasystem
    case 'scs'
    mdatapupscs(yy_start,daystart,timestart,yy_end,dayend,timeend,...
        flags,instream,winfile,varlist);
    case 'techsas'
     mdatapuptechsas(yy_start,daystart,timestart,yy_end,dayend,timeend,...
        flags,instream,winfile,varlist);
    case 'rvdas'
        if strcmp(MEXEC_G.Mship,'sda')
            %limit variables
            if exist('ticasts','var') && ismember(stn,ticasts)
                varlist = 'MFCTDOutboardTension MFCTDCableLengthOut MFCTDDeployedDepth MFCTDLineSpeed MFCTDOverboardPointSelected ';
            else
                varlist = 'CTDOutboardTension CTDCableLengthOut CTDDeployedDepth CTDLineSpeed CTDOverboardPointSelected ';
            end
            %varlist = [varlist 'deeptowoutboardtension deeptowinboardtension deeptowcablelengthout deeptwodeployeddepth deeptowlinespeed '];
            %varlist = [varlist 'biowireoutboardtension biowireinboardtension biowirecablelengthout biowiredeployeddepth biowireoverboardpointselec'];
        end
        if exist(m_add_nc(winfile),'file')
            %mrrvdas2mstar will merge if file exists, don't want that here
            movefile(m_add_nc(winfile),[otfile2 '.tmp'])
        end
        mrrvdas2mstar(instream,t_start_vec,t_end_vec,winfile,dataname,varlist);
        delete([winfile '.tmp']);
%         if strcmp(MEXEC_G.Mship,'sda')
%             %subsample to 1 Hz (from 4 Hz)
%             [d,h] = mloadq(otfile2,'/');
%             fn = fieldnames(d);
%             for fno = 1:length(fn)
%                 d.(fn{fno}) = d.(fn{fno})(1:4:end);
%             end
%             mfsave(otfile2,d,h);
%         end

end


MEXEC_A.MARGS_IN = {
winfile
'y'
'1'
sprintf(winfile.dataname,stn_string)
'/'
'2'
MEXEC_G.PLATFORM_TYPE
MEXEC_G.PLATFORM_IDENTIFIER
MEXEC_G.PLATFORM_NUMBER
'/'
'-1'
};
MEXEC_A.MARGS_IN0 = MEXEC_A.MARGS_IN;
mheadr;

hdr = m_read_header(winfile);
noflds = hdr.noflds;
copystring = ['1~' sprintf('%d',noflds)];

MEXEC_A.MARGS_IN = {
winfile
wkfile3
'/'
'time'
'y = m_flag_monotonic(x1);'
'tflag'
' '
' '
};
mcalc;

MEXEC_A.MARGS_IN = {
wkfile3
winfile
'2'
'tflag .5 1.5'
' '
copystring
};
mdatpik;

if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
    mtranslate_varnames(winfile,instream);
end

delete(m_add_nc(wkfile3));
