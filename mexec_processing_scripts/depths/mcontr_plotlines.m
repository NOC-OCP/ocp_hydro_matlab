% inline code called from mcontr
% examples: 
% none
%   
%
hplotall = get(hplot);
posall = hplotall.ContourMatrix;

cdim = size(posall,2);
numcontour = 0;
while cdim > 0
    npoints = posall(2,1); %this set of points listed as one contour, but might be broken by nans
    xpoints = posall(1,2:npoints+1);
    ypoints = posall(2,2:npoints+1);
    while length(xpoints) > 0
        px = []; py = [];
        while ~isnan(xpoints(end)) & ~isnan(ypoints(end))
            % pull non-nan points off the end of the contour
            px = [px xpoints(end)];
            py = [py ypoints(end)];
            xpoints(end) = [];
            ypoints(end) = [];
            if isempty(xpoints); break; end %finish pulling in points when there are none left
        end
        px = fliplr(px); %restore contour order
        py = fliplr(py);

        if length(px) > 0 % save this contour or part of contour
            numcontour = numcontour+1;
            lev{numcontour} = posall(1,1);
            pathx{numcontour} = px;
            pathy{numcontour} = py;
        end

        if isempty(xpoints); break; end  % done with this contour level
        if isnan(xpoints(end)) | isnan(ypoints(end)) % discard this point; then look for another contour part at this level
            xpoints(end) = [];
            ypoints(end) = [];
        end
    end
    posall(:,1:npoints+1) = [];
    cdim = size(posall,2);
end
hold on
% keyboard
% plot each contour line
% first switch off lines in base contour plot
set(hplot,'linestyle','none');

for kcont = 1:numcontour % plot contour lines as required; plot all lines first.
    xd = pathx{kcont};
    yd = pathy{kcont};
    thislevel = lev{kcont};
    thisindex = find(cdfot.clev == thislevel);

    if isempty(thisindex)
        % this is not a contour level chosen by the user. It might be for
        % example introduced by contourf surrounding NaN data.
        continue
    end

    colindex = mod(thisindex,length(cols));
    if colindex == 0; colindex = length(cols); end
    symindex = mod(thisindex,length(symbols));
    if symindex == 0; symindex = length(symbols); end
    styleindex = mod(thisindex,length(styles));
    if styleindex == 0; styleindex = length(styles); end
    widthindex = mod(thisindex,length(widths));
    if widthindex == 0; widthindex = length(widths); end
    labelindex = mod(thisindex,length(labels));
    if labelindex == 0; labelindex = length(labels); end

    lines{kcont} = [cols(colindex) symbols{symindex} styles{styleindex}];
    lwidth = widths(widthindex);

    if lwidth > 0; plot(xd,yd,lines{kcont},'linewidth',lwidth);end

end

% now overplot labels

for kcont = 1:numcontour
    xd = pathx{kcont};
    yd = pathy{kcont};
    thislevel = lev{kcont};
    thisindex = find(cdfot.clev == thislevel);
    
    if isempty(thisindex)
        % this is not a contour level chosen by the user. It might be for
        % example introduced by contourf surrounding NaN data.
        continue
    end


    labelindex = mod(thisindex,length(labels));
    if labelindex == 0; labelindex = length(labels); end
    labelclosedindex = mod(thisindex,length(labelclosed));
    if labelclosedindex == 0; labelclosedindex = length(labelclosed); end



    if labels(labelindex) < 1; continue; end
    % need to add one annotation per contour
    % find running distance
    delx = diff(xd);
    dely = diff(yd);
    deld = sqrt(delx.*delx+dely.*dely);
    dist = [0 cumsum(deld)];
    if dist(end) < .2; continue; end % if contour length is short, skip label
    [du ki kj] = unique(dist);
    if length(du) < 2; continue; end % if fewer than 2 unique points in contour, skip label

    closed = 0;
    if sqrt(abs(xd(1)-xd(end)) + abs(yd(1)-yd(end))) < 1e-10 % closed contour; shift label location cyclicly
        dist_for_label = dist(end)*rem((0.3*thisindex),1);
        closed = 1;
    else
        dist_for_label = dist(end)*(0.3+rem((0.05*thisindex),.4));
%         dist_for_label = dist(end)/2;
        closed = 0;
    end

    str = sprintf('%20.4f',lev{kcont});
    while strcmp(str(end),'0') == 1; str(end) = []; end
    while strcmp(str(end),'.') == 1; str(end) = []; end
    while strcmp(str(1),' ') == 1; str(1) = []; end

    labelx = interp1(du,xd(ki),dist_for_label);
    labely = interp1(du,yd(ki),dist_for_label);
    contourlabelfontsize = max(4,fontsize-2);

    if closed == 0
        if (labelx > 0 & labelx < 1 & labely > 0 & labely < 1) % BAK on JC032: skip labels outside plot area
            hlabel = text(labelx,labely,str);
            set(hlabel,'HorizontalAlignment','center');
        end
    elseif labelclosed(labelclosedindex) == 0
        hlabel = []; % skip plotting of labels on closed contours
    else% if contour is closed, offset the label
        if labelx > 0 & (labelx+0.02*allscale) < 1 & labely > 0 & labely < 1  % BAK on JC032: skip labels outside plot area
            hplus = plot(labelx,labely,'k+','markersize',max(4,fontsize-4));
            hlabel = text(labelx+0.02*allscale,labely,str);
            set(hlabel,'HorizontalAlignment','left');
        end
    end
    if exist('hlabel','var') % BAK on JC032: hlabel may not be set if outside plot area
        set(hlabel,'fontsize',contourlabelfontsize);
        set(hlabel,'backgroundcolor','w');
        set(hlabel,'VerticalAlignment','middle');
    end

end
% keyboard
% % % % % % % clabelall = get(hclabel);
% % % % % % % clall = clabelall;
% % % % % % % nstring = length(clabelall);
% % % % % % % koffset = 0;
% % % % % % % while nstring > 0
% % % % % % % %    cstrings = clabelall.String;
% % % % % % %    % step through and identify sequence of labels that match first label
% % % % % % %    klab = 1;
% % % % % % %    while klab > 0
% % % % % % %        klab = klab+1;
% % % % % % %        if klab > nstring; break; end
% % % % % % %        if strcmp(clall(klab).String,clall(1).String)
% % % % % % %            continue
% % % % % % %        else
% % % % % % %            break
% % % % % % %        end
% % % % % % %    end
% % % % % % %    % sequence of matching labels is 1:klab-1
% % % % % % %    % choose one to plot
% % % % % % %    clear labxpos
% % % % % % %    for kxlab = 1:klab-1
% % % % % % %        labxpos(kxlab) = clall(kxlab).Position(1);
% % % % % % %    end
% % % % % % %    [xsort xi] = sort(labxpos);
% % % % % % %    kchoose = floor((length(labxpos)+1)/2);
% % % % % % %    if kchoose == 0; kchoose = 1; end
% % % % % % %    kindex = xi(kchoose); % This is the label to keep
% % % % % % %
% % % % % % %    % not quite right. needs to be index in full set of labels.
% % % % % % %    % need to thread each contour through all labels for that contour value, count labels, select middle,
% % % % % % %    % restrict line plot.
% % % % % % %    for kxlab = 1:klab-1
% % % % % % % %        set(hclabel(kxlab+koffset),'BackgroundColor','w');
% % % % % % %        set(hclabel(kxlab+koffset),'Visible','off');
% % % % % % %    end
% % % % % % %    set(hclabel(kindex+koffset),'BackgroundColor','w');
% % % % % % % %    set(hclabel(kindex+koffset),'Visible','on');
% % % % % % %    set(hclabel(kindex+koffset),'Visible','off');
% % % % % % %
% % % % % % %
% % % % % % %    clall(1:klab-1) = [];
% % % % % % %    koffset = koffset+klab-1;
% % % % % % %    nstring = length(clall);
% % % % % % %
% % % % % % % end









