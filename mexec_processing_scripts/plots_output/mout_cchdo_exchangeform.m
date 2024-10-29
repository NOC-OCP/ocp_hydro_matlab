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

%first write the sam file
if exist(fullfile(mgetdir('sam'),sprintf('sam_%s_all.nc',mcruise)),'file')
    clear in out
    in.type = 'sam';
    out.type = 'exch';

    %vector variables
    [out.vars_units, out.varsh] = m_exch_vars_list(2);
    opt1 = 'outputs'; opt2 = 'exch'; get_cropt
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
    out.header = headstring;

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
    opt1 = 'outputs'; opt2 = 'exch'; get_cropt
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
    out.header = [headstring; sprintf('%s %d', 'NUMBER_HEADERS = ', size(out.varsh,1)+1)];

    %write
    basedir = fullfile(mgetdir('sum'),[expocode '_ct1']);
    if ~exist(basedir,'dir'); mkdir(basedir); mfixperms(basedir, 'dir'); end
    out.csvpre = fullfile(basedir, sprintf('%s_00',expocode));
    mout_csv(in, out);
end
