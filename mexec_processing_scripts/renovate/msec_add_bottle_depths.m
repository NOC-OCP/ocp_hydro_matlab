% msec_add_bottle_depths
%
% bak jc191
% add bottle depths from sam_all or sma_all_nutkgnc file to upper and lower plots
%
% only add stations used in grid

root_ctd = mgetdir('M_CTD');

fn_samall = [root_ctd '/sam_' mcruise '_all.nc'];
fn_samall_kg = [root_ctd '/sam_' mcruise '_all_nutkg.nc'];
fn_grid = c.ncfile.name;

if exist(fn_samall_kg,'file') == 2
    fn_samall = fn_samall_kg; % use nutkg file if it exists
end

if exist(fn_samall,'file') == 2
    
    dsam = mload(fn_samall,'/');
    dg = mload(fn_grid,'statnum');
    
    statuse = dg.statnum(1,:);
    plotvar = c.zlist;
    try
        samdata = getfield(dsam,plotvar);
    catch
            fprintf(2,'%s %s %s\n',plotvar,' not found in sam file',fn_samall)
            return
    end
    
    x = [];
    y = [];
    
    
    for kstat = statuse;
        
        
        ki = find(dsam.statnum == kstat & isfinite(samdata));
        
        x = [x ; dsam.lon(ki)];
        y = [y ; dsam.upress(ki)];
    end
    
    xscl = (x-c.xax(1))/(c.xax(2)-c.xax(1));
    yscl = (y-c.yax(1))/(c.yax(2)-c.yax(1));
    
    axes(c.mainplot_gca_handle);
    
    plot(xscl,yscl,'k.','markersize',bottle_depth_size);
    
else
    fprintf(2,'%s \n','sam file with bottle data not found')
    
end
