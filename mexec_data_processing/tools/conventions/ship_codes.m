function varargout = ship_codes(varargin)

if nargin==0
    m_common
    cc = MEXEC_G.mcruise(1:2);
else
    cc = varargin{1}(1:2);
end

switch cc
    case {'di' 'dy'}
        PLATFORM_IDENTIFIER = 'RRS Discovery';
    case 'jc'
        PLATFORM_IDENTIFIER = 'RRS James Cook';
    case 'sd'
        PLATFORM_IDENTIFIER = 'RRS Sir David Attenborough';
    case 'jr'
        PLATFORM_IDENTIFIER = 'RRS James Clark Ross';
    case 'kn'
        PLATFORM_IDENTIFIER = 'RV Knorr';
    case 'en'
        PLATFORM_IDENTIFIER = 'RV Endeavor';
    case 'ce'
        PLATFORM_IDENTIFIER = 'RV Celtic Explorer';
    case 'md'
        PLATFORM_IDENTIFIER = 'RV Marion Dufresne';
    otherwise
        PLATFORM_IDENTIFIER = input('ship ID not recognised in cruise; enter platform identifier (ship long name), e.g. ''RRS James Cook'' ','s');
        warning('add case to m_setup'); pause(0.1)
end

if nargin==0
    MEXEC_G.PLATFORM_IDENTIFIER = PLATFORM_IDENTIFIER;
end
if nargout>0
    varargout{1} = PLATFORM_IDENTIFIER;
end