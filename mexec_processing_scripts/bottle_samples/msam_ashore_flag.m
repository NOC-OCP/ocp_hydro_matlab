function msam_ashore_flag(samtypes)
% msam_ashore_flag
%
% set samtype (string or cell) before calling
%
% add list(s) of samples drawn for shoreside analysis to sam_cruise_all.nc
% from one or more files
% use opt_cruise to specify which fields to look for in which file(s),
% based on samtype
 
m_common
mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

for stno = 1:length(samtypes)
    samtype = samtypes{stno}; %this is just used by opt_cruise (if you have different files for different types)

    do_empty_vars = 0;
    fillstat = 0;
    varmap.statnum = {'ctd_number'};
    varmap.position = {'niskin'};
    opt1 = 'outputs'; opt2 = 'sam_shore'; get_cropt

    %load existing sam data, so we can apply Niskin flags and also check we're
    %not overwriting data that has been filled in
    root_sam = mgetdir('M_CTD');
    samfile = fullfile(root_sam, ['sam_' mcruise '_all']);
    [dso, hso] = mloadq(samfile,'/');

    %get default units
    if do_empty_vars
        evarsunts = m_exch_vars_list(2);
    end

    if ~iscell(fnin); fnin = {fnin}; end
    for fno = 1:length(fnin)

        st = readtable(fnin{fno});
        [st, ~] = var_renamer(st, varmap);
        fn = st.Properties.VariableNames;
        if ~sum(strcmp('sampnum',fn))
            st.sampnum = st.statnum*100+st.position;
        end
        if fillstat
            st = fill_samdata_statnum(st, varsta);
        end
        opt1 = mfilename; opt2 = 'shore_samlog_edit'; get_cropt %place to combine columns
        %assume we don't need to know about replicates as there will always be
        %a first sample***
        [~,ii] = unique(st.sampnum,'stable');
        st = st(ii,:);

        clear dsn hsn
        dsn.sampnum = st.sampnum;
        hsn.fldnam = {'sampnum'}; hsn.fldunt = {'number'};
        [~,fn,ext] = fileparts(fnin{fno});
        hsn.comment = sprintf('flags for samples collected and stored for shore analysis from %s',[fn '.' ext]);

        vars = setdiff(fieldnames(varmap),{'sampnum';'statnum';'position'});
        for vno = 1:size(varmap,1)

            %the point of these files is samples are not analysed yet, so
            %values should either be 0 or 1, or 0:N number of samples, or
            %maybe 1 or 9 
            %***could add code for 'y' or other initials? add a
            %shoresam_parse case maybe

            if contains(vars{vno},'_flag') 
                %if called _flag there's a possiblity it is a woce flag,
                %and in any case 9 replicates is unlikely!
                flname = vars{vno};
                parname = flname(1:end-5);
                dsn.(flname) = 9+zeros(size(dsn.sampnum));
                dsn.(flname)(st.(flname)>0 & st.(flname)<9) = 1;
            else
                %assume it is 0 for no samples, some >0 integer for some
                %samples collected (not tracking replicates here/at this
                %stage)
                parname = vars{vno};
                flname = [vars{vno} '_flag'];
                dsn.(flname) = 9+zeros(size(dsn.sampnum));
                dsn.(flname)(st.(parname)>0) = 1; 
            end
            hsn.fldnam = [hsn.fldnam flname];
            hsn.fldunt = [hsn.fldunt 'woce_4.9'];
            if do_empty_vars
                %also create NaNs for the variable itself
                dsn.(parname) = NaN+zeros(size(dsn.sampnum));
                hsn.fldnam = [hsn.fldnam parname];
                %try filling in default units
                m = strcmp(parname,evarsunts(:,3));
                if sum(m)
                    defunits = lower(evarsunts{mq,2});
                else
                    defunits = 'undefined';
                end
                hsn.fldunt = [hsn.fldunt defunits];
            end

            if isfield(dso,flname)
                %prepare to merge
                [~,iin,iio] = intersect(dsn.sampnum, dso.sampnum);
                %exclude no change
                ms = dso.(flname)(iio)==dsn.(flname)(iin);
                iin(ms) = []; iio(ms) = [];
                %check if we are overwriting data that has already been added
                mq = dso.(flname)(iio)>1 & dso.(flname)(iio)<9;
                if isfield(dso,parname)
                    mq = mq | ~isnan(dso.(parname)(iio));
                end
                if sum(mq)>0
                    warning('overwriting data flags for %s',vars{vno})
                    cont = input('k for keyboard or enter to continue','s');
                    if strcmp(cont,'k')
                        keyboard
                    end
                end
            end

        end

        %apply niskin flags, and discard empty rows (sampnums with no samples
        %collected)
        dsn.niskin_flag = 9+zeros(size(dsn.sampnum));
        [~,ia,ib] = intersect(dso.sampnum,dsn.sampnum);
        dsn.niskin_flag(ib) = dso.niskin_flag(ia);
        dsn = hdata_flagnan(dsn, 'keepempty', 1, 'keepemptyrows', 0);
        dsn = rmfield(dsn, 'niskin_flag');

        %write to sam file
        MEXEC_A.Mprog = mfilename;
        mfsave(samfile, dsn, hsn, '-merge', 'sampnum')

    end

end
