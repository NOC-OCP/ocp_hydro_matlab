function [lat lon] = msposinfo_noup(dn1,navstream)
% function [lat lon] = mtposinfo(varargin)
% eg
% [lat lon] = mtposinfo;
% [lat lon] = mtposinfo([2009 4 4 12 0 0]);
% [lat lon] = mtposinfo([2009 4 4 12 0 0],'dps116');
% mtposinfo now-1;
% mtposinfo '2009 4 4 12 0 0';
% mtposinfo now dps116;
% mtposinfo;
% 
% Obtain position from a techsas nav file. On JC032 this was hardwired to
% posmvpos. If no argument, the latest data cycle in the latest file is returned.
% The argument can be a Matlab datenum or a Matlab datevec
% 
% 
% first draft by BAK on JC032
%
% 8 Sep 2009: SCS version of original techsas script, for JR195
% The searched directory is uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% for example.
%
% this version on jr281 18 march 2013, noupdate of matlab file for use in
% eta.m

m_common

if ~exist('navstream','var'); navstream = MEXEC_G.uway_default_navstream; end  % use default nav stream name

instream = navstream; % mexec stream short name
tstream = msresolve_stream(instream);

navminus = tstream;
navunder = navminus;
navunder(strfind(navunder,'-')) = '_';

if ~exist('dn1','var')
    [pdata u] = mslast(tstream);
    cmd = ['lat = pdata.' navunder '_lat;']; eval(cmd);
    cmd = ['lon = pdata.' navunder '_lon;']; eval(cmd);
    dn = pdata.time+MEXEC_G.uway_torg;
elseif isempty(dn1); 
    [pdata u] = mslast(tstream);
    cmd = ['lat = pdata.' navunder '_lat;']; eval(cmd);
    cmd = ['lon = pdata.' navunder '_lon;']; eval(cmd);
    dn = pdata.time+MEXEC_G.uway_torg;
else
    if ischar(dn1);
        cmd =['dn1 = [' dn1 '];'];  % if the arg has come in as a string, convert from char to number
        eval(cmd);
    end
    dn = datenum(dn1);
    % load data 5 minutes either side in case the required time falls precisely
    % between two files
%     ms_update_aco_to_mat(tstream); % ensure mat file is up to date before loading
    pdata = msload(tstream,dn-5/1440,dn+5/1440,['time ' navminus '-lat ' navminus '-lon']);

    tin = pdata.time+MEXEC_G.uway_torg;
    cmd = ['latin = pdata.' navunder '_lat;']; eval(cmd)
    cmd = ['lonin = pdata.' navunder '_lon;']; eval(cmd)
    [tunique kun] = unique(tin); % bak on jr281 27 march 2013, repeated time in seatex-gll caused failure in ctd2a
    lat = interp1(tunique,latin(kun),dn);
    lon = interp1(tunique,lonin(kun),dn);
% else
%     m = 'expect precisely zero or one input arg which should be matlab datenum or datvec)';
%     fprintf(MEXEC_A.Mfider,'%s\n',m)
%     lat = nan; lon = nan;
%     return
end

if nargout > 0 return; end
% else print to screen


[latd latm] = m_degmin_from_decdeg(lat);
[lond lonm] = m_degmin_from_decdeg(lon);

% dvnow = datevec(now);
dvnow = datevec(dn);
yyyy = dvnow(1);
doffset = datenum([yyyy 1 1 0 0 0]);
daynum1 = floor(dn) - doffset + 1;

str1 = datestr(dn,'yy/mm/dd');
str1a = datestr(dn,'HH:MM:SS');
fprintf(MEXEC_A.Mfidterm,'%s\n',tstream);
fprintf(MEXEC_A.Mfidterm,'%s     %8s   %03d %8s\n','time',str1,daynum1,str1a);
fprintf(MEXEC_A.Mfidterm,'%s %10.5f %5.0f %6.2f\n','lat',lat,latd,latm);
fprintf(MEXEC_A.Mfidterm,'%s %10.5f %5.0f %6.2f\n','lon',lon,lond,lonm);

return

