% mout_cchdo_sam: write the sample data in sam_cruise_all.nc to CCHDO exchange file
% Use: mout_cchdo_sam        
%
% variables to be written are listed in templates/cchdo_sam_varlist.csv, 
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

scriptname = 'mout_cchdo'; oopt = 'woce_expo'; get_cropt
d.expocode = repmat(expocode,length(d.sampnum),1);
d.sect_id = repmat(sect_id,length(d.sampnum),1);
dn = d.utime/86400+datenum(h.data_time_origin);
d.date = datestr(dn,'yyyymmdd');
d.time = datestr(dn,'HHMM');

%%%%% figure out which fields to write %%%%%

vars = m_cchdo_vars_list(2);
scriptname = 'mout_cchdo'; oopt = 'woce_vars_exclude'; get_cropt
iie = [];
for no = 1:length(vars_exclude_ctd)
    iie = [iie; find(strcmp(vars_exclude_ctd{no},vars(:,3)))];
end
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


%%%%% write %%%%%

scriptname = 'mout_cchdo'; oopt = 'woce_sam_headstr'; get_cropt
fotname = sprintf('%s/%s_hy1.csv',mgetdir('sum'),expocode);
fid = fopen(fotname, 'w');

%header
if ~isempty(headstring)
    fprintf(fid, '%s\n', headstring{:});
end

% more header
fprintf(fid, '%s %d\n', 'NUMBER_HEADERS = ', size(vars,1)); %***+1?

%column headers
fprintf(fid, '%s, ', vars{1:end-1,1});
fprintf(fid, '%s\n', vars{end,1});
fprintf(fid, '%s, ', vars{1:end-1,2});
fprintf(fid, '%s\n', vars{end,2});

%data
for sno = iig
    for cno = 1:size(vars,1)-1
        fprintf(fid, [vars{cno,4} ', '], d.(vars{cno,3})(sno,:));
    end
    fprintf(fid, [vars{end,4} '\n'], d.(vars{end,3})(sno,:));
end

%finish
fprintf(fid, '%s', 'END_DATA');
fclose(fid);
