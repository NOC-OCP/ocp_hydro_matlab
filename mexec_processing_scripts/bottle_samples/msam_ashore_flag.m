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
    samtype = samtypes{stno};

    do_empty_vars = 0;
    fillstat = 0;
    varmap = {};
    opt1 = mfilename; opt2 = ['sam_ashore_' samtype]; get_cropt
    if ~iscell(fnin); fnin = {fnin}; end

    %figure out some things about the file(s)
    clear varsta varsam varnis
    m = strcmp(varmap(:,1),'statnum');
    if sum(m)
        varsta = varmap{m,2};
        varnis = varmap{strcmp(varmap(:,1),'position'),2};
    else
        m = strcmp(varmap(:,1),'sampnum');
        varsam = varmap{m,2};
    end

    %load existing sam data, so we can apply Niskin flags and also check we're
    %not overwriting data that has been filled in
    root_sam = mgetdir('M_CTD');
    samfile = fullfile(root_sam, ['sam_' mcruise '_all']);
    [dso, hso] = mloadq(samfile,'/');

    %get default units
    if do_empty_vars
        evarsunts = m_exch_vars_list(2);
    end

    for fno = 1:length(fnin)

        st = readtable(fnin{fno});
        if fillstat
            st = fill_samdata_statnum(st, varsta);
        end
        if ~exist('varsam','var')
            st.sampnum = st.(varsta)*100 + st.(varnis);
            varsam = 'sampnum';
        end
        opt1 = mfilename; opt2 = 'shore_samlog_edit'; get_cropt %place to combine columns
        %assume we don't need to know about replicates as there will always be
        %a first sample***
        [~,ii] = unique(st.(varsam),'stable');
        st = st(ii,:);

        clear dsn hsn
        dsn.sampnum = st.(varsam);
        hsn.fldnam = {'sampnum'}; hsn.fldunt = {'number'};
        [~,fn,ext] = fileparts(fnin{fno});
        hsn.comment = sprintf('flags for samples collected and stored for shore analysis from %s',[fn '.' ext]);

        for vno = 1:size(varmap,1)

            isflag = contains(varmap{vno,1},'_flag');
            if isflag
                fvar = varmap{vno,1};
                parname = fvar(1:end-5);
                fvarin = varmap{vno,2};

                %convert to flags if necessary
                stf.(fvarin) = st.(fvarin);
                switch varmap{vno,3}
                    case 'num_samples'
                        m = st.(fvarin)>0 & isfinite(st.(fvarin));
                        stf.(fvarin)(m) = 1;
                        stf.(fvarin)(~m) = 9;
                        %                 case 'sample_bottle'
                        %                     %test for numbers or letters rather than empty***
                    case 'flag'
                        %no action, it already gives sample flags
                end

                %check if okay to merge
                if isfield(dso,fvar)
                    m = dso.(fvar)(io)>1 & dso.(fvar)(io)<9;
                    m = m & dso.(fvar)(io)~=stf.(fvarin)(in);
                    if do_empty_vars && isfield(dso,parname)
                        m = m | ~isnan(dso.(parname)(io));
                    end
                    if sum(m)>0
                        warning('overwriting data flags for %s',vars{vno})
                        cont = input('k for keyboard or enter to continue','s');
                        if strcmp(cont,'k')
                            keyboard
                        end
                    end
                end

                %add to dsn
                if do_empty_vars
                    dsn.(parname) = NaN+zeros(size(stf.(fvarin)));
                    hsn.fldnam = [hsn.fldnam parname];
                    %try filling in default units
                    m = strcmp(parname,evarsunts(:,3));
                    if sum(m)
                        defunits = lower(evarsunts{m,2});
                    else
                        defunits = 'undefined';
                    end
                    hsn.fldunt = [hsn.fldunt defunits];
                end
                dsn.(fvar) = stf.(fvarin);
                hsn.fldnam = [hsn.fldnam fvar];
                hsn.fldunt = [hsn.fldunt 'woce_table_4.8'];

            end

        end

        %combine types
        opt1 = mfilename; opt2 = 'samflags_combine'; get_cropt

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

    clear samtype

end

clear samtypes
