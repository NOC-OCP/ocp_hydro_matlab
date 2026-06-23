function ndepths = mctd_count_depths(dsam,searchlim)

% use: ndepths = mctd_count_depths(dsam,searchlim)

% bak on jc191 : both of wireout and upress may vary during a bottle stop
% because of winch heave compensator

% count depths with some fuzziness

% pass in structure dsam which is a load of the station sample file

% suggest searchlim should be value = 1; 
% if heave compensator is off, wireout will be consistent within 1.
% if heave compesator is on, probably upress will be consistent within 1.
% this parameter could be tweaked.

wireout = dsam.wireout;
upress = dsam.upress;

kn = isnan(wireout) & isnan(upress);
wireout(kn) = [];
upress(kn) = [];

wokeep = [];
upkeep = [];

while ~isempty(wireout)
    wo = wireout(1);
    up = upress(1);
    kdup = (abs(wireout-wo) <= searchlim | abs(upress-up) <= searchlim); % cycles that match current test value if wireout or upress
    wireout(kdup) = [];
    upress(kdup) = [];
    wokeep = [wokeep; wo];
    upkeep = [upkeep; up];
end

ndepths = length(wokeep);
