function  msdfinfo(instream,tonly)
% function msdfinfo(instream,tonly)
%
% eg 
% msdfinfo adupos
% msdfinfo('winch','f')
%
% Lists the start and end time and number of data cycles for a stream name
%
% The instream argument should be a scs stream name or the corresponding mexec short name
% If tonly is 'fast' or 'f', then don't count the data cycles. (Quicker option
% for 'mtlookd fast')
%
% Call mtgetdfinfo to obtain the first and last datacycle in all
% scs files that match tstream; format and print the result.
% 
% mstar scs (mt) routine; requires mexec to be set up
%
% The scs files are searched for in a directory MEXEC_G.uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% first draft BAK JC032
%
% 8 Sep 2009: SCS version of original techsas script, for JR195
% The searched directory is MEXEC_G.uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% for example.

m_common

tstream = msresolve_stream(instream);
if nargin < 2; tonly = ' '; end

[t1 t2 num] = msgetdfinfo(tstream,tonly);

% bak for jr195 17 Sep 2009
% trap case where the stream doesn't exist and t1 returned as -1
if t1 < 0
    return
end

if t1 > 0
    dvnow = datevec(t1);
else
    dvnow = datevec(now);
end
yyyy = dvnow(1);
doffset = datenum([yyyy 1 1 0 0 0]);
daynum1 = 0; daynum2 = 0;
if t1 > 0; daynum1 = floor(t1) - doffset + 1; end
if t2 > 0; daynum2 = floor(t2) - doffset + 1; end

str1 = datestr(t1,'yy/mm/dd');
str1a = datestr(t1,'HH:MM:SS');
str2 = datestr(t2,'yy/mm/dd');
str2a = datestr(t2,'HH:MM:SS');

if strncmp(tonly,'f',1)
    % fast option
    if ~isnan(num)
        fprintf(MEXEC_A.Mfidterm,'   %8s   %03d %8s  %s  %03d %8s   %8s  %s\n',str1,daynum1,str1a,'to',daynum2,str2a,str2,tstream);
    end
else
    if num > 0
        fprintf(MEXEC_A.Mfidterm,'%10d   %8s   %03d %8s  %s  %03d %8s   %8s  %s\n',num,str1,daynum1,str1a,'to',daynum2,str2a,str2,tstream);
    else
        fprintf(MEXEC_A.Mfidterm,'%10s   %23s  %2s  %23s  %s\n','No data   ',' ',' ',' ',tstream);
    end
end
