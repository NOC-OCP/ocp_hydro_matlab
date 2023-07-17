function [vars, units] = msgetvars(instream)
% function [vars, units] = msgetvars(instream)
%
% first draft BAK JC032
% 
% mstar scs (mt) routine; requires mexec to be set up
%
% tstream is the part of the scs filename that does not include the
% date; ie the first 16 chars have been removed; eg
% 20090318-235958-SBE-SBE45.TSG
% becomes SBE-SBE45.TSG
% 
% The var and units list is taken from the first matching file in a dir command
%
% The scs files are searched for in a directory uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine
%
% 8 Sep 2009: SCS version of original techsas script, for JR195
% The searched directory is uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% for example.

m_common
tstream = msresolve_stream(instream);

scriptname = 'ship'; oopt = 'datasys_best'; get_cropt
files = dir(fullfile(uway_sed, [tstream '.TPL']));

if ~isempty(files)

    ncf.name = files(1).name;

    techsas_varnames = m_unpack_varnames(ncf);

    for k = 1:length(techsas_varnames)
        techsas_units{k} = nc_attget(ncf.name,techsas_varnames{k},'units');
    end

    vars = techsas_varnames(:);
    units = techsas_units(:);

else

    m = 'There appears to be a problem in msvars';
    m2 = result;
    fprintf(MEXEC_A.Mfider,'%s\n',' ',m,m2,' ')
    return
end

