% msbe35_01: load sbe35 data from one or more stations and write to
%     mstar file sbe35_cruise_01.nc, as well as pasting into
%     sam_cruise_all.nc
%
% Use: stn = 16; msbe35_01;
%
% or for multiple stations use klist
%      klist = 1:5; msbe35_01;

m_common
if MEXEC_G.quiet<=1; fprintf(1,'loading SBE35 ascii file(s) to write to sbe35_%s_01.nc and sam_%s_all.nc\n',mcruise,mcruise); end

% load sbe35 data
root_sbe35 = mgetdir('M_SBE35');
sbe35file = sprintf('%s_SBE35_CTD*.asc', upper(mcruise));
stnind = [-6:-4]; %end-6:end-4 e.g. dy113_SBE35_CTD_010.asc
opt1 = 'sbe35'; opt2 = 'sbe35file'; get_cropt
if strcmp(sbe35file,'none')
    return
end

d = dir(fullfile(root_sbe35, sbe35file));
file_list = {d.name};
if isempty(file_list)
    warning('no sbe35 files found; skipping')
    return
end

flag = 9+zeros(8000,1);
t = table(flag);
t.datnum = NaN+flag; t.bn = t.datnum; t.t90 = t.bn;
t.val = t.bn; t.tdiff = t.bn; t.statnum = t.bn;
t.files = cell(8000,1);
clear flag

kount = 1;
for kf = 1:length(file_list)
    fn = fullfile(root_sbe35, file_list{kf});
    if stnind(1)<0; iis = length(file_list{kf})+stnind; else; iis = stnind; end
    fid2 = fopen(fn,'r');
    while 1
        str = fgetl(fid2);
        if ~ischar(str); break; end % fgetl has returned -1 as a number; next file
        strlen = length(str);
        if strlen==77 % data are in 77 byte lines
            t.statnum(kount) = str2double(file_list{kf}(iis));
            t.files{kount} = file_list{kf}; %for debugging
            try
                t.datnum(kount) = datenum(str(5:25));
                %a = str2num(replace(replace(replace(replace(str(26:end),'bn = ',''),'diff = ',''),'val = ',''),'t90 = ',''));
                %bn(kount) = a(1); tdiff(kount) = a(2); val(kount) = a(3); t90(kount) = a(4);
                t.bn(kount) = str2double(str(32:33));
                t.tdiff(kount) = str2double(str(42:46));
                t.val(kount) = str2double(str(53:61));
                t.t90(kount) = str2double(str(69:77));
                t.flag(kount) = 2;
            catch
                t.flag(kount) = 4;
            end
            kount = kount+1;
        end
    end
    fclose(fid2);
end
t.sampnum = t.statnum*100+t.bn;
t(isnan(t.sampnum),:) = [];
m = find(t.flag<9, 1, 'last');
t = t(1:m,:);
t.flag(isnan(sum(t{:,3:7},2))) = 4;
jfiles = unique(t.files(t.flag==4));
if ~isempty(jfiles)
    warning('junk characters or bad values in files:')
    sprintf('%s\n',jfiles{:})
end

opt1 = 'sbe35'; opt2 = 'sbe35_datetime_adj'; get_cropt
%remove duplicate times (in case recorder not erased)
[~,ii] = unique(t.datnum,'stable');
t = t(ii,:);

%modify flags or remove some erroneous lines 
opt1 = 'sbe35'; opt2 = 'sbe35_flags'; get_cropt

%get station start and end times from station_summary file, and use to
%match station numbers and discard duplicate (likely spurious) sampnums
[dsum, hsum] = mloadq(fullfile(mgetdir('sum'),['station_summary_' mcruise '_all.nc']),'/');
dsum.time_start = m_commontime(dsum,'time_start',hsum,'datenum');
dsum.time_end = m_commontime(dsum,'time_end',hsum,'datenum');
opt1 = 'check_sams'; get_cropt
if check_sbe35
    statnumc = NaN+t.statnum;
    m = repmat(dsum.statnum',length(t.datnum),1);
    tm = t.datnum>=dsum.time_start'-15/1440 & t.datnum<=dsum.time_end'+15/1440;
    m(~tm) = -1;
    m = max(m,[],2);
    statnumc(m>-1) = m(m>-1); %station numbers based on time rather than filename
    msta = statnumc~=t.statnum & ~isnan(statnumc); %mismatched station numbers
    msam = sum((t.sampnum'==t.sampnum) - eye(length(t.sampnum)),2); %duplicate sampnums
    mnan = isnan(t.datnum+t.sampnum+t.t90);
    iib = find((msta & msam) | (msta & mnan) | (msam & mnan)); %discard the duplicates that are mismatched on station number; these are probably leftovers in the wrong file; also discard NaNs that are otherwise suspicious/misplaced
    iic = setdiff(find(msam),iib); %check these first
    ii_did = [];
    for no = 1:length(iic)
        if ~ismember(iic(no),ii_did)
            ii = find(t.sampnum==t.sampnum(iic(no)));
            if length(unique(t.files(ii)))==1 && isunix
                system(['cat ' fullfile(root_sbe35,t.files{iic(no)})])
                sprintf('sampnum %d on multiple lines (above)\n',t.sampnum(iic(no)))
            else
                sprintf('sampnum %d on multiple lines:\n',t.sampnum(iic(no)))
                disp(datestr(t.datnum(ii)))
                disp(t.files(ii))
            end
            pause
            ii_did = [ii_did;ii];
        end
    end
    iic = setdiff(find(msta),iib); 
    if ~isempty(iic)
        keyboard
    end
end

%rename and save
clear hnew
hnew.fldnam = {'time' 'position' 'sampnum' 'tdiff' 'val' 'sbe35temp' 'sbe35temp_flag' 'statnum'};
hnew.fldunt = {'seconds' 'on.rosette' 'number' 'number' 'number' 'degc90' 'woce_table_4.9' 'number'};
opt1 = 'mstar'; get_cropt
if docf
    hnew.fldunt{1} = ['seconds since ' datestr(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN,'yyyy-mm-dd HH:MM:SS')];
    hnew.data_time_origin = [];
else
    hnew.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
end
hnew.dataname = ['sbe35_' mcruise '_01'];
hnew.comment = ['files ' sprintf('%s ', file_list{:})]; 

t.position = t.bn;
t.time = m_commontime(t.datnum,'time','datenum',hnew);
t.sbe35temp = t.t90;
t.sbe35temp_flag = t.flag;
opt1 = mfilename; opt2 = 'sbe35flag'; get_cropt
%bottle not fired won't be in list, so nan must be bad
t.sbe35temp_flag(isnan(t.sbe35temp) & t.sbe35temp_flag<4) = 4;
clear d %rather than using table2struct, loop so they'll be in same order as hnew.fldnam
d.junk = [];
for no = 1:length(hnew.fldnam)
    d.(hnew.fldnam{no}) = t.(hnew.fldnam{no});
end
d = rmfield(d,'junk');

otfile1 = fullfile(mgetdir('M_SBE35'), hnew.dataname);
MEXEC_A.Mprog = mfilename;
mfsave(otfile1, d, hnew);

%and update sam_cruise_all file
msbe35_to_sam
