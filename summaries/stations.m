% stations: read water depth for ctd cast from ldeo ladcp or combined
% altimeter and depth readings
%
% Use: stations        and then respond with station number, or for station 16
%      stn = 16; stations;

scriptname = 'stations';

% resolve root directories for various file types
mcsetd('M_CTD'); root_sal = MEXEC_G.MEXEC_CWD;
mcd('M_CTD'); % change working directory

stnlist=1:205;
otdata=ones(3,length(stnlist))+nan;

prefix1 = ['dcs_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
% stnlist=200;
for k=stnlist
    infile=[prefix1 sprintf('%03d',k)];
    if exist([infile '.nc'])~=2
        continue;
    end;
    p=m_read_header(infile);
    t_o=datenum(p.data_time_origin)-datenum([p.data_time_origin(1) 1 1 0 0 0]);
    t_o=t_o*86400;
    
    MEXEC_A.MARGS_IN={
        infile
        'time_start time_end'
        ' '
        };

    t=mload;
    otdata(1,k)=k;
    otdata(2,k)=t.time_start+t_o;
    otdata(3,k)=t.time_end+t_o;

end;



mcd M_SCRIPTS;
fid = fopen( 'stations.dat','wt');
fprintf(fid,'%03d  %f %f\n',otdata);
fclose(fid);