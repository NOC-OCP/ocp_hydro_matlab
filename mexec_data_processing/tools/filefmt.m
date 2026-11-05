function outfile = filefmt(infile,varargin)
[p,f,e] = fileparts(infile);
outfile = fullfile(p,sprintf([f e],varargin{:}));
end