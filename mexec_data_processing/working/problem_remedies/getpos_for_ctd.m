function [botlon, botlat] = getpos_for_ctd(insource,varargin)
%[botlon, botlat] = getpos_for_ctd(otfile)
%[botlon, botlat] = getpos_for_ctd(otfile, 'write')
%[botlon, botlat] = getpos_for_ctd(otfile, 'write', forceuway)
%[botlon, botlat] = getpos_for_ctd(h);

m_common
forceuway = 0; write = 0;
for no = 1:length(varargin)
    if ischar(varargin{no}) && strcmp(varargin{no},'write')
        write = 1;
    else
        forceuway = varargin{no};
    end
end

if isstruct(insource) && nargin==1
    h = insource;
elseif exist(insource,'file')
    h = m_read_header(insource);
else
    error('insource must be either a mexec file header structure or the full path name of a mexec file; \nonly the second can be used with optional inputs ''write'' and ''forceuway''')
end

if ~forceuway && sum(strcmp('latitude',h.fldnam)) && sum(strcmp('longitude',h.fldnam))
    d = mloadq(insource,'press','latitude','longitude',' ');
    kbot = find(d.press == max(d.press), 1 );
    botlat = d.latitude(kbot); botlon = d.longitude(kbot);
else
    [d, h] = mloadq(insource,'time','press',' ');
    kbot = find(d.press == max(d.press), 1 );
    tbotmat = m_commontime(d.time(kbot),'time',h,'datenum');
    switch MEXEC_G.Mshipdatasystem
        case 'scs'
            [botlat, botlon] = msposinfo(tbotmat);
        case 'techsas'
            [botlat, botlon] = mtposinfo(tbotmat);
        case 'rvdas'
            [botlat, botlon] = mrposinfo(tbotmat);
        otherwise
            botlat = []; botlon = [];
    end
end

if write 
    if isempty(botlat)
        warning('no bottom-of-cast lat, lon found for %s, skipping',insource)
        return
    end
    latstr = sprintf('%14.8f',botlat);
    lonstr = sprintf('%14.8f',botlon);
    MEXEC_A.MARGS_IN = {
        insource
        'y'
        '5'
        latstr
        lonstr
        ' '
        ' '
        };
    mheadr
end
