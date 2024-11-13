function [pdata punits] = mtlast(instream)
% function [data units] = mtlast(instream)
%
% first draft by BAK on JC032
%
% Get the last data cycle from a file.
% If there are output arguments in the call, the results are printed to the
% screen. In that case use a semicolon to supress the echo of the output argument to the
% screen.
%
%
% Examples of use:
%
% mtlast position-Applanix_GPS_JC1.gps;
% mtlast posmvpos;
% mtlast('posmvpos');
% [data units] = mtlast('posmvpos');
%
% The instream can be either a techsas stream name or its mexec short form
% the data and units are returned as arguments.

m_common
tstream = mtresolve_stream(instream);

[t1 t2 n] = mtgetdfinfo(tstream);
dn = t2;


[pdata punits] = mtload(tstream,dn,dn,'/');
% matlabdate = datevec(pdata.time+MEXEC_G.uway_torg);

dvnow = datevec(now);
yyyy = dvnow(1);
doffset = datenum([yyyy 1 1 0 0 0]);
daynum1 = floor(dn) - doffset + 1;
str1 = datestr(dn,'yy/mm/dd');
str1a = datestr(dn,'HH:MM:SS.FFF');




if nargout > 0; return; end

fprintf(MEXEC_A.Mfidterm,'\n%s\n',tstream);
fprintf(MEXEC_A.Mfidterm,'%12s :    %8s   %03d %10s\n\n','last data cycle',str1,daynum1,str1a(1:10));

fields = fieldnames(pdata);
for k = 1:length(fields)
    fn = fields{k};
    s1 = fn;
    cmd = ['s2 = num2str(pdata.' fn ');']; eval(cmd);
    cmd = ['s3 = punits.' fn ';']; eval(cmd);
    fprintf(MEXEC_A.Mfidterm,'%12s : %12s   %15s\n',s1,s2,s3)
end
