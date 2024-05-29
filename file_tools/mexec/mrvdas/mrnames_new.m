function tablemap = mrnames_new(tablist,varargin)
% function tablemap = mrnames_new(tablist,qflag)
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

n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'hed'; mt(n).msg = {'hehdt','gphdt','inhdt'}; 
n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'att'; mt(n).msg = {'pashr','pixseatitud','prdid','psxn23','kmatt','psmcv','psmbc'}; 
% n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'hss'; mt(n).msg = {'pixseaheave0'};  
%n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'att'; mt(n).msg = {'inrot','herot'}; 
n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'pos'; mt(n).msg = {'gpgga','gpggk','gpgll','pixsegpsin0','gngga','ingga','gngll'}; 
n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'pos'; mt(n).msg = {'gpvtg','gnvtg','invtg'}; 
% n = n+1; mt(n).dir = 'nav'; mt(n).pre = 'pos'; mt(n).msg = {'gngsa','ingsa'}; 

n = n+1; mt(n).dir = 'met'; mt(n).pre = 'wnd'; mt(n).msg = {'iimwv','wimwv','pmwind','gpxsm'}; %gpxsm is surfmet
n = n+1; mt(n).dir = 'met'; mt(n).pre = 'ocn'; mt(n).msg = {'sbe38','psbsst1','phsst'}; %things that are on the keel or remote 
n = n+1; mt(n).dir = 'met'; mt(n).pre = 'ocn'; mt(n).msg = {'nanan','psbtsg1','pvsv1','pwltran1','pwlfluor1','plmflow1','sfuwy'}; %things that are on the ucsw pipe (in the lab) n = n+1;
% n = n+1; mt(n).dir = 'met'; mt(n).pre = 'wav'; mt(n).msg = {'pwam1','pramr','pwam'}; 
n = n+1; mt(n).dir = 'met'; mt(n).pre = 'atm'; mt(n).msg = {'pcfrs','pvtnh2','pvbar','pmdew','sfmet'}; %pressure, humidity, precip n = n+1;
% n = n+1; mt(n).dir = 'met'; mt(n).pre = 'sky'; mt(n).msg = {'pvceil1','peceil','pbpws','ptdisd'}; %some of these are really too complex to read in our normal way, like the thies clima has hundreds of different variables starting with numberParticlesDiameter  
n = n+1; mt(n).dir = 'met'; mt(n).pre = 'rad'; mt(n).msg = {'pkpyrge','pkpyran','pspar','sflgt'}; %radiometers
n = n+1; mt(n).dir = 'met'; mt(n).pre = 'ocn'; mt(n).msg = {'pc4rhoist1'}; %sda ucsw intake pole position

n = n+1; mt(n).dir = 'bathy'; mt(n).pre = 'sbm'; mt(n).msg = {'sddpt','sddbs','sdalr','sddbk','sddbs','sddpt','dbdbt','sddbt'}; %'pskpdpt',
n = n+1; mt(n).dir = 'bathy'; mt(n).pre = 'mbm'; mt(n).msg = {'kidpt','kodpt'}; 

% n = n+1; mt(n).dir = 'uother'; mt(n).pre = 'env'; mt(n).msg = {'wimta','wimhu','ps8953','pytemp'}; %not sure about some of these n = n+1;
% n = n+1; mt(n).dir = 'uother'; mt(n).pre = 'grv'; mt(n).msg = {'uw','pdgrav','tnn','dtvnn','uwraw'}; 
% n = n+1; mt(n).dir = 'uother'; mt(n).pre = 'mag'; mt(n).msg = {'inmag','3rr0r'}; 
n = n+1; mt(n).dir = 'speed'; mt(n).pre = 'adcp'; mt(n).msg = {'vdvbw'}; 
%n = n+1; mt(n).dir = 'speed'; mt(n).pre = 'log'; mt(n).msg = {'vmvbw','vdvbw','vmvhw','vmvlw','vmmtw','vdvhw','vdvlw'}; 

n = n+1; mt(n).dir = 'winch'; mt(n).pre = 'winch'; mt(n).msg = {'winch','sdawinch'}; 

n = n+1; mt(n).dir = 'lab'; mt(n).pre = 'autosal'; mt(n).msg = {'autosal'};

mt = struct2table(mt);
dnames = mt.dir;


opt1 = 'ship'; opt2 = 'rvdas_form'; get_cropt
if use_cruise_views
    n0 = length(view_name)+2; %assume it's followed by underscore
else
    n0 = 1;
end


%tablemap will contain [mstar_prefix tablename mstar_directory]
%at first mstar_prefix will be too long and granular; we will combine/
%simplify below
tablemap = [tablist tablist tablist tablist]; hasmp = zeros(length(tablist),1);
for tno = 1:length(tablist)
    tabl = tablist{tno}(n0:end);
    ii = strfind(tabl,'_');
    %if we have an extra prefix like anemometer_ on this ship/database
    if npre>0; ii = ii(npre:end); end
    if length(ii)==1
        ii(2) = ii(1); %tablemap{:,4} will be empty
    end
    msg = tabl(ii(end)+1:end);
    inst1 = tabl(1:ii(2)-1);
    inst2 = tabl(ii(2)+1:ii(end)-1);
%     inst2 = tabl(ii(end-1)+1:ii(end)-1);
%     if ~contains(inst2,digitsPattern) && length(ii)>=3
%         n = length(ii)-1;
%         inst2 = tabl(ii(end-n)+1:ii(end-n+1)-1);
%     end
    %inst = tabl(ii(1)+1:ii(2)-1); %everything after the prefix and before the message
    %for each table, look through the dnames
%     disp(tabl); disp(msg); disp(inst1); disp(inst2)
    for dno = 1:length(dnames)
        if sum(strcmp(mt.msg{dno},msg))
            tablemap{tno,1} = inst1;
            %tablemap{tno,3} = fullfile(mt.dir{dno},instt);
            tablemap{tno,3} = fullfile(mt.dir{dno},mt.pre{dno});
            tablemap{tno,4} = inst2;
            hasmp(tno) = 1;
            break
        end
    end
    %if hasmp(tno)==0; keyboard; end
end
tablemap(hasmp==0,:) = [];

tablemap0 = tablemap;
%simplify mstar_prefix and then discard extra column
ii0 = 1:length(tablemap); 
for no = 1:length(tablemap)
    if ismember(no,ii0)
        ii = find(strcmp(tablemap{no,1},tablemap(ii0,1)) & strcmp(tablemap{no,3},tablemap(ii0,3)));
        if length(ii)>1
%             tablemap(ii0(ii),1) = cellfun(@(x,y) [x '_' y],tablemap(ii0(ii),1),tablemap(ii0(ii),4),'UniformOutput',false);
        end
    ii0(ii) = [];
    end
end
tablemap(:,4) = [];

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
