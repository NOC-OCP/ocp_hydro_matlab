function oxygen_sbe = calculate_oxy_from_V(sbeoxyV, time, press, temp, psal, coefs)
% oxygen_sbe = mcoxy_from_V(sbeoxyV, time, press, temp, psal, coefs)
%
% reproduces SBE conversion from volts to umol/kg using the Sea-Bird
%   equation (Application Note 64/Jul2012), with Garcia & Gordon oxygen
%   solubility (and SW potential density)
%
% useful if you have one bad CTD but two good oxygens
%
% output: oxygen_sbe (umol/kg)
%
% inputs should be from raw_noctm file (before align or cellTM
%   corrections***)
% coefs is a structure containing coefficients for the SB equation (Soc,
%   Voff, A, B, C, D0, D1, D2, E, Tau20) (found in XMLCON file)
%   

%oxygen solubility
Ts = log((298.15-temp)./(273.15+temp));
A0 = 2.00907;
A1 = 3.22014;
A2 = 4.0501;
A3 = 4.94457;
A4 = -0.256847;
A5 = 3.88767;
B0 = -0.00624523;
B1 = -0.00737614;
B2 = -0.010341;
B3 = -0.00817083;
C0 = -0.000000488682;
oxsol = exp(A0 + A1*Ts + A2*Ts.^2 + A3.*Ts.^3 + A4*Ts.^4 + A5*Ts.^5 + psal.*(B0 + B1*Ts + B2*Ts.^2 + B3*Ts.^3) + C0*psal.^2);

%***check that tau correction was enabled?

tau = coefs.Tau20*exp(coefs.D1*press + coefs.D2*(temp-20));
dVdt = diff(sbeoxyV)./diff(time);
dVdt = [dVdt(1); .5*(dVdt(1:end-1)+dVdt(2:end)); dVdt(end)]; %***
oxygen_ml_per_l = coefs.Soc*(sbeoxyV + coefs.Voff + tau.*dVdt).*oxsol.*(1 + coefs.A*temp + coefs.B*temp.^2 + coefs.C*temp.^3).*exp(coefs.E*press./(temp+273.15));

pden = sw_pden(psal, temp, press, 0); %sigma_theta + 1000
oxygen_sbe = 44660./pden.*oxygen_ml_per_l;
