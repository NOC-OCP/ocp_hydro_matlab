function mtlookd(varargin)
% function mtlookd(arg)
%
% All streams in the techsas directory are scanned, and mtdfinfo is used
% to produce a summary of earliest and latest data for each stream.
%
% The one possible argument is the character string 'f' or 'fast'
% in which case the number of data cycles is not counted.
% 
% mstar techsas (mt) routine; requires mexec to be set up
%
% The techsas files are searched for in a directory MEXEC_G.uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% first draft BAK JC032
%

tupdate_def = '20';
fontsize = 12;
fontname = 'courier';

if nargin == 0
    argcell = {' ' tupdate_def}; % defaults
end

if nargin == 1; 
    arg1 = varargin{1};
    argnum = str2num(arg1);
    if isempty(argnum) % string wasnt a time interval
        argcell = {arg1 tupdate_def};
    else % arg1 was a time interval
        argcell = {' ' arg1};
    end
end

if nargin == 2;
    arg1 = varargin{1};
    arg2 = varargin{2};
    argnum = str2num(arg2);
    if isempty(argnum) % arg2 wasnt a time interval; swap them round
        argcell = {arg2 arg1};
    else
        argcell = {arg1 arg2};
    end
end

arg1 = argcell{1}; % 'f' or ' ' for fast or full
arg2 = argcell{2}; % time interval for updates

tupdate = str2num(arg2);

tonly = ' ';
if strncmp(arg1,'f',1); tonly = 'f'; end % set the tonly flag to f (fast); Otherwise it remains as ' '.

tstreams = mtgetstreams;
nstreams = length(tstreams);
y0 = -(max([20 nstreams])+2);
y1 = 1;

m_figure
set(gca,'position',[0 0 1 1]);
h = gca;
set(h,'box','off');
set(h,'xtick',[]);
set(h,'ytick',[]);
axis([0 20 y0 y1])

xt1 = 0.5;

nstreams = length(tstreams);
ht = zeros(nstreams+1,1);
dstr = cell(nstreams+1,1);
for k = 1:nstreams+1
    dstr{k} = ' ';
    ht(k) = text(xt1,-k,dstr{k});
    set(ht(k),'fontsize',fontsize,'fontname',fontname)
end

while 1
    for k = 1:nstreams
        mess = mtdfinfo2(tstreams{k},tonly);
        mess(strfind(mess,'_')) = ' '; 
            
        if ~strcmp(mess,dstr{k+1})
            dstr{k+1} = mess;            
            set(ht(k+1),'string',mess,'color','k')
            %         only set to black if string has changed, else keep as red
            pause(0.02)
        else
            set(ht(k+1),'string',mess,'color','r')
            %         only set to black if string has changed, else keep as red
            pause(0.02)
        end
    end

    while 1
        tnow = now;
        dvnow = datevec(tnow);
        yyyy = dvnow(1);
        doffset = datenum([yyyy 1 1 0 0 0]);
        daynum = floor(tnow) - doffset + 1;
        daysecs = floor(86400*(tnow-floor(tnow)));

        str1 = datestr(tnow,'yy/mm/dd');
        str1a = datestr(tnow,'HH:MM:SS');

        if strncmp(tonly,'f',1)
            % fast option
            tstr = sprintf('                                %03d %8s   %8s  %s\n',daynum,str1a,str1,'   time now');
        else
            tstr = sprintf('                                          %03d %8s   %8s  %s\n',daynum,str1a,str1,'   time now');
        end
        dtsr{1} = tstr;

        set(ht(1),'string',tstr,'color','k');
        if rem(daysecs,tupdate) <= 3; 
            for k = 0:nstreams; set(ht(k+1),'color','b'); end
            pause(0.02); 
            break; 
        end % pause allows updating of plot display
        % update as soon as we reach a round multiple of seconds, with
        % a range of 2

        pause(1); % approx one second, but ensure we don't accidentally skip over the round number of seconds and fail to update
    end

end




