m_figure
cols = 'kbrmc';
cols = cols(:);


for kstn = [70:90]

    stnstr = sprintf('%03d',kstn);

    fnc = ['ctd_di346_' stnstr '_psal'];
    fnw = ['WINCH/win_di346_' stnstr ];

    %    c = mload(fnc,'/');
    w = mload(fnw,'/');

    kwmax = find(w.cablout >= 4000);

    linestr = [cols(1),'-'];   cols = circshift(cols,1);

    linestr = 'r-';
    if kstn > 80
        linestr = 'k-';
    end

    plot((w.time-w.time(kwmax(end)))/60,w.cablout,linestr); hold on; grid on;

    %    stoptime = find


end


for kstn = [81 ]

    stnstr = sprintf('%03d',kstn);

    fnc = ['ctd_di346_' stnstr '_psal'];
    fnw = ['WINCH/win_di346_' stnstr ];

    %    c = mload(fnc,'/');
    w = mload(fnw,'/');

    kwmax = find(w.cablout >= 4000);
    linestr = [cols(1),'-'];   cols = circshift(cols,1);


    plot((w.time-w.time(kwmax(end)))/60,w.cablout,'m-','linewidth',2); hold on; grid on;

    %    stoptime = find


end
