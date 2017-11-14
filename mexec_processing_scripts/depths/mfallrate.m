function mfallrate(varargin)
% function mfallrate(varargin)
%
%Search down the downcast for periods where the CTD package reverses or the 
%speed goes below 0.24 m/s (threshold taken from SBE loopedit program that
%this program mostly replicates)
%
%The initial soak is identified by max(pressure-(previous maximum pressure)) 
%with user confirmation of datapoint found.
%
%The soak is flagged bad (NaN) and then datapoints during package reversals and
%slowdowns also marked bad, rest marked good (1)
%
%Variable.*flag is then the cleaned data ready for averaging.

% adapted from mcalc


m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mcalc';
if ~MEXEC_G.quiet; m_proghd; end


fprintf(MEXEC_A.Mfidterm,'%s','Enter name of input disc file  ')
fn_in = m_getfilename;
fprintf(MEXEC_A.Mfidterm,'%s','Enter name of output disc file ')
fn_ot = m_getfilename;
ncfile_in.name = fn_in;
ncfile_ot.name = fn_ot;

% m = 'Output file will be same as input file. OK ? Type y to proceed ';
% reply = m_getinput(m,'s');
% if strcmp(reply,'y') ~= 1
%     disp('exiting')
%     return
% end
ncfile_in
ncfile_in = m_openin(ncfile_in);
ncfile_ot = m_openot(ncfile_ot);

h = m_read_header(ncfile_in);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile_in.name;
MEXEC_A.Mhistory_in{1} = hist;


% --------------------
% Now do something with the data
% first write the same header; this will also create the file
h.openflag = 'W'; %ensure output file remains open for write, even though input file is 'R';
m_write_header(ncfile_ot,h);

%copy selected vars from the infile
m = sprintf('%s\n','Type variable names or numbers to copy (return for none, ''/'' for all): ');
var = m_getinput(m,'s');
if strcmp(' ',var) == 1;
    vlist = [];
else
    vlist = m_getvlist(var,h);
    m = ['list is ' sprintf('%d ',vlist) ];
    disp(m);
end

for k = vlist
    vname = h.fldnam{k};
    numdc = h.dimrows(k)*h.dimcols(k);
    m = ['Copying ' sprintf('%8d',numdc) ' datacycles for variable '  vname ];
    fprintf(MEXEC_A.Mfidterm,'%s\n',m);
    tic; m_copy_variable(ncfile_in,vname,ncfile_ot,vname); toc
end

%file=m_add_nc(infile)
press=nc_varget(ncfile_in.name,'press');

prdiff=diff(press);
 prdiff=[NaN prdiff];

 k=0;
K=NaN*press;

iimp=find(press==max(press));
kk=0;
maxp=0;   %find end of initial soak
maxnegdiff=0; %by finding index of maximum difference between pressure and previous higher max(pressure)
for j=1:iimp  %search from start to deepest pressure (normally overkill but some initial soaks can be deep if trying to warm the CTD up in UCDW - JR165)
    maxp=max(maxp,press(j));
    if maxp-press(j)>maxnegdiff
        if maxp>20&kk==0
            kk=jj; %save previous datacycle if reached a max pressure deeper than usual initial soak
        end
        jj=j;
        
    maxnegdiff=max(maxnegdiff,maxp-press(j));
    end
end

m=['Cast starts at datacycle ' ,num2str(jj),' at ',num2str(press(jj)),' dbar after initial soak'];
disp(m)
figure
 plot(press,'k.')
dataconf=input('Is this datacycle correct? y/n?\n','s');
if isempty(dataconf)|(dataconf~='1'&dataconf~='y')
    if kk>0
   m=['In that case the cast might start at ',num2str(press(kk)),' dbar?'];
disp(m) 
dataconf=input('Is this datacycle correct? y/n?\n','s');
if isempty(dataconf)|(dataconf=='1'|dataconf=='y')
    jj=kk;
    close
else
      plot(press,'k.')
      m = 'Enter datacycle of start of downcast after initial soak\n';
jj = m_getinput(m,'s');
 close    
end
    else
      plot(press,'k.')
       m = 'Enter datacycle of start of downcast after initial soak\n';
jj = m_getinput(m,'d');
 close   
    end
else
    close
end

twoflag=0;  %keep data if data each side is good

 for ip=jj:iimp  %from end of initial soak to deepest pressure
if isfinite(press(ip))

if ip==jj|ip==jj+1|(press(ip)>pressone(k)&prdiff(ip)>0.01) %removes data if data already below it or package going at <0.24m/s
          k=k+1;
          pressone(k)=press(ip);
         % temp1one(k)=temp(i);
         % sig0one(k)=sig0(i);
         if twoflag==1
         K(ip-1)=1;
         end
K(ip)=1;   %this is a flag for data to keep
twoflag=0;
else
    twoflag=twoflag+1;
end
end
 end
K(ip:end)=1; %set all of upcast as good as this method can't deal with bottle stops

       v.data=K;
            newname = 'Fall_rate_flag_good';
            v.name = m_check_nc_varname(newname);
           
        %         v.name = m_getinput(m,'s');
%        m = ['new variable unit, default is : ' defunt '  '];
        v.units = '';
        if strcmp(v.units,' ')
            v.units = m_remove_outside_spaces(defunt);
        end

        % its a new variable, so the other atributes [_FillValue missing_value] will be default
        m_write_variable(ncfile_ot,v);

   




% --------------------



m_finis(ncfile_ot);

hot = m_read_header(ncfile_ot);
if ~MEXEC_G.quiet; m_print_header(hot); end

hist = hot;
hist.filename = ncfile_ot.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;


return
