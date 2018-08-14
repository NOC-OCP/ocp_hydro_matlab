% quick and simple script to add list of samples drawn by Chibo Chiwililwa
% on jc159 for shoreside analysis; Set botchla_flag to 1 when a sample was
% drawn.

fnin = 'Sample_log_Phyto_Chibo_sampnum.csv';

root_in = mgetdir('M_BOT_CHL');
root_sam = mgetdir('M_CTD');




d = load([root_in '/' fnin]);

sampnums = unique(d(:,3));

stations = unique(floor(sampnums/100));

for kstn = stations(:)'
    
    stn_string = sprintf('%03d',kstn);
    
    otfile = [root_sam '/sam_' mcruise '_' stn_string];
    
    [dsam hsam] = mload(otfile,'/');
    
    samsamp = dsam.sampnum;
    [kmatsamp kmat k2] = intersect(samsamp,sampnums);
    
    
    cmd1 = ['y = x; y(['];
    cmd3 = [']) = 1;'];
    
    cmd2 = sprintf('%d ',kmat);
    
    cmd = [cmd1 cmd2 cmd3];
    
    
    %--------------------------------
    % 2018-04-06 11:34:48
    % mcalib
    % calling history, most recent first
    %    mcalib in file: mcalib.m line: 91
    % input files
    % Filename sam_jc159_998.nc   Data Name :  sam_jc159_003 <version> 197 <site> jc159
    % output files
    % Filename sam_jc159_998.nc   Data Name :  sam_jc159_003 <version> 198 <site> jc159
    MEXEC_A.MARGS_IN = {
        otfile
        'y'
        'botchla_flag'
        cmd
        ' '
        ' '
        ' '
        };
    mcalib
    %--------------------------------
    
    stn = kstn; msam_updateall;
    
end



