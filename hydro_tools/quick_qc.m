% script to perform some checks on data quality and consistency:
% 1) units of sample data should be in /kg not /L
% 2) flag outliers based on ***
% 3) apply user-specified adjustments to sample data (e.g. from ad hoc
%     pre-GLODAP intercomparison and/or for SSW batch), and/or compare to 
%     GLODAP database and apply GLODAP adjustment if relevant 
% 4) compare sample and CTD data, choose and apply simple calibration
%     and/or GLODAP adjustment if relevant
%
% note 2) should be used sparingly, and 4) will hopefully not be necessary
% (because data will have been calibrated already before being ingested by
% GLODAP)

%check concentrations in /kg not /L, convert if necessary
if reloads
    clear unts_expect
    unts_expect.nitr = 'umol/kg';
    unts_expect.phos = 'umol/kg';
    unts_expect.silc = 'umol/kg';
    unts_expect.dic = 'umol/kg';
    unts_expect.oxygen = 'umol/kg';
    unts_expect.sf6 = 'pmol/kg';
    vb = check_units(sdata, unts_expect);
    if ~isempty(vb)
        if isfield(cdata, 'SA')
            SA = cdata.SA;
        elseif isfield(cdata, 'asal')
            SA = cdata.asal;
        else
            SA = gsw_SA_from_SP(cdata.psal,cdata.press,cdata.lon,cdata.lat);
        end
        dens = gsw_rho_t_exact(SA,cdata.temp,cdata.press);
    end
    for no = 1:length(vb)
        ii = find(strcmp(vb{no},sdata.vars));
        if strcmpi(sdata.unts{ii}(end-1:end), '/l')
            sdata.(sdata.vars{ii}) = sdata.(sdata.vars{ii})/(dens/1000);
            sdata.unts{ii} = [sdata.unts(1:end-1) 'kg'];
        end
    end
end

%check for bad data
ii = find(cdata.psal<20 | cdata.psal>40);
if ~isempty(ii)
    
end