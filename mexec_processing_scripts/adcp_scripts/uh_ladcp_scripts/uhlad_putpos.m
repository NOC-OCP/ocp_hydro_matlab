function uhlad_putpos(statnum,cast)
% function uhlad_putpos(statnum,cast)
%
% putpos(20,2)
% writes ship positions at ladcp file times to
% postimes/postime020
%
% run after scan.prl
%
% script putpos.m to replace awk script putpos2
% first draft bak for jr195 2009-09-18
%
% ylf jc159 added call to magvarsm at end

m_common


if ischar(statnum); statnum = str2num(statnum); end % variables come in as char if simply typed on the command line
if ischar(cast); cast = str2num(cast); end % variables come in as char if simply typed on the command line

[status ladcp_cruiseid] = unix('echo $LADCP_CRUISEID');

cr_letter = ladcp_cruiseid(1);
prof = [cr_letter sprintf('%03d',statnum) '_' sprintf('%02d',cast)];
fname = ['../casts/' prof '/scanload/' prof '.scn'];
fname2 = ['./postimes/postime' sprintf('%03d',statnum)];

if ~exist(fname,'file')
    m = ['File ' fname ' does not exist'];
    m1 = 'Run scan.prl first';
    fprintf(MEXEC_A.Mfider,'%s\n',' ',m,m1,' ')
    return
end

[status lastline] = unix(['tail -1 ' fname]);

lastline(1:11) = [];
text = lastline(1:21);
dn = datenum(text,'yyyy/mm/dd  HH:MM:SS'); % read time

if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)
    [lat lon] = msposinfo_noup(dn); % use default nav stream
else
    [lat lon] = mtposinfo(dn); % use default nav stream
end

[latd latm] = m_degmin_from_decdeg(lat);
[lond lonm] = m_degmin_from_decdeg(lon);

otstring = [datestr(dn,'yyyy mm dd') sprintf('%4.0f%6.2f%4.0f%6.2f',latd,latm,lond,lonm)];


fid = fopen(fname2,'w');disp(fid);disp(otstring);disp(fname2);
fprintf(fid,'%s\n',otstring);
fclose(fid);

magvarsm(statnum, cast)

return
