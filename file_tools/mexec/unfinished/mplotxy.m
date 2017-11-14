function pdfot = mplotxy(varargin)
% function mplotxy(pdf,ncfile)
%
% to remove a field in pdf use 
% pdf = rmfield(pdf,'stopdc')
% or whatever you want.
%
% At present, if M  variables are to be plotted we require
% y to be M x N and yax to be M x 2
% xax,yax are axes limits
% nxt,nyt are number of tick intervals
% cols is a sequence of colors to be cycled through eg 'krbgmcy'
% any colour not in this list has its y tick labels in black.
%
% pdf is a structure
% pdf.xlist eg 'press'
% pdf.ylist eg 'temp salin oxygen'
% pdf.xax   eg [0 3000]
% pdf.yax   eg [0 30 ; 30 40 ; 100 300;]
% pdf.startdc eg 1 (default 1 if not set)
% pdf.stopdc  eg 1000 (default end if not set)
% pdf.ntick   eg [6 10] (default 10 10 if not set)
% pdf.cols    eg 'krbm' (default 'krbmcgy' if not set)
% pdf.symbols    eg {'+' 'o' '*'} (cell array of symbols; default {''} if not set)
% pdf.styles    eg {'-' '-' '--' '.' ''} (cell array of line styles; default {'-'} if not set)
% pdf.widths    eg [2 2 1 2] (real array of line widths; default [2] if not set)
% pdf.plotsize    eg [20 12] size in cm (default [18 12])
% pdf.time_var     name or number of time variable
% pdf.time_scale   scaling to be used on axis if time is independent
%                   variable; see options below.
% pdf.dctime       include start and stop data cycle times in plot if available (0 for
%                    no, 1 (default) for yes)
%
% if length of startdc is > 1, look for a time variable in the file.
% The time variable can be specified as pdf.time_var, or otherwise the
% code will look for the first variable it identifies as time (see
% m_isvartime), which presently means it must begin with the string 'time',
% but the string beginnings can be set in global variable MEXEC_A.Mtimnames
%
% if a time variable is found, it will be used to determine startdc and
% stopdc. All data between (t0 <= t <= t1) the start time and stop time are plotted
% eg 
% startdc = [yyyy mo dd hh mm ss]
% or
% startdc = [dayofyear hh mm ss]
% thus the length of startdc is 1,4 or 6.
%
% options for x axis handling time handling, passed in as pdf.time_scale
% 0 don't mess with x data, useful for example if x & y are lon and lat
% 1 xdata are seconds after start time
% 2 xdata are minutes after start time (default if x is a time variable)
% 3 xdata are hours after start time
% 4 xdata are days after start time
% 9 xdata are day of year [yyyy 1 1 0 0 0] == 1
%

% It is possible to create multiple panels in one figure.
% It is also possible to plot from successive pdfs in one panel (pexec
% overxy capability)
% To make multiple panels, the procedure is equivalent to the equivalent in
% mcontr. Use pdfin.newfigure = one of 'portrait' 'landscape' 'none' to
% decide whether a new page is required. Option 'none' allows you to select
% a new plotorg and plotsize.
%
% To achieve multiple plots in the same panel: The figure handle is returned in
% pdfot.axeshandle. Combining this with pdfin.over = 1 (numeric unity, not
% character 1) the program uses the same figure axes. Remember that the
% data plotted are normalised with pdfin.xax and pdfin.yax. If over == 1,
% the y axis labels are omitted. An example that would achieve two
% overplots in one figure follows:


% % % % pdf.newfigure = 'p';  % new portrait plot
% % % % pdf.plotsize = [18 6];
% % % % pdf.ntick = [5 10];
% % % % 
% % % % pdf.plotorg = [3 2];
% % % % pdf.over = 0;
% % % % pdf.xlist = 'press';
% % % % pdf.xax = [0 500];
% % % % pdf.ylist = 'temp';
% % % % pdf.cols = 'k';
% % % % pdf.yax = [0 40];
% % % % pdf.ncfile.name = 'ctd_jc032_001_2db';
% % % % pdf = mplotxy(pdf)
% % % % 
% % % % pdf.over = 1;  %overplot next file in same panel; keep same axes handle
% % % % pdf.ylist = 'temp';
% % % % pdf.cols = 'r';
% % % % pdf.yax = [0 40];
% % % % pdf.ncfile.name = 'ctd_jc032_002_2db';
% % % % pdf = mplotxy(pdf)
% % % % 
% % % % pdf.newfigure = 'none';  % move origin to new location in same figure
% % % % pdf.plotorg = [3 10];
% % % % pdf.over = 0;
% % % % pdf.ylist = 'psal';
% % % % pdf.cols = 'k';
% % % % pdf.yax = [30 40];
% % % % pdf.ncfile.name = 'ctd_jc032_001_2db';
% % % % pdf = mplotxy(pdf)
% % % % 
% % % % pdf.over = 1;
% % % % pdf.ylist = 'psal';
% % % % pdf.cols = 'r';
% % % % pdf.yax = [30 40];
% % % % pdf.ncfile.name = 'ctd_jc032_002_2db';
% % % % pdf = mplotxy(pdf)


% unfinished: things to consider
% AND: if y is 2-D, then plot each row or column separately, as in matlab 'plot'.
% at present convert all gridded data to 1-D; really we need a completely
% different program to handle a case of one independent variable, but
% 2-D ax and y data. In that case a matlab plot command returns as many handles
% as there are columns of data. We also need a version of overxy.
% should carry time_scale in a variable called pdf.time_scale not cludge it on
% start/stopdc. Should probably allow start and stop to work differently.
% eg one on time and the other on data cycle. [ I think this is now done,
% but it needs to be extensively tested].

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'mplotxy';
if ~MEXEC_G.quiet; m_proghd; end

% remove the varargin from MEXEC_A.MARGS_IN because it will be passed straight into
% m_edplot. Normally, arguments are read from varargin or MEXEC_A.MARGS_IN using
% m_getinput. If we don't remove varargin here it will 'accumulate'
MEXEC_A.MARGS_IN_LOCAL(1:length(varargin)) = [];
MEXEC_A.MARGS_IN = MEXEC_A.MARGS_IN_LOCAL;
pdfot = m_edplot(varargin{:});

