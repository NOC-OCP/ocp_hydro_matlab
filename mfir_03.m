% mfir_03: merge ctd upcast data onto fir file
%
% Use: mfir_03        and then respond with station number, or for station 16
%      stn = 16; mfir_03;

minit; scriptname = mfilename;
mdocshow(scriptname, ['adds CTD upcast data at bottle firing times to fir_' mcruise '_' stn_string '_ctd.nc']);

root_ctd = mgetdir('M_CTD');
prefix1 = ['fir_' mcruise '_'];
prefix2 = ['ctd_' mcruise '_'];
infile1 = [root_ctd '/' prefix1 stn_string '_time'];
infile2 = [root_ctd '/' prefix2 stn_string '_psal'];
otfile2 = [root_ctd '/' prefix1 stn_string '_ctd'];
wkfile1 = ['wk1_' scriptname '_' datestr(now,30)];
dcsfile = [root_ctd '/dcs_' mcruise '_' stn_string];

var_copycell = mcvars_list(2);

% remove any vars from copy list that aren't available in the input file
numcopy = length(var_copycell);
h_input = m_read_header(infile2);
for kloop_scr = numcopy:-1:1
    if isempty(strmatch(var_copycell(kloop_scr),h_input.fldnam,'exact'))
        var_copycell(kloop_scr) = [];
    end
end
var_copystr = ' ';
for kloop_scr = 1:length(var_copycell)
    var_copystr = [var_copystr var_copycell{kloop_scr} ' '];
end
var_copystr(1) = [];
var_copystr(end) = [];

% construct names and units cell array for mheadr
snames_units = {};
for kloop_scr = 1:length(var_copycell)
    snames_units = [snames_units; var_copycell(kloop_scr)];
    snames_units = [snames_units; {['u' var_copycell{kloop_scr}]}];
    snames_units = [snames_units; {'/'}];
end

get_cropt; %fillstr

%--------------------------------
MEXEC_A.MARGS_IN = {
otfile2
infile1
'/'
'time'
infile2
'time'
var_copystr
fillstr
};
mmerge
%--------------------------------

%--------------------------------
MEXEC_A.MARGS_IN_1 = {
otfile2
'y'
'8'
};
MEXEC_A.MARGS_IN_2 = snames_units(:);
MEXEC_A.MARGS_IN_3 = {
'-1'
'-1'
};
MEXEC_A.MARGS_IN = [MEXEC_A.MARGS_IN_1; MEXEC_A.MARGS_IN_2; MEXEC_A.MARGS_IN_3];
mheadr
%--------------------------------

%ylf added dy113: add info about local gradients (and
%wiggliness)***incomplete, doesn't propagate through to sam
gvar_copycell = mcvars_list(3);
otfilestruct=struct('name',[otfile2 '.nc']);
d=mload(otfilestruct.name,'upress',' ');
[d1,h1] = mload(infile2,'/');
sb = mload(dcsfile,'scan_bot',' ');
deltap = 10;
mp = abs(repmat(d.upress,1,length(d1.press))-repmat(d1.press,length(d.upress),1))<=deltap/2;
mp = mp & repmat(d1.scan,length(d.upress),1)>=sb.scan_bot;
numcopy = length(gvar_copycell);
for kls = numcopy:-1:1
    if ~isempty(strmatch(gvar_copycell(kls), h1.fldnam, 'exact'))
        g = getfield(d1, gvar_copycell{kls});
        g = nanmean(abs(diff((repmat(g,length(d.upress),1).*mp)'))); 
        m_write_variable(otfilestruct,struct('name',[gvar_copycell{kls} 'grad'],'units',['<Delta/10 dbar>'],'data',g));
    end
end

