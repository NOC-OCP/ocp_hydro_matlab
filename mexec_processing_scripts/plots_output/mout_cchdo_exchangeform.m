function mout_cchdo_exchangeform(klist)
% write the sample data in sam_cruise_all.nc and the ctd
% data in ctd_cruise_nnn.nc to CCHDO exchange-format files
%
% set klist to write a set of ctd stations (or klist = [] to skip)
%
% calls
%   get_cropt (outputs, exch; sets header info and customises variables to
%     be written)
%   m_exch_vars_list (sets the variable name mapping)
%

m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
opt1 = 'outputs'; opt2 = 'exch'; get_cropt
expocode = [shipcode dates(1,:)];
common_headstr = {sprintf('#SHIP: %s', MEXEC_G.PLATFORM_IDENTIFIER);...
		  sprintf('#Cruise %s', crname);...
		  sprintf('#EXPOCODE: %s', expocode);...
		  sprintf('#DATES: %s - %s', dates(1,:), dates(2,:));...
		  sprintf('#Chief Scientist: %s', cs);...
		  acknowl};
common_botstr = {};
for rno = 1:size(nsta_nros,1)
  common_botstr = [common_botstr; sprintf('#%d stations with %d-place rosette',nsta_nros(rno,1),nsta_nros(rno,2))];
end
common_depstr = {sprintf('# DEPTH_TYPE   : %s', dept{1});...
		 sprintf('# DEPTH_TYPE   : %s', dept{2})};
common_ctdstr = {sprintf('#CTD: Who - %s; Status - %s',datas.CTD.who,datas.CTD.status);...
		 '#Notes: Includes CTDSAL, CTDOXY, CTDTMP'};
if strcmp(datas.CTD.status,'final')
  common_ctdstr = [common_ctdstr;
		   '#The CTD PRS; TMP; SAL; OXY data are all calibrated and good.'];
		 

%first write the sam file
if exist(fullfile(mgetdir('sam'),sprintf('sam_%s_all.nc',mcruise)),'file')
    clear in out
    in.type = 'sam';
    out.type = 'exch';

    %vector variables
    [out.vars_units, out.varsh] = m_exch_vars_list(2);
    [~,ia] = setdiff(out.vars_units(:,1),vars_exclude_sam,'stable');
    out.vars_units = out.vars_units(ia,:);
    for no = 1:size(vars_rename,1)
        m = strcmp(vars_rename{no,1},out.vars_units(:,1));
        if sum(m); out.vars_units{m,1} = vars_rename{no,2}; end
        vars_rename{no,1} = [vars_rename{no,1} '_FLAG_W'];
        m = strcmp(vars_rename{no,1},out.vars_units(:,1));
        if sum(m); out.vars_units{m,1} = vars_rename{no,2}; end
    end

    %variables to be tiled
    in.extras.expocode = expocode;
    in.extras.sect_id = sect_id;
    in.extras.castno = 1;

    %header
    out.header = [{sprintf('BOTTLE, %s %s',datestr(now,'yyyymmdd'),submitter)};...
		  common_headstr; common_botstr; common_ctdstr; common_depstr];
    fn = setdiff(fieldnames(datas),'CTD');
    for fno = 1:length(fn)
      out.header = [out.header;...
		    sprintf('#%s: Who - %s; Status - %s %s.',fn{fno},datas.(fn{fno}).who,datas.(fn{fno}).status,datas.(fn{fno}).comment)];
      end

    %write
    out.csvpre = fullfile(mgetdir('sum'), sprintf('%s_hy1',expocode));
    mout_csv(in, out);
end


%then write the ctd file(s)
if ~isempty(klist)

    clear in out
    in.type = 'ctd';
    in.stnlist = klist;
    out.type = 'exch';

    %vector variables
    [out.vars_units, out.varsh] = m_exch_vars_list(1);
    [~,ia] = setdiff(out.vars_units(:,1),vars_exclude_sam,'stable');
    out.vars_units = out.vars_units(ia,:);
    for no = 1:size(vars_rename,1)
        m = strcmp(vars_rename{no,1},out.vars_units(:,1));
        if sum(m); out.vars_units{m,1} = vars_rename{no,2}; end
        vars_rename{no,1} = [vars_rename{no,1} '_FLAG_W'];
        m = strcmp(vars_rename{no,1},out.vars_units(:,1));
        if sum(m); out.vars_units{m,1} = vars_rename{no,2}; end
    end

    %header
    in.extrah.expocode = expocode;
    in.extrah.sect_id = sect_id; 
    in.extrah.castno = 1;
    out.header = [{sprintf('CTD, %s %s',datestr(now,'yyyymmdd'),submitter)};...
		  common_headstr; common_botstr; common_ctdstr; common_depstr;...
    sprintf('%s %d', 'NUMBER_HEADERS = ', size(out.varsh,1)+1)];

    %write
    basedir = fullfile(mgetdir('sum'),[expocode '_ct1']);
    if ~exist(basedir,'dir'); mkdir(basedir); mfixperms(basedir, 'dir'); end
    out.csvpre = fullfile(basedir, sprintf('%s_00',expocode));
    mout_csv(in, out);
end
