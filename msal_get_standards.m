% msal_get_standards
%
% based on msal_01 to read autosal csv file, and extract standards
%
% msal_01 overhauled on jr302, so this was overhauled too.
%
% msal_get_standards
%
% Complete overhaul on jr302 by BAK 7 June 2014. Ignore the first column
% of crate label, and sort out the values according to the sample number.
% 00101 to 99901 for CTD samples stations 1 to 999
% 999001 to 999999 for standards
% 001000000 to 366235959 for TSG timed samples dddhhmmss
%
% assume sal_jr302_01.csv is append of all csv files.

scriptname = 'msal_get_standards';


% resolve root directories for various file types
root_sal = mgetdir('M_BOT_SAL');
root_ctd = mgetdir('M_CTD'); % change working directory

prefix1 = ['sal_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];
prefix2 = ['sal_' MEXEC_G.MSCRIPT_CRUISE_STRING '_'];

standards_fn = [prefix2 'standards.txt'];

if ~exist('sal_csv_file', 'var')
    %   infile1 = [root_sal '/' prefix1 stn_string '.csv'];
    % bak on jr302: we now use an appended autosal csv file that contains all the analysed values.
    % prompt for name of appended auotsal csv file if it hasn't
    % been pre-set:
    sal_csv_file = input('type name of appended autosal csv file (eg sal_jr302_01.csv) ','s');
    infile1 = [root_sal '/' sal_csv_file];
else
    infile1 = [root_sal '/' sal_csv_file];
end

% bak on jr281 april 2013, for stations with no salt samples we want to
% generate a file with nan for data and 9 for flag

indata=mtextdload(infile1,',');

% for variable arrays, parse to see which rows hold data
nrows=length(indata);
indexstn =[];
indexstd =[];
indextsg =[];
for k=1:nrows
    data_cell=indata{k};
    if length(data_cell) < 10; continue; end
    strng=data_cell{10};
    if isempty(strng); 
        continue;
    else
        fprintf(1,'%s\n',strng)
    end;
    if strmatch(strng(1),'s') % this is the sampnum heading line
        continue
    end
    sampraw = str2num(strng);
    if isempty(sampraw) % number not decoded
        continue
    end
    if(sampraw >= 00101 & sampraw <= 99901) % ctd sample
        indexstn = [indexstn k];
    end
    if(sampraw >= 999000 & sampraw <= 999999) % standard
        indexstd = [indexstd k];
    end
    if(sampraw >= 001000000 & sampraw <= 366235959) % time of tsg sample
        indextsg = [indextsg k];
    end
end;

indexstn = unique(indexstn);
indexstd = unique(indexstd);
indextsg = unique(indextsg);

% now load the data to an array and assign variable names
varnames={'station','salbot','run1','run2','run3','runavg','salinity','sampnum', 'flag'};
varunits={'number','number','number','number','number','number','pss-78','number','woce table'};

% otdata has 24 rows, one for each niskin bottle
otdata=ones(length(indexstd),length(varnames)+1)+nan;
% otdata=ones(24,length(varnames))+nan;


l=1;
for krow=indexstd
    data_cell = indata{krow};
    strng=data_cell{1};
    % % %     otdata(l,1)=str2double(strng(4:6));
    % % %     otdata(l,2)=str2double(strng(8:end));
    % % % %     otdata(l,2)=str2double(strng(7:end));%for the badly named files
    % bak 12 jun 2014 revised on jr302 so standard number is taken from sample number
    numeric = str2double(data_cell{10});
    otdata(l,1) = numeric;
    
    for kcol=[4:11];
        % jc159 we aren't assigning flags in autosal csv file; only
        % assigning sample number
        % backwards compatible fix
        if kcol <= length(data_cell)
        otdata(l,kcol-1)=str2double(data_cell{kcol});
        end
    end;


    l=l+1;
end;


% output data
fid = fopen(standards_fn,'w');
for kloop = 1:size(otdata,1)
%     fprintf(fid,'%d  %10.6f\n',otdata(kloop,1),otdata(kloop,4));
%     fprintf(fid,'%d  %10.6f\n',otdata(kloop,1),otdata(kloop,6)); % apparent bug fixed on jr306; average value is in 6th column of otdata; 7th column of input
    fprintf(fid,'%d  %10.6f %d\n',otdata(kloop,1),otdata(kloop,6),otdata(kloop,10)); % apparent bug fixed on jr306; average value is in 6th column of otdata; 7th column of input
end
fclose(fid);


