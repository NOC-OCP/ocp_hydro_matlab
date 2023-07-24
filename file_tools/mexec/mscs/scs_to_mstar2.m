function status = scs_to_mstar2(stream,mstarname,dn1,dn2,varargin)
% function status = scs_to_mstar2(stream,mstarname,dn1,dn2,otfile,dataname,varlist,qflag)
%
% load scs file into mstar file
%
% 8 Sep 2009: SCS version of original techsas script, for JR195
% The searched directory is MEXEC_G.uway_root, which for example can be
% /data/cruise/jcr/20090310/scs_copy/Compress
% The var names and units are taken from ascii file
% seatex-gga.TPL
% for example.
%

m_common
status = 1;

n = 4;
if nargin>n
    otfile = varargin{1};
    if nargin>n+1
        dataname = varargin{2};
        if nargin>n+2
            varlist = varargin{3};
            if nargin>n+3
                qflag = varargin{4};
            end
        end
    end
end
if ~exist('otfile','var'); otfile = stream; end
if ~exist('dataname','var'); dataname = replace(otfile,'.nc',''); end
if ~exist('varlist','var') || isempty(varlist); varlist = '/'; end
if ~exist('qflag','var'); qflag = 1; end

%use msload, then rearrange into data, (updated) names, and units
[data, units] = msload(stream,dn1,dn2,varlist);
if isempty(data.time); return; end
names = fieldnames(data);
[namesnew, vunits] = mtranslate_varnames(names, stream);
for no = 1:length(names)
    if isempty(namesnew{no})
        vunits{no} = units.(names{no});
        data.(names{no}) = data.(names{no})(:);
    else
        data.(namesnew{no}) = data.(names{no})(:);
        data = rmfield(data,names{no});
        names{no} = namesnew{no};
    end
    if strcmp(names{no},'time')
        opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt
        data.(names{no}) = 86400*(data.(names{no}) + uway_torg - datenum(MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN));
        vunits{no} = 'seconds';
    end
end
units = vunits;
data = orderfields(data,names);

%subsample to 1 hz (if indicated) or remove repeated times
opt1 = 'uway_proc'; opt2 = '1hz_max'; get_cropt
if save_1hz_uway && isempty(tstep_force)
    dt = diff(data.time); dt = dt(dt>0); 
    dt = mode(dt);
    tstep = max(round(1/dt),1);
end
if tstep>1
    iits = 1:tstep:length(data.time);
    [~,iit] = unique(data.time(iits),'stable');
    iit = iits(iit);
else
    [~,iit] = unique(data.time,'stable');
end

clear hnew
hnew.fldnam = names(:)';
hnew.fldunt = units(:)';
% subsample time
m = false(1,length(names));
for kl = 1:length(names)
    vname = names{kl};
    if isnumeric(data.(vname))
        m(kl) = true;
        data.(vname) = data.(vname)(iit);
    else
        data = rmfield(data,vname);
        warning('skipping non-numeric variable %s from table %s',vname,table)
    end
end
hnew.fldnam = hnew.fldnam(m); hnew.fldunt = hnew.fldunt(m);

opt1 = 'mstar'; get_cropt
if docf
    hnew.data_time_origin = [];
else
    hnew.data_time_origin = MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN;
end

hnew.dataname = dataname; hnew.instrument_identifier = stream; %***
hnew.comment = ['Variables written from scs to mstar at ' datestr(now,31) ' by ' MEXEC_G.MUSER];
%think these are included by default since they are from MEXEC_G?***
%nc_attput(ncfile.name,nc_global,'platform_type',MEXEC_G.PLATFORM_TYPE); %eg 'ship'
%nc_attput(ncfile.name,nc_global,'platform_identifier',MEXEC_G.PLATFORM_IDENTIFIER); %eg 'James_Cook'
%nc_attput(ncfile.name,nc_global,'platform_number',MEXEC_G.PLATFORM_NUMBER); %eg 'Cruise 31'
if exist(m_add_nc(otfile),'file')
    mfsave(otfile, data, hnew, '-merge', 'time');
else
    mfsave(otfile, data, hnew);
end
status = 0;
