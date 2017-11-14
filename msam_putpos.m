% msam_putpos: apply positions to set of files
%
% Use: msam_putpos        and then respond with station number, or for station 16
%      stn = 16; msam_putpos;
%
% bak on jr302 22 jun 2014: new script edited from mdcs_05, to populate new
% lat and lon vars in sam file. position taken from dcs pos file, or if that
% doesnt exist, taken from header of ctd raw file

scriptname = 'msam_putpos';
cruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('stn','var')
    stn = input('type stn number ');
end
stn_string = sprintf('%03d',stn);
stnlocal = stn; clear stn % so that it doesn't persist

mdocshow(scriptname, ['adds positions from dcs or ctd raw file to sam_' cruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['sam_' cruise '_'];
prefix2 = ['dcs_' cruise '_'];
prefix3 = ['ctd_' cruise '_'];

clear fn

fn{1} = [root_ctd '/' prefix1 stn_string];
fn{2} = [root_ctd '/' prefix2 stn_string '_pos'];
fn{3} = [root_ctd '/' prefix3 stn_string '_raw'];

filename = m_add_nc(fn{1});
if ~exist(filename,'file')
    m = ['File ' filename ' does not exist yet'];
    fprintf(MEXEC_A.Mfider,'%s\n',m)
    return
end

% If the position isnt available from the dcs
% file, take it from the raw file instead, which should have been set using
% posinfo at the time that file was created
if exist(m_add_nc(fn{2}),'file') == 2
    [d h] = mload(fn{2},'statnum','lat_bot','lon_bot',' ');
    
    % allow for the possibility that the dcs file contains many stations
    
    kf = find(d.statnum == stnlocal);
    latbot = d.lat_bot(kf(1));
    lonbot = d.lon_bot(kf(1));
elseif exist(m_add_nc(fn{3}),'file') == 2
    h = m_read_header(fn{3});
    latbot = h.latitude;
    lonbot = h.longitude;
else
    msg = ['No source found for position on station ' stn_string];
    fprintf(MEXEC_A.Mfider,'%s\n',msg);
    return
end

latstr = ['y = ones(size(x)) * ' sprintf('%12.6f',latbot)]; 
lonstr = ['y = ones(size(x)) * ' sprintf('%12.6f',lonbot)]; 

%--------------------------------
% 2014-06-22 19:43:18
% mcalib
% calling history, most recent first
%    mcalib in file: mcalib.m line: 91
% input files
% Filename sam_jr302_001.nc   Data Name :  sam_jr302_001 <version> 38 <site> jr302_atsea
% output files
% Filename sam_jr302_001.nc   Data Name :  sam_jr302_001 <version> 39 <site> jr302_atsea
MEXEC_A.MARGS_IN = {
fn{1}
'y'
'lat'
latstr
' '
' '
'lon'
lonstr
' '
' '
' '
};
mcalib
%--------------------------------
