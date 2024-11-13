function v = m_getinput(msg,type,opt)
% function v = m_getinput(msg,type,opt)
%
% Call with type = 's' for string or 'd' for double
% If you respond c/r the defaults are ' ' and NaN

% optional third argument opt can take value 'no_ot' to avoid adding to
% MEXEC_A.MARGS_OT


m_common

argsin = MEXEC_A.MARGS_IN_LOCAL;
% bak on jr281 April 2013 this was called by mday_01 and MARGS_OT was unset
% causing an error exit. Next 3 lines added.
if ~isfield(MEXEC_A,'MARGS_OT')
    MEXEC_A.MARGS_OT = {};
end
argsot = MEXEC_A.MARGS_OT;
    

% If MEXEC_A.MARGS_IN_LOCAL is absent or empty, get input from keyboard
% If MEXEC_A.MARGS_IN_LOCAL has elements, take the input from the first element of the cell array

if isempty(argsin) % MEXEC_A.MARGS_IN_LOCAL is empty, prompt at keyboard
    if strcmp(type,'s')
        v = input(msg,'s');
        if isempty(v); v = ' '; end
    else
        v = input(msg);
        if isempty(v); v = nan; end
    end
else  % MEXEC_A.MARGS_IN_LOCAL has elements, take the input from the first element of the cell array
    v = argsin{1};
    % keyboard input is always converted to character
    % do the same for MEXEC_A.MARGS_IN or varargin input
    if ischar(v); end
    if isnumeric(v); v = num2str(v); end
    if isstruct(v); end
    argsin(1) = [];
    if ~MEXEC_G.quiet
    disp(msg);
    disp(v);
    end
end


MEXEC_A.MARGS_IN_LOCAL = argsin;
if exist('opt','var') ~= 1
    argsot = [argsot v];
    MEXEC_A.MARGS_OT = argsot;
elseif ~strcmp(opt,'no_ot')
    argsot = [argsot v];
    MEXEC_A.MARGS_OT = argsot;
end
