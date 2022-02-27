function m_add_history(ncfile)
% function m_add_history(ncfile)
%
% write processing steps in the calling program to the netcdf file comments

m_common

h = m_read_header(ncfile);
hist = h;
hist.filename = ncfile.name;
MEXEC_A.Mhistory_ot_local{1} = hist;


if isfield(MEXEC_A,'Mhistory_skip') && MEXEC_A.Mhistory_skip~=0
        m1 = ' *********** ';
        m2 = [' Skipping write of history from program            ' MEXEC_A.Mprog];
        m3 = [' To restart history ensure global variable MEXEC_A.Mhistory_skip = 0'];
        fprintf(MEXEC_A.Mfider,'%s\n',m1,m2,m3,m1)
        return
end


% term = 1;




% BAK 13 Nov 2009: Write the calling tree for the program, so we can
% see what script a program was called from as well as the program name
stacklist = dbstack(1); % get calling history but skip the present function


st = stacklist(end);
% start saving version record to add to file as a comment
commit_version = MEXEC_G.mexec_version; % Added JC211 1 Feb 2021
filecom = ['prog ' st.name '(' commit_version ');']; % eg prog mcopya(v3_commit_3bec1b5c);


if isfield(MEXEC_A,'Mhistory_in') ~= 1
    filecom = [filecom ' in: none ;'];
else
    for kin = 1:length(MEXEC_A.Mhistory_in)
        h = MEXEC_A.Mhistory_in{kin};
        filecom = [filecom ' in: ' h.dataname ' <s> ' h.mstar_site ' <v> ' sprintf('%d',h.version) ';'];
    end
end

filecomin = filecom;

for kot = 1:length(MEXEC_A.Mhistory_ot_local)
    h = MEXEC_A.Mhistory_ot_local{kot};
    filecomot = [filecomin ' out: ' h.dataname ' <s> ' h.mstar_site ' <v> ' sprintf('%d',h.version) ';'];
    ncfot.name = h.filename;
%     fprintf(MEXEC_A.Mfider,'%s\n',filecomot); % for test purposes
    m_add_comment(ncfot,filecomot);% If there's more than one output file, each file's comment variable only gets the output version for that file.
end



return
