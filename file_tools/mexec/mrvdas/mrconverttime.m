function dnum = mrconverttime(ts)
% function dnum = mrconverttime(ts)
%
% *************************************************************************
% mexec interface for RVDAS data acquisition
% First drafts of scripts for start jc211 28 jan 2021, alongside in Stanley
% 
% Evolution on that cruise by bak, ylf, pa
% *************************************************************************
%
% Convert an array of rvdas time strings to matlab datenum, allowing for 
%   variable string length due to asbent trailing zeros
%
% Input:
%
% ts is a cell array of time strings from rvdas, or a single char array; 
%   There may be some trailing zeros missing in each string. 
%   Possible input strings are of form
% 
%  '2021-01-28 17:48:13+00'      % length 22
%  '2021-01-28 17:48:13.8+00'    % length 24
%  '2021-01-28 17:48:13.88+00'   % length 25
%  '2021-01-28 17:48:12.883+00'  % length 26, complete string
%
% Output:
%
% dnum:  double array of matlab datenum

c = class(ts);
switch c
    case 'char'
        % if there is only one element it may be a char string not a cell
        % array. Make it a cell array with one element.
        ts = {ts};
        % This usally makes a Nx26 char array, padded with spaces. Unless
        % the maximum length of ts was less than 26, which is dealt with
        % later.
    case 'cell'
    otherwise
    fprintf(MEXEC_A.Mfider,'\n%s %s\n\n','Input to mrconverttime should be of class',c);
    error('input to mrconverttime doesn''t seem to be either cell or char')
end

nt = length(ts);

% padding strings
e7 = '.000+00';
e5 = '00+00';
e4 = '0+00';

% new code for correcting time, replaces commented out code below. Keep the
% old code for the time being in case this becomes very slow whnen the
% arrays are very large and we want to try something else.

cc = char(ts);

% If ts is a single time, and is length < 26, eg when called from mrdfinfo, then 
% cc won't have size 26. So pad it out.
ccsize = size(cc);
padsize = [ccsize(1) 26-ccsize(2)];
if padsize(2) > 0
    pad = char(zeros(padsize)+double(' ')); %char array of spaces
    cc = [cc pad]; % Now cc is Nx26, if it wasn't before
end


kspace = strfind(cc(:,23)',' '); % find where column 22 is a space, and fix it
for kl = kspace(:)'; cc(kl,20:26) = e7 ; end
kspace = strfind(cc(:,25)',' ');
for kl = kspace(:)'; cc(kl,22:26) = e5 ; end
kspace = strfind(cc(:,26)',' ');
for kl = kspace(:)'; cc(kl,23:26) = e4 ; end

% % padding strings
% e4 = '.000+00';
% e2 = '00+00';
% e1 = '0+00';
% 
% for kl = 1:nt
%     t = ts{kl};
% 
%     lt = length(t);
%     % if lt == 26; continue; end
%     % if lt == 25; continue;end
%     % if lt == 24; continue;end
%     % if lt == 22; continue;end
%     switch lt
%         case 26
%             % do nothing
%         case 25
%             ts{kl} = [t(1:22) e1];
%         case 24
%             ts{kl} = [t(1:21) e2];
%         case 22
%             ts{kl} = [t(1:19) e4];
%         otherwise
%             fprintf(MEXEC_A.Mfider,'\n%s%s%s\n\n','Input to mrconverttime had unexpected length ''',ts{kl},'''')
%             error('input to mrconverttime had unexpected length')
%     end
% end
% 
% 
% cc = char(ts); % convert from cell array to single long string
st1 = cc'; st1 = st1(:)';  % make a single long char array and read out of it.
dall = sscanf(st1,'%4d-%2d-%2d %2d:%2d:%6f+%*2d'); % * means skip %2d
dall = reshape(dall,[6 nt]); % Reshape to datevecs
dall = dall';
dnum = datenum(dall);
