function mdatapuprvdas(startyy,startddd,starttime,endyy,endddd,endtime,flags,instream,otfile,varlist);
 
 % bak on jc211
 % ignorelast varlist; get all vars in the definition
 
 m_common
 
starthh = floor(starttime/10000);
startmm = floor((starttime-10000*starthh)/100);
startss = starttime-10000*starthh - 100*startmm;
dn1 = datenum([2000+startyy 1 1 0 0 0]) + (startddd-1) + starthh/24 + startmm/1440 + startss/86400;
dv1 = datevec(dn1);

endhh = floor(endtime/10000);
endmm = floor((endtime-10000*endhh)/100);
endss = endtime-10000*endhh - 100*endmm;
dn2 = datenum([2000+endyy 1 1 0 0 0]) + (endddd-1) + endhh/24 + endmm/1440 + endss/86400;
dv2 = datevec(dn2);
 
[dd names units] = mrload(instream,dn1,dn2);

% calculate mexec time in seconds and remove dnum from the names list for
% saving
torg = datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN);
dd.time = (dd.dnum-torg)*86400;
names = [{'time'};names];
units = [{'seconds'};units];
kdnum = find(strcmp('dnum',names));
names(kdnum) = [];
units(kdnum) = [];

nvars = length(names);
namesunits = cell(0);
for kl = 1:nvars
    vname = names{kl};
    cmd = [vname ' = dd.' vname ';']; eval(cmd);
    namesunits = [namesunits;{' '};units(kl)];
end

MEXEC_A.MARGS_IN_1 = {m_add_nc(otfile)};
MEXEC_A.MARGS_IN_2 = names;
MEXEC_A.MARGS_IN_3 = {
    ' '
    ' '
    '8'
    '0'
    };
MEXEC_A.MARGS_IN_4 = namesunits;
MEXEC_A.MARGS_IN_5 = {
    '-1'
    '-1'
    };
    


MEXEC_A.MARGS_IN = [
    MEXEC_A.MARGS_IN_1
    MEXEC_A.MARGS_IN_2
    MEXEC_A.MARGS_IN_3
    MEXEC_A.MARGS_IN_4
    MEXEC_A.MARGS_IN_5
    ];
msave

MEXEC_A.MARGS_IN = {
m_add_nc(otfile)
'y'
'1'
otfile
' '
'2'
MEXEC_G.PLATFORM_TYPE
MEXEC_G.PLATFORM_IDENTIFIER
MEXEC_G.PLATFORM_NUMBER
' '
'4'
MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN
' '
'-1'
'-1'
};
mheadr

nowstring = datestr(now,31);
ncfile_ot.name = m_add_nc(otfile);
m_add_comment(ncfile_ot,'Variables written from rvdas to mstar');
m_add_comment(ncfile_ot,['at ' nowstring]);
m_add_comment(ncfile_ot,['by ' MEXEC_G.MUSER]);
%--------------------------------