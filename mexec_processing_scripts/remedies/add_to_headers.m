function add_to_headers(infiles, editvars, editvals, varargin)
% function add_to_headers(infiles, editvars, editvals, varargin);
% function add_to_headers(infiles, editvars, infofiles, varargin);
%
% replace values of one or more header variables in one or more files
%
% inputs:
%   infiles, an Mx1 cell array list of mstar filenames whose headers should be edited
%   editvars, a 1xN cell array list of variables from the file headers to be changed
%   editvals, either an MxN cell array giving the new values, or a Mx1 cell array list of mstar filenames from which to paste the header variable values
% optional parameter-value inputs:
%   inpath, path to the infiles (if not included)
%   infopath, if files were listed in editvals, path to them (if not included)
%   fillonly (default 0) if true, only replace NaN or -999

fillonly = 0;
for no = 1:2:length(varargin)-1
    eval([varargin{no} ' = varargin{no+1};'])
end

for fno = 1:length(infiles)
    if exist('inpath','var')
        infile = fullfile(inpath,infiles{fno});
    else
        infile = infiles{fno};
    end
    
    h = m_read_header(infile);
    modified = 0;

    if size(editvals,2)==1
        if exist('infopath','var')
            infofile = fullfile(infopath,editvals{fno});
        else
            infofile = editvars{fno};
        end
        h0 = m_read_header(infofile);
        for vno = 1:length(editvars)
            if ~fillonly || ~isfinite(h.(editvars{vno})) || h.(editvars{vno})==-999
                h.(editvars{vno}) = h0.(editvars{vno});
                modified = 1;
            end
        end
    else
        for vno = 1:length(editvars)
            if ~fillonly || ~isfinite(h.(editvars{vno})) || h.(editvars{vno})==-999
                h.(editvars{vno}) = editvals{fno,vno};
                modified = 1;
            end
        end
    end

    if modified
        m_write_header(infile,h);
    end

end
