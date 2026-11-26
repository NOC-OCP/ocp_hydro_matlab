%called by adcp_process and set_cast_params
 
infileu = dir(fullfile(rawdir,uppat));
infiled = dir(fullfile(rawdir,dnpat));
if ~isempty(infiled)
    infiled = infiled(cellfun(@(x) x>1024,{infiled.bytes}));
end
if ~isempty(infileu)
    infileu = infileu(cellfun(@(x) x>1024,{infileu.bytes}));
end
