%script to add 24 Hz indices to dcs_cruise_stn file, 
%rerun mfir_03 and mfir_04 (so they can average if specified in opt_cruise)
%and modify variables in sam_* files
%
%the first two steps are to convert to processing using averages from 24 Hz
%to 2 dbar and averages over 5 s for bottle comparison
%
%the third is to replace the old smallscript_sams, which just started from
%scratch

scriptname = 'smallscript';
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;
oopt = '';
    
if ~exist('klist'); oopt = 'klist'; get_cropt; end


wkfile = 'wk_dcs_sams_script.nc';
root_ctd = mgetdir('M_CTD');
scriptname = mfilename; get_cropt
if ~dodcs24 & ~doucav & length(rmvars)==0 & length(addvars)==0
    error(['smallscript_sams not doing anything, check opt_' mcruise])
else
    if length(rmvars)>0
        warning('removing variables from sam files; update template for future')
    end
    if length(addvars)>0
        warning('adding variables to sam files; update template for future')
    end
    disp('Will process stations in klist: ')
    disp(klist)
    okc = input('OK to continue (y/n)?','s');
    if okc == 'n' | okc == 'N'
	    return
    end
end

%dcs
if dodcs24
    for kloop = klist
    
        infile = sprintf('%s/dcs_%s_%03d.nc',root_ctd,mcruise,kloop);
        h = m_read_header(infile);
        if sum(strcmp('dc24_bot',h.fldnam))==0
            MEXEC_A.MARGS_IN = {infile; wkfile; '/'; ... 
                'dc_bot'; 'y = x1*24;'; 'dc24_bot'; 'number'; ...
                'dc_start'; 'y = x1*24;'; 'dc24_start'; 'number'; ...
                'dc_end'; 'y = x1*24;'; 'dc24_end'; 'number';...
                ' '};
            mcalc
            unix(['/bin/mv ' wkfile ' ' infile]);
        end
        
    end
end

%fir
if doucav
    
    for kloop = klist

        stn = kloop; mfir_03

        stn = kloop; mfir_04
    
    end
end

%sam
if length(addvars)>0 | length(rmvars)>0 | length(chunts)>0
    
    for kloop = klist
        
        infile = sprintf('%s/sam_%s_%03d.nc',root_ctd,mcruise,kloop);
        if kloop == klist(1)
            h = m_read_header(infile);
            var_copystr = ' ';
            for kloop_scr = 1:length(h.fldnam)
                if sum(strcmp(h.fldnam{kloop_scr},rmvars))==0
                    var_copystr = [var_copystr h.fldnam{kloop_scr} ' '];
                end
            end
            var_copystr([1 end]) = [];
        end
        MEXEC_A.MARGS_IN = {infile; wkfile; var_copystr};
        for no = 1:length(addvars)
            if sum(strcmp(h.fldnam, addvars{no}))==0
               MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; 'upress'; 'y = NaN+x1;'; addvars{no}; addunts{no}];
            end
        end
        MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN; ' '];
        mcalc
        unix(['/bin/mv ' wkfile ' ' infile]);
        if length(chunts)>0
            h = m_read_header(infile);
            for no = 1:size(chunts,1)
                ii = find(strcmp(h.fldnam,chunts{no,1}));
                if length(ii)>0
                    h.fldunt{ii} = chunts{no,2};
                else
                    warning([chunts{no,1} ' not in ' infile ' to change units'])
                end
            end
            ncfile = struct('name', infile);
            ncfile = m_openot(ncfile);
            m_write_header(ncfile, h);
        end
        
        stn = kloop; msam_02b

    end

end

%sam_all
unix(sprintf('/bin/cp %s/sam_%s_%03d.nc %s/sam_%s_all.nc',root_ctd,mcruise,klist(1),root_ctd_mcruise));
for kloop = klist(2:end)
    stn = kloop; msam_apend
end    
