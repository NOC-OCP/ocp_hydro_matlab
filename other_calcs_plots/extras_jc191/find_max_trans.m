% bak jc191 find max trans for each station
%

tr_max = nan(999,1);
stn_high = 0;

for kl = 1:150
    stnstr = sprintf('%03d',kl);
    fnin = ['ctd_jc191_' stnstr '_raw.nc']; % find in raw, so we can see raw even after trans cal has been applied
    if exist(fnin,'file') ~= 2; continue; end
    d = mload(fnin,'press transmittance');
    
    ksub = find(d.press > 20); % submerged
    tr_max(kl) = max(d.transmittance(ksub));
    
    stn_high = max(stn_high,kl);
    
end

tr_max(stn_high+1:end) = [];