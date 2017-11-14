function dep = mcarter(lat,lon,uncdep)
% function dep = mcarter(lat,lon,uncdep)
%
% function cordep = mcarter(lat,lon,uncdep); use Carter tables to return corrected seabed depth
%
% can be used in a matlab session or called from mcalib or mcalc
%
% make carter area depth correction to uncdep (depth in metres) at lat lon
% should work ok on N-Dimensional arrays
% carea has same dimensions as lat and lon
% cordep has same dimensions as uncdep
%
% if carter correction .mat file does not exist, create it
% using m_make_carter
% check value
% cordep = mcarter(0,0,5051); == [5079.53 23]
%
% INPUT:
%   uncdep: (metres) echo sounder depths assuming c = 1500 m/s
%   lat: latitude (degrees); truncated to range -90 <= lat <= 89.5
%   lon: longitude (degrees); any lon OK since mcrange is used to ensure -180 <= lon < 180
%
% OUTPUT:
%   cordep is a structure
%   cordep.cordep : corrected depth in metres;
%   cordep.carter_area : carter area in the range 1:85;
%   cordep.default_names = {'cordep' 'carterarea'};
%   cordep.default_units = {'metres' 'carterarea'};
%
% EXAMPLES:
%   cordep = mcarter(0,0,5051); % check value should be 5079.53 in Carter area 23
%
% UPDATED:
%   Initial version BAK 2008-10-17 at NOC
%   Help updated by BAK 2009-08-11 on macbook
%   Error handling by BAK 2009-08-11 on macbook


m_common
MEXEC_A.Mprog = 'mcarter';
if ~MEXEC_G.quiet; m_proghd; end

% fn = [MCARTER_DIRECTORY '/carter'];
% d = load(fn); % load mat file.


% error check on dimensions of input arguments; easiest check is to attempt
% to add them and let matlab do the check for us.
try
    suminput = lat+lon+uncdep;
catch
    % jump to here if sum fails
    m1 = 'input variables lat, lon, uncdep do not have matching dimensions';
    m2 = 'dimensions were:';
    m3 = ['lat:    ' num2str(size(lat)) ];
    m4 = ['lon:    ' num2str(size(lon)) ];
    m5 = ['uncdep: ' num2str(size(uncdep)) ];
    m6 = sprintf('%s\n',m1,m2,m3,m4,m5);
    error('mexec:mcarter:input_dimension_mismatch','\n%s\n',m6);
end

ok = 0;
for k = 1 % one pass through the checks
    if isfield(MEXEC_G,'Mcarter') ~= 1; ok = 0; break; end% database appears not to have been built
    if isfield(MEXEC_G.Mcarter,'c_area') ~= 1; ok = 0; break; end
    if numel(MEXEC_G.Mcarter.c_area) ~= 64800; ok = 0; break; end
    if MEXEC_G.Mcarter.c_area(32490) ~= 23; ok = 0; break; end % check value at lat = 0, lon = 0
    if isfield(MEXEC_G.Mcarter,'c_corrected') ~= 1; ok = 0; break; end
    if numel(MEXEC_G.Mcarter.c_corrected) ~= 85; ok = 0; break; end % 85 carter areas
    pcheck = MEXEC_G.Mcarter.c_corrected{23};
    if pcheck(end) ~= 8175; ok = 0; break; end
    ok = 1;
end

if ok == 0
    m1 = 'Building Carter area database; once only per matlab session';
    m2 = 'results stored in global structure variable MEXEC_G.Mcarter';
    fprintf(MEXEC_A.Mfider,'%s\n',m1,m2);
    m_make_carter; % results will be saved in global, so only executed once per matlab session
end

careas = MEXEC_G.Mcarter.c_area;


lat(lat < -90) = -90;
lat(lat >= 90) = 89.5;
lon  = mcrange(lon,-180,180);
klati = floor(lat) + 91;
kloni = floor(lon) + 181;

kindex = klati + (kloni-1)* size(careas,1);

kindexok = isfinite(kindex);
carea = nan+lat;
carea(kindexok) = careas(kindex(kindexok));
if length(carea)==1; carea = repmat(carea, size(uncdep)); end

% now get the depth correction

cordep = nan+uncdep;

for k = 1:numel(uncdep)
    if isnan(carea(k)); continue; end
    corrprof = MEXEC_G.Mcarter.c_corrected{carea(k)};
    % corrprof = double(corrprof);
    x1 = floor(uncdep(k)/100); % ensure uncdep(k) is properly bracketed in corrprof
    x2 = x1+3;
    x1 = max(x1,1);
    x2 = min(x2,length(corrprof));
    x1 = min(x1,x2-1); % bak on jr302 7 jun 2014. Avoid crash if unc is greater than max depth for which table is defined
    % z = 0:100:13000;
    % x = z(1:length(corrprof));
    cordep(k) = interp1(100*[x1:x2]-100,corrprof([x1:x2]),uncdep(k));
end
% reshape(cordep,size(uncdep,1),size(uncdep,2));

dep.cordep = cordep;
dep.carter_area = carea;
dep.default_names = {'cordep' 'carterarea'};
dep.default_units = {'metres' 'carterarea'};

return