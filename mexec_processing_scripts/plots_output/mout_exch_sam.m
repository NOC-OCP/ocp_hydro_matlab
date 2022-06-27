% mout_exch_sam: write the sample data in sam_cruise_all.nc to CCHDO exchange file
% Use: mout_exch_sam        
%
% variables to be written are listed in templates/exch_sam_varlist.csv, 
%    a comma-delimited list of vars to be renamed
%    The format of each column is
%    CCHDOname,CCHDOunits,mstarname,format string
%

mcruise = MEXEC_G.MSCRIPT_CRUISE_STRING;


%%%%% load input data %%%%%

root_ctd = mgetdir('M_CTD');
infile1 = [root_ctd '/sam_' mcruise '_all'];

[d, h] = mload(infile1,'/');
iig = find(~isnan(d.upress)); 
iig = iig(:)';


%%%%% add some fields that don't exist (or edit) %%%%%

scriptname = 'mout_exch'; oopt = 'woce_expo'; get_cropt
d.expocode = repmat(expocode,length(d.sampnum),1);
d.sect_id = repmat(sect_id,length(d.sampnum),1);
if isfield(d,'utime')
    dn = d.utime/86400+datenum(h.data_time_origin);
else
    dn = d.time/86400+datenum(h.data_time_origin);
end
d.date = datestr(dn,'yyyymmddHHMM');
d.time = d.date(:,9:12); d.date = d.date(:,1:8);
if ~isfield(d,'ulatitude') && isfield(d,'latitude')
    d.ulatitude = d.latitude; d.ulongitude = d.longitude;
end
if ~isfield(d,'ulatitude') && isfield(d,'lat')
    d.ulatitude = d.lat; d.ulongitude = d.lon;
end
if ~isfield(d, 'castno')
    d.castno = ones(size(d.sampnum));
end
if ~isfield(d, 'depth') || sum(~isnan(d.depth))==0
    sumfn = [mgetdir('M_SUM') '/station_summary_' mcruise '_all.nc'];
    if exist(sumfn,'file')
        [dsum, hsum] = mloadq(sumfn,'/');
        d.depth = NaN+zeros(size(d.sampnum));
        for sno = 1:length(dsum.statnum)
            ii = find(d.statnum==dsum.statnum(sno));
            d.depth(ii) = dsum.cordep(sno);
        end
    end
end


%%%%% figure out which fields to write %%%%%

vars = m_exch_vars_list(2);
scriptname = 'mout_exch'; oopt = 'woce_vars_exclude'; get_cropt
iie = [];
for no = 1:length(vars_exclude_sam)
    iie = [iie; find(strcmp(vars_exclude_sam{no},vars(:,3)))];
end
vars(iie,:) = [];

%flags
for vno = 1:size(vars,1)
    if endsWith(vars{vno,3}, '_flag')
        varn = vars{vno,3}(1:end-5);
        %first some backwards compatibility on flag names
        if ~isfield(d, vars{vno,3}) && isfield(d, [varn 'flag'])
            %used to not have an underscore
            d.(vars{vno,3}) = d.([varn 'flag']);
        elseif strcmp(vars{vno,3},'sbe35temp_flag') && isfield(d, 'sbe35flag')
            %special case
            d.sbe35temp_flag = d.sbe35flag;
        end
        %now add column of NaNs for samples with flags but no data yet
        if isfield(d, vars{vno,3}) && ~isfield(d, varn)
            %add column of NaNs for samples with flags but no data yet
            d.(vars{vno,3}(1:end-5)) = NaN+d.(vars{vno,3});
        end
        %and for samples with data but no flags, create flag variable
        if ~isfield(d, vars{vno,3}) && isfield(d, varn)
            d.(vars{vno,3}) = 2+zeros(size(d.(varn)));
            d.(vars{vno,3})(isnan(d.(vars{vno,3}(1:end-5)))) = 4;
        end
    end
end

%replace NaNs with fill values and find which variables are present
for vno = 1:size(vars,1)
    if isfield(d, vars{vno,3})
        if endsWith(vars{vno,3},'_flag')
            d.(vars{vno,3})(isnan(d.(vars{vno,3}))) = 9;
        else
            d.(vars{vno,3})(isnan(d.(vars{vno,3}))) = -999;
        end
    else
        iie = [iie; vno];
    end
end
vars(iie,:) = [];

%make sure there are no duplicate column headers by selecting first
[~,ia,~] = unique(vars(:,1));
vars = vars(sort(ia),:);
    

%%%%% write %%%%%

scriptname = 'mout_exch'; oopt = 'woce_sam_headstr'; get_cropt
fotname = fullfile(mgetdir('sum'), sprintf('%s_hy1.csv',expocode));
fid = fopen(fotname, 'w');

%header
if ~isempty(headstring)
    fprintf(fid, '%s\n', headstring{:});
end

%column headers
fprintf(fid, '%s,', vars{1:end-1,1});
fprintf(fid, '%s\n', vars{end,1});
fprintf(fid, '%s,', vars{1:end-1,2});
fprintf(fid, '%s\n', vars{end,2});

%data
for sno = iig
    for cno = 1:size(vars,1)-1
        fprintf(fid, [vars{cno,4} ','], d.(vars{cno,3})(sno,:));
    end
    fprintf(fid, [vars{end,4} '\n'], d.(vars{end,3})(sno,:));
end

%finish
fprintf(fid, '%s', 'END_DATA');
fclose(fid);
