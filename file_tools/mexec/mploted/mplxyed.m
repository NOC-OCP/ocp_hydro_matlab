function pdfot = mplxyed(varargin)

% function mplxyed
% use:
% 
% mplxyed
% 
% or
% 
% mplxyed(pdf) if you already have a pdf to describe the initial plot
%
% I haven't yet worked out the syntax to enable the pdf to be offered as
% the first response form the keyboard, but the pdf is correctly pulled in as the first element
% of MEXEC_A.MARGS_IN.
% 
% not much help yet, I'm afraid
% the plot appearance is controlled by pdfs in much the same way as
% for mplotxy; for the data selection and edit prompts, read the prompt and
% good luck !
%
% An edit file of the form mplxyed_yyyymmdd_HHMMSS_dataname records any
% edits. The name of this file is included in the history file for the
% dataname.
%

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mplxyed';
m_proghd

global hplot x1 x2 r1 r2 c1 c2 % hplot is a structure used to pass information between the subroutines
% x1 and x2 are the startdc and stopdc in m_edplot
hplot = [];

m = 'Type pdf for initial plot; Type c/r for none: ';
if ~isempty(MEXEC_A.MARGS_IN_LOCAL)
    if ~isstruct(MEXEC_A.MARGS_IN_LOCAL{1})
        pdfin = [];
    else
        % pull the first argument assuming it is a pdf
        pdfin = m_getinput(m,'v');
    end
else
    pdfin = [];
end

if ~isstruct(pdfin); pdfin = []; end

% MEXEC_A.MARGS_IN_LOCAL(1:length(varargin)) = [];
% MEXEC_A.MARGS_IN = MEXEC_A.MARGS_IN_LOCAL;
if isstruct(pdfin)
    if nargin == 2
        pdfin.ncfile.name = varargin{2};
    end
end
pdfot = m_edplot(pdfin); % this also checks we have a valid mstar file

% BAK on JC032: suggestion from lmm to have an option to return to inital
% or earlier pdfs
pdfsave{1} = pdfot;
%-----

% record info about input file so we have it for the history file
h = m_read_header(pdfot.ncfile);
hist = h;
hist.filename = pdfot.ncfile.name;
MEXEC_A.Mhistory_in{1} = hist;

h = m_read_header(pdfot.ncfile.name);
ynumlist = m_getvlist(pdfot.ylist,h);
if isfield(pdfin,'varednum') && isnumeric(pdfin.varednum) && pdfin.varednum>0
    vared = pdfin.varednum;
    fprintf(MEXEC_A.Mfidterm,'set to edit variable %d, %s\n',vared,h.fldnam{ynumlist(vared)});
else
    m = 'Type the name or number of the variable you wish to edit from the list below, or return to quit ';
    fprintf(MEXEC_A.Mfidterm,'%s\n',m)
    for k = 1:length(hplot)
        m1 = [sprintf('%3d ',k) h.fldnam{ynumlist(k)}];
        fprintf(MEXEC_A.Mfidterm,'%s\n',m1)
    end
    m = sprintf('%s',': ');
    vared = m_getinput(m,'s');
    if isfinite(str2double(vared))
        vared = str2double(vared);
    else
        vared = find(strcmp(vared,h.fldnam(ynumlist)));
    end
    if isempty(vared) || isnan(vared)
        disp('exiting mplxyed'); return
    elseif vared<=0 || vared>length(hplot)
        vared = m_getinput('try again (number): ', 'd');
    end
end

yname = pdfot.ylist;
xname = pdfot.xlist;

xdo = get(hplot(vared),'xdata');
ydo = get(hplot(vared),'ydata');

kedit = 0;
ok = 0;
while ok == 0
    m = 'which action ? ';
    m1 = 's : select data cycles';
    m2 = 'w : plot with selected data cycles removed';
    m3 = 'o : plot with original data (undoes w)';
    m4 = 'a : zoom but make ''auto'' tick values ';
    m5 = 'z : zoom to exact area to be chosen with cursor';
    m6 = 'l : list selected data';
    m7 = 'e : edit selected data to NaN (in data file)';
    m8 = 'q : quit';
    m9 = 'r : refresh';
    m10 = 'f : replot with original view'; % bak on jc032 insert new option
    m11 = 'b : go back to previous view'; % bak on jc032 new option
    fprintf(MEXEC_A.Mfidterm,'%s\n',m,m1,m6,m2,m3,m4,m5,m10,m11,m7,m9,m8); % bak on jc032 inster new option
    var = m_getinput(' ','s');

    switch var
        case 'l'
            % list
            m_edlist
        case 's'
            try
                kfind = m_edfinddc(pdfot);
            catch
                disp('try again; select diagonal corners with crosshairs');
                kfind = m_edfinddc(pdfot);
            end
            m = [sprintf('%d',length(kfind{vared})) ' data cycles selected'];
            fprintf(MEXEC_A.Mfidterm,'%s\n',m,' ');
        case 'w'
            xd2 = xdo;
            yd2 = ydo;
            yd2(kfind{vared}) = nan;
            bad = isnan(xd2+yd2);
            xd2(bad) = [];
            yd2(bad) = [];
            set(hplot(vared),'xdata',xd2);
            set(hplot(vared),'ydata',yd2);
        case 'o'
            set(hplot(vared),'xdata',xdo);
            set(hplot(vared),'ydata',ydo);
        case 'e'
            % edit
            m_ededit            
%             need to finish m_ededit to do housekeeping, nabs, version, lock file, etc
        case 'z'
            try
                pdfot = m_edzoom(pdfot,'n');
            catch
                disp('try again; select diagonal corners with crosshairs');
                pdfot = m_edzoom(pdfot,'n');
            end
            pdfsave = [pdfsave {pdfot}]; % bak jc032 save this view
            ydo = get(hplot(vared),'ydata');
            xdo = get(hplot(vared),'xdata');
        case 'a'
            try
                pdfot = m_edzoom(pdfot,'y');
            catch
                disp('try again; select diagonal corners with crosshairs');
                pdfot = m_edzoom(pdfot,'n');
            end
            pdfsave = [pdfsave {pdfot}]; % bak jc032 save this view
            ydo = get(hplot(vared),'ydata');
            xdo = get(hplot(vared),'xdata');
        case 'r'
            pdfot = m_edrefresh(pdfot);
            ydo = get(hplot(vared),'ydata'); % bak jc032 update xdo, ydo
            xdo = get(hplot(vared),'xdata');
        case 'f' % bak jc032 new option
            pdfot = m_edrefresh(pdfsave{1});
            pdfsave = [pdfsave {pdfot}]; % bak jc032 save this view
            ydo = get(hplot(vared),'ydata'); % bak jc032 update xdo, ydo
            xdo = get(hplot(vared),'xdata');
        case 'b' % bak jc032 new option
            if length(pdfsave) > 1 % don't go back if there is only one saved pdf
                pdfsave(end) = [];
                pdfot = m_edrefresh(pdfsave{end}); % bak jc032 new option
                ydo = get(hplot(vared),'ydata'); % bak jc032 update xdo, ydo
                xdo = get(hplot(vared),'xdata');
            else
                m = 'No previous pdfs saved';
                fprintf(MEXEC_A.Mfider,'%s\n',' ',m,' ');
            end
        case 'q'
            ok = 1; %quit
        otherwise
            disp('Option not recognised - please try again')
    end
end

if kedit > 0
%     editing has been done
%     bak jc069 put more detailed information about source and output files in edit record file
%     hist contains the header of the input file, used to write the history
%     file
    mess_1 = ['in_file     : ' hist.filename];
    mess_2 = ['in_dataname : ' hist.dataname];
    mess_3 = ['in_version  : ' sprintf('%d',hist.version)];

    m_finis(pdfot.ncfile);
    h = m_read_header(pdfot.ncfile);
    if ~MEXEC_G.quiet; m_print_header(h); end

    hist = h;
    hist.filename = pdfot.ncfile.name;
    MEXEC_A.Mhistory_ot{1} = hist;
    motsave = MEXEC_A.MARGS_OT;
    % cludge MEXEC_A.MARGS_OT to use the write_history feature
    nowtime = datestr(now,'yyyymmdd_HHMMSS');
    % This function is used when processing underway stream and don't always want to write in the CTD diectory (DAS)
    % change so that write in the same directory as the datafile
    %editfn = [mgetdir('M_CTD') '/mplxyed_' nowtime '_' h.dataname];
    try 
        % bak, jc211, 20 feb 2021
        % If the program has not been run using a pdfin, then pdfin is an
        % empty array, not a structure, so the next line fails.
        %  [flpath,flname,flext] = fileparts(pdfin.ncfile.name);
        % I haven't tested it thoroughly, but pdfot is probably populated even
        % if pdfin is empty. Try next line instead
        [flpath,~,~] = fileparts(pdfot.ncfile.name);
        if isempty(flpath) % if this is a simple run on a local file, the filename could just be 'surfmet_jc211_d050_edt.nc' and flpath is empty
            flpath = '.'; 
        end
        flpath = fullfile(flpath,'editlogs');
        if ~exist(flpath,'dir'); mkdir(flpath); end
    catch
        flpath = '.'; % flname and flext not needed.
    end
    editfn = fullfile(flpath, ['mplxyed_' nowtime '_' h.dataname]);
    % bak jc069 put more detailed information about source and output files in edit record file
    mess_4 = ['ot_file     : ' hist.filename];
    mess_5 = ['ot_dataname : ' hist.dataname];
    mess_6 = ['ot_version  : ' sprintf('%d',hist.version)];

    fid = fopen(editfn,'w'); mfixperms(editfn);
    fprintf(fid,'%s\n',editfn,mess_1,mess_2,mess_3,mess_4,mess_5,mess_6,vnam);
    fprintf(fid,'%d\n',kedits);
    fclose(fid); mfixperms(editfn);
    MEXEC_A.MARGS_OT = {'edit variable' vnam [sprintf('%d',length(kedits)) ' data cycles'] 'recorded in file' editfn};
    m_write_history;
    MEXEC_A.MARGS_OT = motsave;
end

%unfinished: what we could do with is a program that would take the list of
%data cycles from editfn and re-edit the data file to set precisely those data cycles
%to nan. Then the faked write_history could generate a script to repeat the
%data edit from the list of data cycles without having to select. At the moment this
%effect could be faked with some dort of mask form an existing 'clean'
%file.


return



