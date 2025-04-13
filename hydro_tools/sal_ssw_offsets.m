function ssw_batches = sal_ssw_offsets(varargin)

if nargin>0
    filename = varargin{1};
elseif exist('iapso_ssw.txt','file')
    filename = which('iapso_ssw.txt');
    disp(['loading ' filename])
else
    error('iapso_ssw.txt file not found')
end

%read batch-batch offsets table from file (Table 1)
fid = fopen(filename,'r');
parsenext = 0;
rno = 1;
data = {};
while 1
    str = fgetl(fid);
    if ~ischar(str); break; end %just in case, break on EOF: -1
    if contains(str,'---------')
        if ~parsenext %first time, top of data in table
            parsenext = 1; continue
        else %next time, end of data in table
            break
        end
    end
    if parsenext
        data(rno,:) = strsplit(str);
        rno = rno+1;
    end
end
fclose(fid);

ssw_batches = table();
ssw_batches.batch = data(:,2);
ssw_batches.batch_num = cellfun(@(x) str2double(x(2:4)),data(:,2));
ssw_batches.date = data(:,3);
ssw_batches.k15 = cell2mat(data(:,4));
a = cellfun(@(x) str2double(x), data(:,5:7));
ssw_batches.pss_78 = a(:,1);
ssw_batches.offset = a(:,2)*1e-3;
ssw_batches.correction_factor = a(:,3);


%ylf jc159
%
%salinometer values of osil standard sea water batches
%first column: batch number (151 = p151)
%second column: 2xK15
%third column: batch offset (to be added to salinities calibrated with that
%   batch), from Kawano et al. (2006) and H. Uchida (pers comm)
%   note: values of 0 may mean those table rows have tno been updated here
% %   yet
% 
% ssw_batches = [
%               151 1.99994 -0.4e-3
%               153 1.99958  0.4e-3 
%               154 1.99980  0.6e-3
%               155 1.99962  0.1e-3
%               156 1.99968  0.4e-3
%               158 1.99940 -0.2e-3
%               159 1.99966 -0.4e-3
%               160 
%               161 1.99974  0.0e-3
%               163 1.99970  0
%               165 1.99972  0
% 	      ];

