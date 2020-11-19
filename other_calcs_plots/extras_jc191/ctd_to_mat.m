for kl = [3:24 26:135];
    str = sprintf('%03d',kl);
    fn = ['ctd_jc191_' str '_2db.nc'];
    [d h] = mload(fn,'/');
    cmd = ['d' str ' = d;']; eval(cmd);
    cmd = ['h' str ' = h;']; eval(cmd);
    cmd = ['save ctd_2db_all.mat d' str ' h' str ' -append']; eval(cmd)
end
    