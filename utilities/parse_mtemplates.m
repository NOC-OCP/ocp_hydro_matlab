function [snames, sunits, sdef] = parse_mtemplates(templatefile);
% [snames, sunits, sdef] = parse_mtemplates(templatefile);

cellall = mtextdload(templatefile,','); % load all text

for kline = 1:length(cellall)
    cellrow = cellall{kline}; % unpack rows
    snames{kline} = m_remove_outside_spaces(cellrow{1});
    sunits{kline} = m_remove_outside_spaces(cellrow{2});
    if length(cellrow) > 2 % unpick default value if its there
        sdef{kline} = m_remove_outside_spaces(cellrow{3}); % string, inserted in a command later on
    else
        sdef{kline} = 'nan'; % backwards compatible. If there's no default use nan
    end
end

snames = snames(:);
sunits = sunits(:);
sdef = sdef(:);

if 0 %old code for writing back to out file in case original file had wrong line terminators; don't expect this to come up generally
    %can probably remove this block
    numvar = length(snames);
    fidmsam01 = fopen(varfileout,'w'); % save back to out file
    for k = 1:numvar
        fprintf(fidmsam01,'%s%s%s\n',snames{k},',',sunits{k});
    end
    fclose(fidmsam01);
end