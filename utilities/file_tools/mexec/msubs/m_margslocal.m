% m_margslocal
%
% mexec script
% make local copy of MEXEC_A.MARGS_IN and clean up MEXEC_A.MARGS_IN
% so that MEXEC_A.MARGS_IN is left empty if the program crashes
%
% FIELDS SET:
%    MEXEC_A.MARGS_IN_LOCAL
%


if isfield(MEXEC_A,'MARGS_IN')
    MEXEC_A.MARGS_IN_LOCAL = MEXEC_A.MARGS_IN;
else
    MEXEC_A.MARGS_IN_LOCAL = {};
end
MEXEC_A.MARGS_IN = {};