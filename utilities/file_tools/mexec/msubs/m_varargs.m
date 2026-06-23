% m_varargs
%
% mexec script
% add varargin in front of other MEXEC_A.MARGS_IN_LOCAL
%
% FIELDS SET:
%    MEXEC_A.MARGS_IN_LOCAL
%

if exist('varargin','var') == 1
    MEXEC_A.MARGS_IN_LOCAL = [varargin(:)' MEXEC_A.MARGS_IN_LOCAL(:)'];
end

