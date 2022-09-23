%script called by gridhsec to load and combine sample data from file_lists
%using parse_load_hdata
%get rid of data where there's no good ctd data***, and make list of
%variables to map 

%variables to load
if isfield(info, 'vnu')
    vnu = info.vnu;
else
    vnu = dataset('File','varnamesunits_lookup.csv', 'Delimiter', ',');
end

if ~isempty(file_lists)
    disp(['loading ' num2str(length(file_lists)) ' sample files'])
    tic
    options = {'predir' info.samdir 'badflags' info.sbadflags 'expocode' info.expocode 'single_block' 1};
    if isfield(info, 'sam_hcpat')
        options = [options 'hcpat' info.sam_hcpat];
    end
    sdata = parse_load_hdata(file_lists, vnu, options);
    toc
    
    %make vars just list variables to map, not coordinate variables
    [sdata.vars,iil] = setdiff(sdata.vars, coordv);
    sdata.unts = sdata.unts(iil);
    %or flag variables
    iifs = find(contains(sdata.vars, '_flag'));
    sdata.vars(iifs) = []; sdata.unts(iifs) = [];
    
    %use "bottle" temp (sbe35) if available, otherwise make ctdtemp temp***
    iitb = find(strcmp(sdata.vars, 'temp'), 1); iitc = find(strcmp(sdata.vars, 'ctdtemp'));
    if isempty(iitb) && length(iitc)==1
        sdata.temp = sdata.ctdtemp; sdata = rmfield(sdata, 'ctdtemp');
        sdata.vars(iitc) = [];
    end
    
    %get lat, lon, press if necessary
    if ~isfield(sdata, 'lat')
        sdata.lat = NaN+sdata.niskin; sdata.lon = sdata.lat;
        [s,ii] = unique(cdata.statnum);
        sdata.lat = interp1(s, cdata.lat(ii), sdata.statnum, 'nearest');
        sdata.lon = interp1(s, cdata.lon(ii), sdata.statnum, 'nearest');
    end
    if ~isfield(sdata, 'press')
        sdata.press = NaN+sdata.niskin;
        if isfield(sdata, 'depth')
            ii = find(~isnan(sdata.depth+sdata.lat));
            sdata.press(ii) = sw_pres(sdata.depth(ii), sdata.lat(ii));
        else
            warning('no depth or pressure in sample data file')
            keyboard
        end
    end

    
    %keep only vectors of good data for stations and depths where there is
    %good cdata
    iig = find(ismember(sdata.statnum, cdata.statnum) & sdata.press>=min(cdata.press)-100 & sdata.press<=max(cdata.press)+100);
    iib = [];
    fns = fieldnames(sdata); fns = fns(~contains(fns,'vars')); fns = fns(~contains(fns,'unts'));
    for vno = 1:length(fns)
        data = sdata.(fns{vno}); data = data(iig);
        if vno<=length(sdata.vars) && sum(~isnan(data))==0
            iif = find(strcmp(sdata.vars, [fns{vno} '_flag']));
            iib = [iib vno iif];
        else
            sdata.(fns{vno}) = data;
        end
    end
    if ~isempty(iib)
        sdata.vars(iib) = []; sdata.unts(iib) = [];
        sdata = rmfield(sdata, fns(iib));
    end
    
else
    sdata = struct([]);
end

%sort out nitrate vs no2+no3 in sdata (make sure we have something called nitr if possible)
iin = find(strcmp('nitrate', sdata.vars));
iit = find(strcmp('no2_no3', sdata.vars));
if ~isempty(iit) %if there's the sum, use it
    sdata.nitr = sdata.no2_no3;
    sdata.vars = [sdata.vars 'nitr'];
    sdata.unts = [sdata.unts sdata.unts{iit}];
    readme = [readme; 'nitr is no2+no3'];
elseif ~isempty(iin) %otherwise, if there's nitrate, use it
    sdata.nitr = sdata.nitrate;
    sdata.vars = [sdata.vars 'nitr'];
    sdata.unts = [sdata.unts sdata.unts{iin}];
    readme = [readme; 'nitr is nitrate'];
end
if isfield(sdata, 'nitr') %take the others out of list of variables to map
    iin = [iin find(strcmp('nitrite', sdata.vars))];
    sdata.vars([iit iin]) = [];
    sdata.unts([iit iin]) = [];
end

clear iil iifs iib iic iif iin iit ii
disp('sample data loaded')
