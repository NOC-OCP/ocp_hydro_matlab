% msec_add_station_depths
%
% bak jc191
% add station depths from summary nc file to the lower plot in a section
% plot
% only add depths for stations that are used in the grid file being plotted
% convert depth to pressure

root_sum = mgetdir('M_SUM');

fn_statsum = [root_sum '/station_summary_' mcruise '_all.nc'];
fn_grid = c.ncfile.name;

if exist(fn_statsum,'file') == 2
    
    dsum = mload(fn_statsum,'/');
    dg = mload(fn_grid,'statnum');
    
    statuse = dg.statnum(1,:);
    
    x = [];
    y = [];
    
    
    for kstat = statuse;
        ki = find(dsum.statnum == kstat);
        
        x = [x dsum.lon(ki)];
        y = [y sw_pres(dsum.cordep(ki),dsum.lat(ki))];
    end
    
    xscl = (x-c.xax(1))/(c.xax(2)-c.xax(1));
    yscl = (y-c.yax(1))/(c.yax(2)-c.yax(1));
    
    axes(c.mainplot_gca_handle);
    
    plot(xscl,yscl,'k-','linewidth',station_depth_width);
    
else
    fprintf(2,'%s %s \n','Station summary file with depths not found ',fn_statsum);
end

