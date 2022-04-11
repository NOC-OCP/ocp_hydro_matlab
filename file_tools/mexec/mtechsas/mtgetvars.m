function [vars units] = mtgetvars(instream)
% function [vars units] = mtgetvars(instream)
%
% first draft BAK JC032
% 
% mstar techsas (mt) routine; requires mexec to be set up
%
% tstream is the part of the techsas filename that does not include the
% date; ie the first 16 chars have been removed; eg
% 20090318-235958-SBE-SBE45.TSG
% becomes SBE-SBE45.TSG
% 
% The var and units list is taken from the first matching file in a dir command.
%
% The techsas files are searched for in a directory MEXEC_G.uway_root defined in
% the mexec setup. At sea, this will typically be a data area exported from a
% ship's computer and cross-mounted on the mexec processing machine

m_common
tstream = mtresolve_stream(instream);

files = dir(fullfile(MEXEC_G.uway_root, ['*' tstream]));

if ~isempty(files)

    ncf.name = files(1).name;

    techsas_varnames = m_unpack_varnames(ncf);

    for k = 1:length(techsas_varnames)
        techsas_units{k} = nc_attget(ncf.name,techsas_varnames{k},'units');
    end

    vars = techsas_varnames(:);
    units = techsas_units(:);

else

    m = 'There appears to be a problem in mtvars';
    fprintf(MEXEC_A.Mfider,'%s\n',' ',m,' ')
    return
end

