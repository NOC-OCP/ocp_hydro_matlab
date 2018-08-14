% msam_putpos: apply positions to set of files
%
% Use: msam_putpos        and then respond with station number, or for station 16
%      stn = 16; msam_putpos;
%
% bak on jr302 22 jun 2014: new script edited from mdcs_05, to populate new
% lat and lon vars in sam file. position taken from dcs pos file, or if that
% doesnt exist, taken from header of ctd raw file

scriptname = 'msam_putpos';
minit
mdocshow(scriptname, ['adds positions from dcs pos or ctd raw file to sam_' mcruise '_' stn_string '.nc']);

root_ctd = mgetdir('M_CTD');

otfile = [root_ctd '/sam_'  mcruise '_' stn_string];
infile1 = [root_ctd '/dcs_' mcruise '_' stn_string '_pos'];
infile2 = [root_ctd '/ctd_' mcruise '_' stn_string '_raw'];

filename = m_add_nc(otfile);
if ~exist(filename,'file')
    m = ['File ' filename ' does not exist yet'];
    fprintf(MEXEC_A.Mfider,'%s\n',m)
    return
end

latbot = []; lonbot = [];
useraw = 0;
if exist(m_add_nc(infile1),'file') == 2 %default is to get from dcs file
    h = m_read_header(infile1); 
    if sum(strcmp('lat_bot',h.fldnam))==0
        warning(['no cast bottom position in ' fn{iipos}])
        useraw = 1;
    else
       d = mload(infile1,'statnum','lat_bot','lon_bot',' ');
       % allow for the possibility that the dcs file contains many stations
       kf = find(d.statnum == stnlocal);
       latbot = d.lat_bot(kf(1));
       lonbot = d.lon_bot(kf(1));
       if isnan(latbot+lonbot); useraw = 1; end
    end
elseif exist(m_add_nc(infile2),'file') == 2; useraw = 1; end
if useraw %if position wasn't found in dcs file, take it from the raw file instead
    h = m_read_header(infile2);
    latbot = h.latitude;
    lonbot = h.longitude;
end
if isempty(latbot)
    msg = ['No source found for position on station ' stn_string];
    fprintf(MEXEC_A.Mfider,'%s\n',msg);
    return
end

latstr = ['y = ones(size(x)) * ' sprintf('%12.6f',latbot)]; 
lonstr = ['y = ones(size(x)) * ' sprintf('%12.6f',lonbot)]; 

%--------------------------------
MEXEC_A.MARGS_IN = {
otfile
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
