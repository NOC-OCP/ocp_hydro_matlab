function skeleton_in1_ot1

% skeleton program with input and output to different files

m_common
m_margslocal
m_varargs

MEXEC_A.Mprog = 'skeleton_in1_ot1';
if ~MEXEC_G.quiet; m_proghd; end

fprintf(MEXEC_A.Mfidterm,'%s','Input file name     ')
fn_in = m_getfilename;
fprintf(MEXEC_A.Mfidterm,'%s','Output file name    ')
fn_ot = m_getfilename;
ncfile_in.name = fn_in;
ncfile_ot.name = fn_ot;

% m = 'Output file will be same as input file. OK ? Type y to proceed ';
% reply = m_getinput(m,'s');
% if strcmp(reply,'y') ~= 1
%     disp('exiting')
%     return
% end

ncfile_in = m_openin(ncfile_in);
ncfile_ot = m_openot(ncfile_ot);


h = m_read_header(ncfile_in);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile_in.name;
MEXEC_A.Mhistory_in{1} = hist;


% --------------------
% Now do something with the data
% first write the same header; this will also create the file
h.openflag = 'W'; %ensure output file remains open for write, even though input file is 'R';
m_write_header(ncfile_ot,h);

for k = 1:h.noflds
    vname = h.fldnam{k};
    m_copy_variable(ncfile_in,vname,ncfile_ot,vname);
end
% --------------------




m_finis(ncfile_ot);

h = m_read_header(ncfile_ot);
if ~MEXEC_G.quiet; m_print_header(h); end

hist = h;
hist.filename = ncfile_ot.name;
MEXEC_A.Mhistory_ot{1} = hist;
m_write_history;


return