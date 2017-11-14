% save matlab vars as mstar file
% not a function, so that we can access variables in current matlab
% filespace

% called from msave. We want to hide most of the work in function.

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'msave';
if ~MEXEC_G.quiet; m_proghd; end

prog = MEXEC_A.Mprog; % save for later

m1 = ' If you want to run this as a script without typing all the responses ';
m2 = ' Then queue the responses in the cell array MEXEC_A.MARGS_IN ';
m3 = ' eg to msave variables x and y in mystarfile.nc with or without units/comments ';
m4 = ' MEXEC_A.MARGS_IN = {''mymstarfile'' ''x'' ''z'' ''/'' ''/'' ''7'' ''-1'' ''comment 1'' ''comment 2'' ''/'' ''/'' ''8'' ''0'' ''/'' ''xunits'' ''/'' ''zunits'' ''/'' ''/''};msave; ';
m5 = ' MEXEC_A.MARGS_IN = {''mymstarfile'' ''x'' ''z'' ''/'' ''s''};msave; ';

if ~MEXEC_G.quiet
fprintf(MEXEC_A.Mfidterm,'%s\n',m1,m2,m3,m4,m5,' ');
end

if length(MEXEC_A.MARGS_IN_LOCAL)==0
   fprintf(MEXEC_A.Mfidterm,'%s','Enter name of output disc file  '); ncfile.name = m_getfilename;
else
   ncfile.name = m_getfilename(MEXEC_A.MARGS_IN_LOCAL{1}); MEXEC_A.MARGS_IN_LOCAL(1) = [];
end

MEXEC_A.MSAVE_VLIST = {ncfile.name};
ok = 0;
while ok == 0
   m = 'next var name or, return or ''/'' to end ';
   reply = m_getinput(m,'s');

   if strcmp(reply, ' ') | strcmp(reply,'/')
      ok = 1;
   else
      reply = m_remove_outside_spaces(reply);
      vname = m_check_nc_varname(reply);
      if strcmp(vname,reply) == 1
         eval(['vlistadd = {reply ' reply '};']);
         MEXEC_A.MSAVE_VLIST = [MEXEC_A.MSAVE_VLIST vlistadd];
      else
         m = [' The var name you entered is not a valid name in mstar NetCDF files: ''' reply ''''];
         m2 = ' If this wasn''t the result of a typing error, I''m afraid you ';
         m3 = ' will have to rename the variable before you can save it';
         fprintf(MEXEC_A.Mfider,'%s\n',m,m2,m3)
      end
   end
   
end


% Now run m_matlab_to_mstar, which has no terminal prompts

margs1 = MEXEC_A.MARGS_OT; % keep a record of input arguments for this prog
MEXEC_A.Mhistory_skip = 1;
m_matlab_to_mstar % data are passed in global MEXEC_A.MSAVE_VLIST
MEXEC_A.Mhistory_skip = 0;

MEXEC_A.MARGS_OT = {}; % clear MEXEC_A.MARGS_OT from m_matlab_to_mstar so we can use it to collect response to mheadr questions
margs2 = {};
margs3 = {};

ok = 0;
while ok == 0
    % queue responses for mheadr ahead of any other MEXEC_A.MARGS_IN responses left
    % over from m_matlab_to_mstar; First store the responses in
    % MEXEC_A.MARGS_IN_LOCAL for call to m_getinput
    MEXEC_A.MARGS_IN_LOCAL = MEXEC_A.MARGS_IN_LOCAL_OLD;
    m1 = ' Now set the units or other header data ''s'' to skip; anything else to proceed \n';
    reply = m_getinput(m1,'s');
    margs2 = MEXEC_A.MARGS_OT;
    
    if strcmp(reply,'s') == 1; break; end
    MEXEC_A.Mhistory_skip = 1;
    emptycell = {}; % if MEXEC_A.MARGS_IN isn't already set to be a cell array, then the next two lines will concatenate ncfile.name
    % and 'y' as char strings not cell elements. emptycell forces the whole
    % thing to be treated as a cell.
    %
    % queue responses for mheadr ahead of any other MEXEC_A.MARGS_IN responses left
    % over from m_matlab_to_mstar; Now store in MEXEC_A.MARGS_IN for call to mheadr
    MEXEC_A.MARGS_IN = MEXEC_A.MARGS_IN_LOCAL;
    MEXEC_A.MARGS_IN = [ncfile.name 'y' MEXEC_A.MARGS_IN(:)' emptycell(:)']; % must use MEXEC_A.MARGS_IN because we are calling mheader which is a 'main' program
    mheadr
    MEXEC_A.Mhistory_skip = 0;
    margs3 = MEXEC_A.MARGS_OT(3:end); % keep a record of input arguments for this prog; skip the first two that weren't taken from terminal

    break
end

MEXEC_A.Mprog = prog;

MEXEC_A.MARGS_OT = [margs1 margs2 margs3];



% fake the input file details so that write_history works
h = m_read_header(ncfile);
histin = h;
histin.filename = [];
histin.dataname = [];
histin.version = [];
histin.mstar_site = [];
MEXEC_A.Mhistory_in{1} = histin;

h = m_read_header(ncfile);
hist = h;
hist.filename = ncfile.name;
MEXEC_A.Mhistory_ot{1} = hist;

m_write_history;
