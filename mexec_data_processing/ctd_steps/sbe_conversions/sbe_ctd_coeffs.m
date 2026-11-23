%SBE default oxygen hysteresis coefficients
co.hyst_oxy0.H1 = -0.033; %suggested range: [-0.02 -0.05]
co.hyst_oxy0.H2 = 5000;
co.hyst_oxy0.H3 = 1450; %suggested range: [1200 2000]

%if pumps go off, default delays to recover, based on plumbing and sensor response
co.pumpsNaN.temp1 = 12; %based on jc159, T takes 1/2 s to recover
co.pumpsNaN.temp2 = 12;
co.pumpsNaN.cond1 = 12;
co.pumpsNaN.cond2 = 12;
co.pumpsNaN.oxy1 = 8*24; %based on jc159, O takes 8 s to recover
co.pumpsNaN.oxy2 = 8*24;
