% makes summary table for latex document
%
% statnum
% time start, bottom, end
% cordep
% maxp
% maxwire
% ht off (min(altim))
% date yymmdd
% dayofyear
% pos start bottom end
% ht off (watdep-dpth(maxp))
% num diff bottle depths
% num niskin bottles sampled for each param set
% salt
% o2
% nuts
% cfc
% co2
% comments
%

%write to ascii file
stnlistname = [root_sum '/station_summary_' mcruise '_ltable.tex'];
fid = fopen(stnlistname,'w');

% list headings
fprintf(fid,'%s','\begin{tabular}{|');
fprintf(fid,'%s|',{repmat('r|',1,length(varnames))});
fprintf(fid,'%s\n','}\\ \hline');
fprintf(fid,'%3s & %8s & %4s &', 'stn', 'yy/mo/dd', 'hhmm');
fprintf(fid,' %10s & %11s &', 'dg min lat', 'dg min lon');
fprintf(fid,' %4s &', varnames{7:end});
fprintf(fid,' %s\n','Comments');

for k = stnall

    ss = datestr(dns(k),'yy/mm/dd HHMM');
    sb = datestr(dnb(k),'yy/mm/dd HHMM');
    se = datestr(dne(k),'yy/mm/dd HHMM');
    fprintf(fid,'\n%3s %s\n', '', ss);
    fprintf(fid,'%03d %s', k, sb);

    l1 = 'N'; if lat(k) < 0; l1 = 'S'; end
    l2 = 'E'; if lon(k) < 0; l2 = 'W'; end
    latk = abs(lat(k));
    latd = floor(latk);
    latm = 60*(latk-latd); if latm >= 59.995; latm = 0; latd = latd+1; end% prevent write of 60.00 minutes
    lonk = abs(lon(k));
    lond = floor(lonk);
    lonm = 60*(lonk-lond); if lonm >= 59.995; lonm = 0; lond = lond+1; end% prevent write of 60.00 minutes
    fprintf(fid,' %2d %05.2f %s %3d %05.2f %s', latd, latm, l1, lond, lonm, l2);

    for no = 7:length(varnames)
       eval(['data = ' varnames{no} '(k);']);
       % jc159 bak30 march 2018; width of field is width of var name,
       % minimum 4.
       vn = varnames{no};
       fwid = length(vn);
       fwid = max(4,fwid);
       form = sprintf('%s%d%s',' %',fwid,'.0f');
       fprintf(fid, form, data);
    end

    fprintf(fid,'  %s',comments{k});
    fprintf(fid,'\n');

    fprintf(fid,'%3s %s \n', '', se);

end

fclose(fid);

cordep(cordep == -999) = -99999;
resid(resid == -999) = -99999;
maxp(maxp == -999) = -99999;
maxd(maxd == -999) = -99999;
minalt(minalt == -9) = -99999;


%write to mstar .nc file

prefix1 = ['station_summary_' mcruise '_'];
otfile2 = [root_sum '/' prefix1 'all'];
dataname = [prefix1 'all'];

% sorting out units for msave
varnames_units = {};
for k = 1:length(varnames)
    varnames_units = [varnames_units; varnames(k)];
    varnames_units = [varnames_units; {'/'}];
    varnames_units = [varnames_units; varunits(k)];
end

timestring = ['[' sprintf('%d %d %d %d %d %d',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN) ']'];

time_start = 86400*(dns-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN));
time_bottom = 86400*(dnb-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN));
time_end = 86400*(dne-datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN));

MEXEC_A.MARGS_IN_1 = {
    otfile2
    };
MEXEC_A.MARGS_IN_2 = varnames(:);
MEXEC_A.MARGS_IN_3 = {
    ' '
    ' '
    '1'
    dataname
    '/'
    '2'
    MEXEC_G.PLATFORM_TYPE
    MEXEC_G.PLATFORM_IDENTIFIER
    MEXEC_G.PLATFORM_NUMBER
    '/'
    '4'
    timestring
    '/'
    '8'
    };
MEXEC_A.MARGS_IN_4 = varnames_units(:);
MEXEC_A.MARGS_IN_5 = {
    '-1'
    '-1'
    };
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3; MEXEC_A.MARGS_IN_4; MEXEC_A.MARGS_IN_5];
msave

