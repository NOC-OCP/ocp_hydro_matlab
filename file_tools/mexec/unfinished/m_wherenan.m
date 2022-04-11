function var3=m_wherenan(var1,var2)
% function var3=m_wherenan(var1,var2)
%
% makes var2=nan whenever var1=nan.

var3=var2;

var3(find(isnan(var1)))=nan;

