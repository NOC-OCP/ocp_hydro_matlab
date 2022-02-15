function pup = heave(dn_psal,dn_temp,up_psal,up_temp,pdn)    
% Find pup - the pressures on the up profile that have the same properties as at pdn on the down profile
% Have tried a couple of different ways to do this, best uses neutral density
%
% DAS 2021

iok = ~isnan(dn_psal) & ~isnan(dn_temp) & ~isnan(up_psal) & ~isnan(up_temp);
dzn = NaN*pdn;
[dzn(iok)] = heaveND(dn_psal(iok),dn_temp(iok),up_psal(iok),up_temp(iok),pdn(iok));
if sum(~iok) > 0
    disp('Heave using interp for absent')
    dzn(~iok) = interp1(pdn(iok),dzn(iok),pdn(~iok));
end

pup = pdn + dzn;
