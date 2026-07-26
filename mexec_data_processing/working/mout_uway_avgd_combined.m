function mout_uway_avgd_combined

m_common

opt1 = 'ship'; opt2 = 'datasys_best'; get_cropt

%make sure 60-s ocean data is first, then nearest-neighbor interpolate 30-s
%atmos and nav data to its times
files = {'ocean' fullfile(mgetdir('surfmet'),sprintf('surface_ocean_%s.nc',mcruise));...
    'atmos' fullfile(mgetdir('surfmet'),sprintf('atmos_truewind_%s.nc',mcruise));...
    'nav' fullfile(mgetdir(default_navstream),sprintf('bestnav_%s.nc',mcruise));...
    }; 
if ~exist(files{end,2},'file')
    files{end,2} = fullfile(MEXEC_G.mexec_data_root,'nav',sprintf('bestnav_%s.nc',mcruise));
end
opt1 = 'uway_proc'; opt2 = 'tsg_cals'; get_cropt
tcstr = sprintf('temp_remote_cal (measured inlet %s [%s])', uo.calstr.temp_remote.pl.msg, uo.calstr.temp_remote.pl.(mcruise));
scstr = sprintf('salinity_cal (measured %s [%s])', uo.calstr.salinity.pl.msg, uo.calstr.salinity.pl.(mcruise));
hd = {
    '60 s means of underway surface ocean data and subsampled 30 s means of underway meteorological and navigation and attitude data';
    ['processed using https://github.com/NOC-OCP/ocp_hydro_matlab (branch dy180_post2; commit ' MEXEC_G.mexec_version(1:7) ')'];
    'bad or low-flow points edited out of cond; fluo; salinity; soundvelocity; temp_remote; temph; trans';
    ['navigation from ' default_navstream '; heading from ' default_hedstream '; attitude from ' default_attstream];
    'original fields from uncontaminated seawater system: flow; fluo (from fluorescence); trans (transmissivity); temph (SBE45 housing temperature); cond (SBE45 conductivity); salinity (SBE45 derived salinity); soundvelocity (SBE45 derived sound velocity); temp_remote (SBE38 temperature at inlet)';
    ['calibrated fields: ' tcstr '; ' scstr];
    };

for fno = 1:size(files,1)
    [d, h] = mload(files{fno,2},'/');
    dt = struct2table(d);
    dt.Properties.VariableUnits = h.fldunt;
    if ~sum(strcmp('dday',h.fldnam))
        tu = sprintf('days since %d-01-01 00:00:00',MEXEC_G.MDEFAULT_DATA_TIME_ORIGIN);
        if isfield(d,'timesec')
            timvar = 'timesec';
        else
            timvar = 'times';
        end
        dt.dday = m_commontime(d,timvar,h,tu);
        dt.Properties.VariableUnits{end} = tu;
    end
    [~,ikeep] = setdiff(dt.Properties.VariableNames,{'timesec','dum_e','dum_n','times','distrun','smg','cmg'});
    dt = dt(:,ikeep);
    if fno==1
        [~,ii] = sort(dt.Properties.VariableNames);
        dt = dt(:,ii);
        ii = find(strcmp('dday',dt.Properties.VariableNames));
        dt = dt(:,[ii 1:ii-1 ii+1:end]);
        dtc = dt;
    else
        t = dt.dday; 
        dt(:,strcmp('dday',dt.Properties.VariableNames)) = [];
        [c,ia,ib] = intersect(round(dtc.dday*24*60), round(t*24*60));
        nc = size(dtc,2); ncn = size(dt,2);
        dtc(ia,nc+[1:ncn]) = dt(ib,:);
        dtc.Properties.VariableNames(nc+[1:ncn]) = dt.Properties.VariableNames;
        dtc.Properties.VariableUnits(nc+[1:ncn]) = dt.Properties.VariableUnits;
    end
end
%delete rows with no atmos or ocean data
names0 = dtc.Properties.VariableNames;
m1 = ~ismember(names0,{'dday','latitude','longitude','heave','heading','pitch','roll'});
ii = find(sum(isnan(dtc{:,m1}) | dtc{:,m1}==0, 2)<sum(m1));
%unless they are in the middle
ii = ii(1):ii(end);
dtc = dtc(ii,:);

%add (overwrite?***) units (for now; this should happen earlier)
nm = dtc.Properties.VariableNames;
un = dtc.Properties.VariableUnits;
un(strncmp('salinity',nm,8)) = {'psu (pss-78)'};
un(strncmp('temp',nm,4)) = {'degrees Celsius (its-90)'};
un(strncmp('soundv',nm,6)) = {'m/s'};
un(strncmp('fluo',nm,4)) = {'ug/L'};
un(strncmp('flow',nm,4)) = {'L/min'};
un(strcmp('heave',nm)) = {'m'};
un(strcmp('pitch',nm)) = {'degrees'};
un(strcmp('roll',nm)) = {'degrees'}; 
un(strcmp('latitude',nm)) = {'decimal degrees [+N -S]'};
un(strcmp('longitude',nm)) = {'decimal degrees [+E -W]'};
dtc.Properties.VariableUnits = un;

%print to file
outfile = fullfile(mgetdir('sum'),sprintf('underway_%s.csv',mcruise));
fid = fopen(outfile,'w');
fprintf(fid,'%s\n',hd{:});
fprintf(fid,'%s\n',strjoin(dtc.Properties.VariableNames,','));
fprintf(fid,'%s\n',strjoin(dtc.Properties.VariableUnits,','));
for rno = 1:length(dtc.dday)
    fprintf(fid,'%f,',dtc{rno,1:end-1});
    fprintf(fid,'%f\n',dtc{rno,end});
end
fclose(fid);
