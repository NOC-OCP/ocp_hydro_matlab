function tablemap = mrnames(tablist,varargin)
% function tablemap = mrnames(tablist,qflag)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Define and show the names of the rvdas tables and the mexec shorthand
% equivalent (i.e. mstar filename prefixes)
%
% Examples
%
%   tablemap = mrnames(tablist,'q');
%
% Input:
% 
% tablist is the list of tablenames (fieldnames of output of
% mrtables_from_json)
% If called without a second argument, the table will be listed to the
% screen. If called with 'q', the listing to the screen is suppressed.
%
% Output: 
% 
% tablemap is an N x 3 cell array. Column 1 is the list of mexec short
% names. Column 2 is the list of RVDAS table names (the subset of input
% tablist that has a corresponding mstar name). Column 3 is directory 
% names.  
% 
% The mapping is constructed by searching for the messages in tablist
% (those present and being ingested on this cruise) in a lookup. You can
% add new messages (msg) and/or prefixes/shortnames (pre) to the lookup
% (mt, below). The same dir/pre (directory/prefix) can apply to multiple
% messages as long as only one per instrument is being read in on a given
% cruise; use rvdas_skip in cruise options file to exclude duplicates, or
% else the first of any set of repeats will be used and the other(s)
% ignored.   


% Search for any of the arguments to be 'q', and set qflag = 'q' or '';
qflag = '';
mq = strcmp('q',varargin);
if sum(mq)
    qflag = 'q';
end

%create lookup for potential types of messages (some of which may have been excluded from mrtables_from_json by rvdas_skip option in mrjson_load_all)
n = 0;

n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'hdt'; mt(n).msg = {'hehdt','gphdt','inhdt'}; 
n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'att'; mt(n).msg = {'pashr','pixseatitud','prdid','psxn23','kmatt','psmcv','psmbc'}; 
n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'hss'; mt(n).msg = {'pixseaheave0'};  
n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'pos'; mt(n).msg = {'gpgga','gpggk','gpgll','pixsegpsin0','gngga','ingga','gngll'}; 
n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'vtg'; mt(n).msg = {'gpvtg','gnvtg','invtg'}; 
n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'rot'; mt(n).msg = {'inrot','herot'}; 
n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'dop'; mt(n).msg = {'gngsa','ingsa'}; 

n = n+1; mt(n).dir = 'met'; mt(n).pre = 'met'; mt(n).msg = {'gpxsm'}; %surfmet / combined file (?) n = n+1;
n = n+1; mt(n).dir = 'met'; mt(n).pre = 'wind'; mt(n).msg = {'iimwv','wimwv','pmwind'}; 
n = n+1; mt(n).dir = 'met'; mt(n).pre = 'sst'; mt(n).msg = {'sbe38','psbsst1'}; %things that are on the keel or remote n = n+1;
n = n+1; mt(n).dir = 'met'; mt(n).pre = 'tsg'; mt(n).msg = {'nanan','psbtsg1','pvsv1','pwltran1','pwlfluor1','plmflow1'}; %things that are on the ucsw pipe (in the lab) n = n+1;
n = n+1; mt(n).dir = 'met'; mt(n).pre = 'wave'; mt(n).msg = {'pwam1','pramr','pwam'}; 
n = n+1; mt(n).dir = 'met'; mt(n).pre = 'atmo'; mt(n).msg = {'pbpws','pcfrs','ptdisd','pvtnh2','pvbar','pbpws','pmdew'}; %pressure, humidity, precip n = n+1;
n = n+1; mt(n).dir = 'met'; mt(n).pre = 'sky'; mt(n).msg = {'pvceil1','peceil'}; 
n = n+1; mt(n).dir = 'met'; mt(n).pre = 'rad'; mt(n).msg = {'pkpyrge','pkpyran','phsst','pspar'}; %radiometers n = n+1;

n = n+1; mt(n).dir = 'bathy'; mt(n).pre = 'singleb'; mt(n).msg = {'sddpt','sddbs','pskpdpt','sdalr','sddbk','sddbs','sddpt','dbdbt','sddbt'}; 
n = n+1; mt(n).dir = 'bathy'; mt(n).pre = 'multib'; mt(n).msg = {'kidpt','kodpt'}; 

n = n+1; mt(n).dir = 'uother'; mt(n).pre = 'env'; mt(n).msg = {'wimta','wimhu','ps8953','pytemp'}; %not sure about some of these n = n+1;
n = n+1; mt(n).dir = 'uother'; mt(n).pre = 'grav'; mt(n).msg = {'uw','pdgrav'}; 
n = n+1; mt(n).dir = 'uother'; mt(n).pre = 'mag'; mt(n).msg = {'inmag','3rr0r'}; 
n = n+1; mt(n).dir = 'uother'; mt(n).pre = 'log'; mt(n).msg = {'vmvbw','vdvbw','vmvhw','vmvlw','vmmtw','vdvhw','vdvlw'}; 

n = n+1; mt(n).dir = 'winch'; mt(n).pre = 'winch'; mt(n).msg = {'winch','sdawinch'}; 


mt = struct2table(mt);
dnames = mt.dir;
% m = strcmp(dnames,'nav'); mt.insts(m) = repmat({'seapath_320','seapath','posmv','fugro_oceanstar','fugro','phins','cnav','ranger','r5_supreme'},sum(m),1);
% mt.insts(strcmp(dnames,'att')) = {'seapath_320','seapath','posmv','phins','sgyro','imu108','standard_30_mf','bluenaute'};
% mt.insts(strcmp(dnames,'met')) = {'sbe38','surfmet','windsonic','sbe45','rex2','wamos','ft702lt','usonic3','omc116','vaisala_cl3l','lmx24','wschl'};
% mt.insts(strcmp(dnames,'bathy')) = {'em122','ea640','ea640'};
% mt.insts(strcmp(dnames,'uother')) = {'env','at1m10_100'}
% mt.insts(strcmp(dnames,'winch')) = {'winchlog'};

%for each table, look through the dname
scriptname = 'mrvdas_ingest'; oopt = 'use_cruise_views'; get_cropt
scriptname = 'mrvdas_ingest'; oopt = 'rvdas_nameform'; get_cropt
if use_cruise_views
    n0 = length(view_name)+2; %assume it's followed by underscore
else
    n0 = 1;
end

%tablemap will contain [mstar_prefix tablename mstar_directory]
tablemap = [tablist tablist tablist tablist]; hasmp = zeros(length(tablist),1);
for tno = 1:length(tablist)
    tabl = tablist{tno}(n0:end);
    ii = strfind(tabl,'_');
    %if we have an extra prefix like anemometer_
    if npre>0; ii = ii([npre end]); else; ii = [1 ii(end)]; end
    msg = tabl(ii(2)+1:end); 
    inst = tabl(ii(1)+1:ii(2)-1); %everything after the prefix and before the message
%     %check for multiples
%     ii = strfind(inst,'_');
%     if ~isempty(ii) && isfinite(str2double(inst(ii(end)+1:end)))
%         instt = inst(1:ii(end)-1);
%     else
%         instt = inst;
%     end
    for dno = 1:length(dnames)
        if sum(strcmp(mt.msg{dno},msg))
            tablemap{tno,1} = [mt.pre{dno} inst];
            %tablemap{tno,3} = fullfile(mt.dir{dno},instt);
            tablemap{tno,3} = fullfile(mt.dir{dno},mt.pre{dno});
            hasmp(tno) = 1;
        end
    end
    %if hasmp(tno)==0; keyboard; end
end
tablemap(hasmp==0,:) = [];

%scriptname = 'mrvdas_ingest'; oopt = 'use_cruise_views'; get_cropt
%if use_cruise_views
%    tablemap(:,2) = cellfun(@(x) [view_name '_' x], tablemap(:,2), 'UniformOutput', false);
%end

if isempty(qflag)
    tablemapsort = sortrows(tablemap,1);
    for kl = 1:size(tablemapsort,1)
        pad = '                                            ';
        q = '''';
        s1 = tablemapsort{kl,1}; s1 = [pad q s1 q]; s1 = s1(end-15:end);
        s2 = tablemapsort{kl,2}; s2 = [q s2 q pad]; s2 = s2(1:30);
        fprintf(MEXEC_A.Mfidterm,'%s %s\n',s1,s2);
    end
end
