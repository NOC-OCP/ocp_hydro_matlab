function d = get_from_rvdas_info(vin)

clear d

varlist = mrvdasnames(1); % use any argument to suppress printing from within the call

rvdas_pull;

vmexec = varlist(:,1);
vrvdas = varlist(:,2);

kmatch = find(strcmp(vin,vmexec));

if isempty(kmatch)
    fprintf(2,'\n%s %s %s\n\n','*** stream ',vin,' not found');
    error
end

vrvd = vrvdas{kmatch};

cmd = ['vdef = defs.' vrvd ';']; eval(cmd)




rootcsv = '/local/users/pstar/jc211/mcruise/data/csv_gash/';

csvname = [rootcsv vin '_' datestr(now,'yyyymmddHHMMSSFFF') '.csv'];

sqlname = vdef{1,1};

sqltext = ['\copy (select time from ' sqlname ' order by time asc limit 1) to ''' csvname ''' csv '];
psql_string = ['psql -h rvdas.cook.local -U rvdas -d "JC211" -c "' sqltext '"'];
system(psql_string);
fid = fopen(csvname,'r');
t = fgetl(fid);
fclose(fid);

% padding strings
e4 = '.000+00';
e2 = '00+00';
e1 = '0+00';


lt = length(t);
% if lt == 26; continue; end
% if lt == 25; continue;end
% if lt == 24; continue;end
% if lt == 22; continue;end
switch lt
    case 26
        % do nothing
    case 25
        t = [t(1:22) e1];
    case 24
        t = [t(1:21) e2];
    case 22
        t = [t(1:19) e4];
    otherwise
        % should never occur
end

v = sscanf(t,'%4d-%2d-%2d %2d:%2d:%6f+%*2d'); % * means skip %2d
v = v(:)';
dn1 = datenum(v);

sqltext = ['\copy (select time from ' sqlname ' order by time desc limit 1) to ''' csvname ''' csv '];
psql_string = ['psql -h rvdas.cook.local -U rvdas -d "JC211" -c "' sqltext '"'];
system(psql_string);
fid = fopen(csvname,'r');
t = fgetl(fid);
fclose(fid);

% padding strings
e4 = '.000+00';
e2 = '00+00';
e1 = '0+00';


lt = length(t);
% if lt == 26; continue; end
% if lt == 25; continue;end
% if lt == 24; continue;end
% if lt == 22; continue;end
switch lt
    case 26
        % do nothing
    case 25
        t = [t(1:22) e1];
    case 24
        t = [t(1:21) e2];
    case 22
        t = [t(1:19) e4];
    otherwise
        % should never occur
end

v = sscanf(t,'%4d-%2d-%2d %2d:%2d:%6f+%*2d'); % * means skip %2d
v = v(:)';
dn2 = datenum(v);





sqltext = ['\copy (select count(*) from ' sqlname ' ) to ''' csvname ''' csv '];
psql_string = ['psql -h rvdas.cook.local -U rvdas -d "JC211" -c "' sqltext '"'];
system(psql_string);

ncyc = load(csvname);

fprintf(1,'\n%s\n%s\n\n',vin,sqlname)

fprintf(1,'%s %s\n','File start ',datestr(dn1,31));
fprintf(1,'%s %s\n','File end   ',datestr(dn2,31));
fprintf(1,'%s %d\n','num cycles ',ncyc);

system(['/bin/rm ' csvname]);


% now print names and units

fprintf(1,'%20s %20s\n','time','string')

vuse = vdef;
vuse{1,1} = 'time';
vuse{1,2} = 'string';

for kl = 1:size(vuse,1)
    pad = '                                            ';
    q = '''';
    s1 = vuse{kl,1}; s1 = [pad q s1 q]; s1 = s1(end-15:end);
    s2 = vuse{kl,2}; s2 = [q s2 q pad]; s2 = s2(1:30);
    
    fprintf(1,'%s %s\n',s1,s2);
end

d.dn1 = dn1;
d.dn2 = dn2;
d.ncyc = ncyc;
d.vdef = vuse;

