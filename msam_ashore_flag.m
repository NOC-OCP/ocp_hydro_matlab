% quick and simple script to add list of samples drawn on jc159 for 
% shoreside analysis
%
% formerly mchibo_01
%
% some input parsing moved to opt_cruise file to facilitate setting
% multiple different sample flags

stn = 0; minit; scriptname = mfilename;

if ~exist('samtype', 'var')
   samtype = input('sample type? ');
end
get_cropt
    
root_sam = mgetdir('M_CTD');

stns = unique(stations);
for kstn = stns(:)'
    
    stn_string = sprintf('%03d',kstn);
    otfile = [root_sam '/sam_' mcruise '_' stn_string];
    
    iistn = find(stations==kstn);
    
    %--------------------------------
    MEXEC_A.MARGS_IN = {otfile; 'y'};
    for nno = 1:length(flagnames)
        for fno = 1:length(flagvals)
           snum = sampnums{nno,fno}; snum = snum(:);
           iifl = find(floor(snum/100)==kstn);
           if ~isempty(iifl)
              MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN;
              flagnames{nno}
              sprintf('sampnum %s bottle_qc_flag', flagnames{nno})
              sprintf('y = x2; y(x3~=9 & ismember(x1, [%s])) = %d;', num2str(snum(iifl)'), flagvals(fno));
              ' '
              ' '
              ];
           end
        end
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalib2
    %--------------------------------
    
    stn = kstn; msam_updateall;
    
end

clear samtype

