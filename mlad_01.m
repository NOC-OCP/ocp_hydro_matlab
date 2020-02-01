% mlad_01: create empty data cycles file
%
% Use: mlad_01        and then respond with station number, or for station 16
%      stn = 16; mlad_01;
%
% gdm on di346
% script to load ldeo and uh processed ladcp velocity profiles and save to
% three m* files for that station each containing uh, ldeo and bt
% velocities
%
% the lats and longs come from the dcs file

minit; scriptname = mfilename;
mdocshow(scriptname, ['add documentation string for ' scriptname])

% resolve root directories for various file types

root_ladcp = mgetdir('M_LADCP');
root_ctd = mgetdir('M_CTD');

% getting the location of the cast
dcs_filename = [root_ctd '/dcs_' mcruise '_' stn_string];
d=m_read_header(dcs_filename);
latstr=num2str(d.latitude);lonstr=num2str(d.longitude);

% load the uh profiles first

fname = [MEXEC_G.MEXEC_DATA_ROOT '/uh/pro/di1001/ladcp/proc/matprof/h/d' stn_string '_02'];
d_uh=load(fname);
u=d_uh.su_mn_i;
v=d_uh.sv_mn_i;
% uh_w=sw_mn_i;
z=d_uh.d_samp;

nd=find(u==0);u(nd)=u(nd)+nan;
nd=find(v==0);v(nd)=v(nd)+nan;

nd=find(d_uh.su_mn_i==0);d_uh.su_mn_i(nd)=d_uh.su_mn_i(nd)+nan;
nd=find(d_uh.sv_mn_i==0);d_uh.sv_mn_i(nd)=d_uh.sv_mn_i(nd)+nan;

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];
prefix = ['ladcp_' mcruise '_'];

dataname1=[prefix stn_string '_uh'];
dataname2=[prefix stn_string '_ld'];
dataname3=[prefix stn_string '_bt'];

otfile1 = [root_ladcp '/' prefix stn_string '_uh.nc'];
otfile2 = [root_ladcp '/' prefix stn_string '_ld.nc'];
otfile3 = [root_ladcp '/' prefix stn_string '_bt.nc'];

logfile= [root_ladcp '/' prefix 'log.txt'];

%--------------------------------
% 2010-01-08 12:14:31
% msave
% input files
% Filename    Data Name :   <version>  <site>
% output files
% Filename ladcp_di346_003.nc   Data Name :  ladcp_di346_003 <version> 1 <site> di346_atsea
MEXEC_A.MARGS_IN = {
    otfile1
    'u'
    'v'
    'z'
    '/'
    '/'
    '1'
    dataname1
    '/'
    '8'
    '0'
    '/'
    'm/s'
    '/'
    'm/s'
    '/'
    'm'
    '-1'
    '2'
    MEXEC_G.PLATFORM_TYPE
    MEXEC_G.PLATFORM_IDENTIFIER
    MEXEC_G.PLATFORM_NUMBER
    '/'
    '4'
    timestring
    '/'
    '5'
    latstr
    lonstr
    '/'
    '/'
    };
msave
%--------------------------------


%% load the ldeo profiles

ldeo_root = [MEXEC_G.MEXEC_DATA_ROOT '/ldeo/di1001/D346' stn_string];
if exist([ldeo_root '/D346' stn_string 'wctd.mat'])==2
    load([ldeo_root '/D346' stn_string 'wctd']);% should be a switch to take the wctd if it exists
else
    load([ldeo_root '/D346' stn_string 'noctd']);% should be a switch to take the wctd if it exists
end
u=dr.u;
v=dr.v;
z=dr.z;
%--------------------------------
% 2010-01-08 12:14:31
% msave
% input files
% Filename    Data Name :   <version>  <site>
% output files
% Filename ladcp_di346_003.nc   Data Name :  ladcp_di346_003 <version> 1 <site> di346_atsea
MEXEC_A.MARGS_IN = {
    otfile2
    'u'
    'v'
    'z'
    '/'
    '/'
    '1'
    dataname2
    '/'
    '8'
    '0'
    '/'
    'm/s'
    '/'
    'm/s'
    '/'
    'm'
    '-1'
    '2'
    MEXEC_G.PLATFORM_TYPE
    MEXEC_G.PLATFORM_IDENTIFIER
    MEXEC_G.PLATFORM_NUMBER
    '/'
    '4'
    timestring
    '/'
    '5'
    latstr
    lonstr
    '/'
    '/'
    };
msave
%--------------------------------

%% load the ldeo bottom track profiles
%  bottom track doesn't exist for all profiles so put a conditional
%  statement here
if isfield(dr,'ubot')
    u=dr.ubot;
    v=dr.vbot;
    z=dr.zbot;
    %--------------------------------
    % 2010-01-08 12:14:31
    % msave
    % input files
    % Filename    Data Name :   <version>  <site>
    % output files
    % Filename ladcp_di346_003.nc   Data Name :  ladcp_di346_003 <version> 1 <site> di346_atsea
    MEXEC_A.MARGS_IN = {
        otfile3
        'u'
        'v'
        'z'
        '/'
        '/'
        '1'
        dataname3
        '/'
        '8'
        '0'
        '/'
        'm/s'
        '/'
        'm/s'
        '/'
        'm'
        '-1'
        '2'
        MEXEC_G.PLATFORM_TYPE
        MEXEC_G.PLATFORM_IDENTIFIER
        MEXEC_G.PLATFORM_NUMBER
        '/'
        '4'
        timestring
        '/'
        '5'
        latstr
        lonstr
        '/'
        '/'
        };
    msave
    %--------------------------------
else
    fid = fopen(logfile,'a');
    fprintf(fid,['No Bottom Track data for station ' stn_string '\n']);
    fclose(fid);
end;

% ld_w=dr.w;
% plot it up
figure;hold on; grid on;box on;
plot(d_uh.su_mn_i,-d_uh.d_samp,'b--');
plot(d_uh.sv_mn_i,-d_uh.d_samp,'g--');
plot(dr.u,-dr.z,'b');
plot(dr.v,-dr.z,'g');

if isfield(dr,'ubot')
    plot(dr.ubot,-dr.zbot,'b*');
    plot(dr.vbot,-dr.zbot,'g*');
    legend('uh_u','uh_v','ld_u','ld_v','bt_u','bt_v','location','southeast')
else legend('uh_u','uh_v','ld_u','ld_v','location','southeast')
end;

ylim([-max(dr.z) -min(dr.z)])

title(['LADCP profiles for station ' stn_string ]);
xlabel('Velocity (m/s)'); ylabel('Depth (m)')

print('-dpsc', [root_ladcp '/ladcp_profile_' stn_string])

