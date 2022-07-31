% msam_ashore_flag
%
% set samtype (string) before calling
%
% add list(s) of samples drawn for shoreside analysis to sam_cruise_all.nc
% from one or more files
% use opt_cruise to specify which fields to look for in which file(s),
% based on samtype

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;

if ~exist('samtype', 'var')
    samtype = input('sample type? ','s');
end
scriptname = mfilename; oopt = ['sam_ashore_' samtype]; get_cropt
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
    %assume we don't need to know about replicates as there will always be
    %a first sample*** 
    [~,ii] = unique(st.(varsam),'stable');
    st = st(ii,:); 
    
    clear dsn hsn
    dsn.sampnum = st.(varsam);
    hsn.fldnam = {'sampnum'}; hsn.fldunt = {'number'};
    [~,fn,ext] = fileparts(fnin{fno});
    hsn.comment = sprintf('flags for samples collected and stored for shore analysis from %s',[fn '.' ext]);

    [~,io,in] = intersect(dso.sampnum,st.sampnum);
    niskin_flag = 9+zeros(size(dsn.sampnum));
    niskin_flag(in) = dso.niskin_flag(io);
    m4 = niskin_flag==4; m9 = niskin_flag==9;


    for vno = 1:size(varmap,1)
    
        isflag = contains(varmap{vno,1},'_flag');
        if isflag
            fvar = varmap{vno,1};
            parname = fvar(1:end-5);
            fvarin = varmap{vno,2};
            
            %convert to flags if necessary
            switch varmap{vno,3}
                case 'num_samples'
                    st.(fvarin)(st.(fvarin)>0 & isfinite(st.(fvarin))) = 1;
%                 case 'sample_bottle'
%                     %test for numbers or letters rather than empty
                case 'flag'
                    %no action, it already gives sample flags
            end

            %match with niskin flags
            st.(fvarin)(m4) = max(5,st.(fvarin)(m4));
            st.(fvarin)(m9) = 9;
        
            %check if okay to merge
            if isfield(dso,fvar)
                m = dso.(fvar)(io)>1 & dso.(fvar)(io)<9;
                m = m & dso.(fvar)(io)~=st.(fvarin)(in);
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
                dsn.(parname) = NaN+zeros(size(st.(fvarin)));
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
            dsn.(fvar) = st.(fvarin);
            hsn.fldnam = [hsn.fldnam fvar];
            hsn.fldunt = [hsn.fldunt 'woce_table_4.8'];

        end

    end

    %write to sam file
    MEXEC_A.Mprog = mfilename;
    mfsave(samfile, dsn, hsn, '-merge', 'sampnum')

end

clear samtype
