function ncfile = cchdo_botnc_to_mstar(cchdo_in,ncfile,dataname)
% function ncfile = cchdo_botnc_to_mstar(cchdo_in,ncfile,dataname)
%
%
% load cchdo data from cchdo_in and write to mstar file ncfile

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'cchdo_botnc_to_mstar';
m_proghd;

hatt = m_default_attributes;
hatt.dataname = dataname;

ncfile = m_openot(ncfile); %check it is not an open mstar file

cnames = m_unpack_varnames(cchdo_in);
cchdo_time_dim = nc_getdiminfo(cchdo_in.name,'pressure'); 
cchdo_time_length = cchdo_time_dim.Length;

for k = 1:length(cnames)
    m = ['Reading variable ' cnames{k}];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
    clear cchdo_data cchdo_units v
    switch cnames{k}
        case {'latitude','longitude','station','cast'}
            hatt.(cnames{k}) = nc_varget(cchdo_in.name,cnames{k},0,1);
        case {'time','woce_date','woce_time'}
            md.(cnames{k}) = nc_varget(cchdo_in.name,cnames{k},0,1);
        otherwise
            data = nc_varget(cchdo_in.name,cnames{k},0,cchdo_time_length);
            if ischar(data)
                continue
            else
                data(data==-999) = nan;
                d.(cnames{k}) = data;
                u.(cnames{k}) = nc_attget(cchdo_in.name,cnames{k},'units');
            end
    end
end

dd = rem(md.woce_date,100);
w2 = md.woce_date-dd;
mo = rem(w2,10000)/100;
yyyy = floor(md.woce_date/10000);
mm = rem(md.woce_time,100);
w2 = md.woce_time-mm;
hh = rem(w2,10000)/100;
timunt = sprintf('seconds since %04d-%02d-%02d %02d:%02d:%02d',yyyy,mo,dd,hh,mm,0);
hatt.fldnam = fieldnames(d);
hatt.fldunt = u;

mfsave(ncfile.name, d, h)

nowstring = datestr(now,31);
m_add_comment(ncfile,'This mstar file created from cchdo file');
m_add_comment(ncfile,cchdo_in.name);
m_add_comment(ncfile,['at ' nowstring]);
