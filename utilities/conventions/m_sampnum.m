function varargout = m_sampnum(varargin)
% m_sampnum 
%   with no input arguments, displays conventions for sampnum used by
%     mexec_processing
%
% [isctd, isuway, isstrd] = m_sampnum(sampnum)
%   with single input argument, returns masks of which sampnums are from
%     CTD, from underway, or other (i.e. from standards) 
%   sampnum is a numeric vector
%
% sampnum = m_sampnum('ctd', statnum, position)
%   with first input argument 'ctd', calculates sampnum for CTD samples
%     according to the convention 
%   statnum and position are numeric vectors of the same size
% 
% sampnum = m_sampnum('uway', datetimes)
% sampnum = m_sampnum('uway', datevecs)
% sampnum = m_sampnum('uway', datenums)
%   with first input argument 'uway', calculates sampnum for underway
%     samples according to the convention 
%   datetimes is a vector of datetimes 
%     (e.g. [2024-Jan-01 00:00:00; 2024-Jan-01 00:05:00])
%   datevecs is an Nx6 matrix of [yyyy mm dd HH MM SS]
%     (e.g. [2024 1 1 0 0 0; 2024 1 1 0 5 0])
%   datenums is a vector of Matlab datenums (e.g. [739252; 739252.0035]


if nargin==0
    m = {'CTD sampnum combines unique cast number (statnum) with Niskin rosette place/firing number (position):'
         '    sampnum = 100*statnum + position, where statnum is a whole number and position is usually from [1:24] or [1:36]'
         '    e.g. sampnum = 513 is cast number 5, Niskin 13; sampnum 14002 is cast number 140, Niskin 2'
         '         and if you use 999 for a test cast, its sampnums are 99901, 99902 etc.'
         '    test: 0 < sampnum < 1e5'
         '   '
         'underway sampnum gives (UTC) date-time using either yearday or year-month-day plus hours and minutes:'
         '    sampnum = -jjjHHMM or sampnum = yyyymmddHHMM'
         '    e.g. for a cruise starting in 2024, sampnum 202405311014 is equivalent to sampnum -1521014'
         '    test: sampnum < 0 | sampnum > 1e11'
         '   '
         '(sub)standard sampnums are any others, such as 6-digit integers starting with 9'
         '    e.g. salinity standards are assigned sampnums 999001, 999002, etc.; substandards are assigned 998001, etc.'
         '    test: 1e5 <= sampnum <= 1e11 '};
    fprintf(1,'%s\n',m{:})

elseif nargin==1
    sampnum = varargin{1};
    isctd = sampnum>0 & sampnum<1e5; %CTD samples 000NN to 999NN
    isuway = sampnum<0 | sampnum>1e11; %underway samples -JJJHHMM or yyyymmddHHMM
    isstrd = ~isuway & ~isctd; %(sub)standards usually 990MMM to 999MMM
    varargout = {isctd, isuway, isstrd};

elseif strcmp('ctd',varargin{1})
    varargout{1} = 100*varargin{2} + varargin{3};

elseif strcmp('uway',varargin{1})
    varargout{1} = str2num(datestr(varargin{1}, 'yyyymmddHHMM'));

end
