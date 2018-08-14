% script called from mplxyed

if ~exist('kfind','var')
    m = 'No data selected to edit';
    m1 = 'Select some data first with option s';
    fprintf(MEXEC_A.Mfider,'%s\n',m,m1)
    return
else
    subindex = kfind{vared}(:)';
    if length(subindex) == 0
        m = 'No data cycles selected to edit';
        m1 = 'Select some data first with option s';
        fprintf(MEXEC_A.Mfider,'%s\n',m,m1)
        return
    end
end

if kedit == 0;
    % first time in edit case
    kedit = 1; % set a flag to show that some editing has been done
    ncf = m_openio(pdfot.ncfile); % set write flag
    % create a variable to record the edits
    kedits = [];
end

%list of points to edit
index = x1-1+kfind{vared}(:)';
vnam = h.fldnam{ynumlist(vared)};
kedits = [kedits index];
kedits = unique(kedits);

%load existing data
vdata = nc_varget(pdfot.ncfile.name,vnam,[r1-1 c1-1],[r2-r1+1,c2-c1+1]);
vdata(kfind{vared}) = nan;
%overwrite with edited data
nc_varput(pdfot.ncfile.name,vnam,vdata,[r1-1 c1-1],[r2-r1+1,c2-c1+1]);
m_uprlwr(pdfot.ncfile,vnam);

return
