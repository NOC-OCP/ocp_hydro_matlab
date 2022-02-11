function didedits = ctd_apply_autoedits(filename, castopts)

m_common; MEXEC_A.mprog = mfilename;

[st,ii] = dbstack;
isinspec = 0;

didedits = 0;

%edit out scans when pumps are off, plus expected recovery times
if ~isempty(castopts.pvars)
    MEXEC_A.MARGS_IN = {filename; 'y'};
    for no = 1:size(castopts.pvars,1)
        pmstring = sprintf('y = x1; pmsk = repmat([1:length(x2)], %d+1, 1)+repmat([-%d:0]'', 1, length(x2)); pmsk(pmsk<1) = 1; pmsk = sum(1-x2(pmsk),1); y(find(pmsk)) = NaN;', pvars{no,2}, pvars{no,2});
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; pvars{no,1}; [pvars{no,1} ' pumps']; pmstring; ' '; ' '];
        disp(['will edit out pumps off times plus ' num2str(pvars{no,2}) ' scans from ' pvars{no}])
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalib2;
    didedits = 1;
end

%scanedit (for additional bad scans)
if ~isempty(castopts.sevars)
    MEXEC_A.MARGS_IN = {filename; 'y'};
    for no = 1:size(castopts.sevars,1)
        sestring = sprintf('y = x1; y(x2>=%d & x2<=%d) = NaN;', castopts.sevars{no,2}, castopts.sevars{no,3});
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; castopts.sevars{no,1}; [castopts.sevars{no,1} ' scan']; sestring; ' '; ' '];
        disp(['will edit out scans from ' castopts.sevars{no,1} ' with ' sestring])
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    mcalib2;
    didedits = 1;
end

%remove out of range values
if ~isempty(castopts.revars)
    if ~isinspec && ~castopts.redoctm && sum(strncmp('temp',castopts.revars(:,1),4))
        warning('you appear to be range editing temperature without having inspected the raw file')
        warning('are you sure you do not need to go back to mctd_01 with redoctm?')
    end
    MEXEC_A.MARGS_IN = {filename; 'y'};
    for no = 1:size(castopts.revars,1)
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; castopts.revars{no,1}; sprintf('%f %f',castopts.revars{no,2},castopts.revars{no,3}); 'y'];
        disp(['will edit values out of range [' sprintf('%f %f',castopts.revars{no,2},castopts.revars{no,3}) '] from ' castopts.revars{no,1}])
    end
    MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
    medita;
    didedits = 1;
end

%despike
if ~isempty(castopts.dsvars)
    if ~isinspec && ~castopts.redoctm && sum(strncmp('temp',castopts.dsvars(:,1),4))
        warning('you appear to be despiking temperature without having inspected the raw file')
        warning('are you sure you do not need to go back to mctd_01 with redoctm?')
    end
    nds = 2;
    while nds<=size(castopts.dsvars,2)
        MEXEC_A.MARGS_IN = {filename; 'y'};
        for no = 1:size(castopts.dsvars,1)
            MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; castopts.dsvars{no,1}; castopts.dsvars{no,1}; sprintf('y = m_median_despike(x1, %f);', castopts.dsvars{no,nds}); ' '; ' '];
            disp(['will despike ' castopts.dsvars{no,1} ' using threshold ' sprintf('%f', castopts.dsvars{no,nds})])
        end
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
        mcalib2
        nds = nds+1;
    end
    didedits = 1;
end
