m_common; MEXEC_A.mprog = mfilename;
opt1 = 'castpars'; opt2 = 'minit'; get_cropt
if MEXEC_G.quiet<=1; fprintf(1,'adding selected variables from extra .cnv to ctd_%s_%s_raw.nc\n',mcruise,stn_string); end

root_ctd = mgetdir('M_CTD');
dataname = ['ctd_' mcruise '_' stn_string];
opt1 = 'mctd_01'; opt2 = 'redoctm'; get_cropt
if ~redoctm %default: operate on file which had the cell thermal mass correction applied in SBE Processing
    otfile = fullfile(root_ctd, [dataname '_raw.nc']);
else %in some cases, operate on original file (to remove large spikes), then apply align and CTM
    otfile = fullfile(root_ctd, [dataname '_raw_noctm.nc']);
    disp('starting from noctm file')
end

opt1 = 'mctd_01'; opt2 = 'extracnv'; get_cropt
[d0, h0] = mloadq(otfile,'/');
ow = intersect(h0.fldnam,extravars);
if ~isempty(ow) && MEXEC_G.quiet<=1
    warning('overwriting variables %s,',ow{:});
end
for fno = 1:length(extracnv)
    if exist(extracnv{fno},'file')
        [dn, hn] = msbe_to_mstar(extracnv{fno},'y','y');
        clear d h
        d.scan = d0.scan;
        h.fldnam = {'scan'}; h.fldunt = {'number'};
        %don't use mfsave merge because it might keep some old data;
        %instead, merge here
        [~,i0,in] = intersect(d0.scan, dn.scan, 'stable');
        for vno = 1:length(extravars)
            d.(extravars{vno}) = NaN+d.scan;
            d.(extravars{vno})(i0) = dn.(extravars{vno})(in);
        end
        extravars = [extravars 'scan'];
        [h.fldnam,ia,ib] = intersect(extravars,hn.fldnam,'stable');
        h.fldunt = hn.fldunt(ib);
        h.comment = sprintf('with parameters added from sbe file %s',extracnv{fno});
        system(['chmod 644 ' m_add_nc(otfile)]);
        mfsave(otfile, d, h, '-addvars');
    end
end

system(['chmod 444 ' m_add_nc(otfile)]);


% %propagate but only as far as 24hz***commented out because really should
% %rerun normal steps in case of autoedits affecting all params
% 
% extravars = setdiff(extravars,{'scan'});
% %add
% [varlist, var_copystr, iiv] = mvars_in_file(extravars, otfile);
% [dr,hr] = mloadq(otfile,var_copystr);
% fname = sprintf('ctd/ctd_jc238_%03d_raw_cleaned',stnlocal);
% if exist(m_add_nc(fname),'file')
%     system(['chmod 644 ' m_add_nc(fname)]);
%     mfsave(fname,dr,'-addvars');
%     system(['chmod 444 ' m_add_nc(fname)]);
% end
% fname = sprintf('ctd/ctd_jc238_%03d_24hz',stnlocal);
% mfsave(fname,dr,'-addvars');
% 
% %remove
% fnames = {sprintf('ctd/ctd_jc238_%03d_psal',stnlocal);
%     sprintf('ctd/ctd_jc238_%03d_2db',stnlocal);
%     sprintf('ctd/ctd_jc238_%03d_2up',stnlocal)};
% for fno = 1:length(fnames)
%     [varlist, var_copystr, iiv] = mvars_in_file(extravars, fnames{fno});
%     if ~isempty(iiv)
%         [d,h] = mload(fnames{fno},'/');
%         [~,ia,ib] = intersect(h.fldnam,extravars);
%         h.fldnam(ia) = [];
%         h.fldunt(ia) = [];
%         d = rmfield(d,extravars(ib));
%         mfsave(fnames{fno},d,h);
%     end
% end
% fname = sprintf('ctd/fir_jc238_%03d',stnlocal);
% ev = {};
% for vno = 1:length(extravars)
%     ev = [ev {['u' extravars{vno}]} {['d' extravars{vno}]}];
% end
% [varlist, var_copystr, iiv] = mvars_in_file(ev, fname);
% if ~isempty(iiv)
%     [d,h] = mload(fname,'/');
%     [~,ia,ib] = intersect(h.fldnam,ev);
%     h.fldnam(ia) = [];
%     h.fldunt(ia) = [];
%     d = rmfield(d,ev(ib));
%     mfsave(fname,d,h);
% end

