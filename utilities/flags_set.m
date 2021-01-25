function flag = flags_set(flag, sampnum, flagval, flagsampnums);
% flag = flags_set(flag, sampnum, flagval, flagsampnums);
%
% change flags corresponding to sampnums listed in flagsampnums to 
% flagval
%
% flags and sampnum must be the same size
% flagval is a vector of doubles, the values elements of flag should be set to
% flagsampnums is a cell array the same length as flagval, with each
%      element a vector listing the sampnums to set to the corresponding
%      flagval
%      unless flagval is a scalar, in which case flagsampnums may
%      alternately be a vector

if size(flag,1)~=size(sampnum,1) | size(flag,2)~=size(sampnum,2)
    error('flag and sampnum must be the same size')
end

if ~iscell(flagsampnums)
    if length(flagval)==1
        flagsampnums = {flagsampnums};
    else
        error('more than one flagval so flagsampnums must be a cell array')
    end
end

for vno = 1:length(flagval)
   flag(ismember(sampnum, flagsampnums{vno})) = flagval(vno);
end
