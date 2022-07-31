%for singlebeam

[d0,h] = mload(otfile,'/');
dopts.despike.depth_below_xducer = [10 5 3];
[d, ~] = apply_autoedits(d0, dopts);
mfsave(otfile,d,h);