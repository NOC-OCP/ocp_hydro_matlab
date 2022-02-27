% input: 1 Hz pressure (or 1 Hz plus start and end scans)
% min_stop (minimum length of stops in seconds)
% delp (max range of pressure stops)

iib = find(press>=max(press)*.9); press = press(iib(1):end);

min_stop = 100;
delp = 10;

bine = [0:delp:7000];
binc1 = .5*(bine(1:end-1)+bine(2:end));
N = histcounts(press, bine);
binc1 = binc1(N>=min_stop);

mask1 = NaN+zeros(size(press));
for no = 1:length(binc1)
    iis = find(press>=binc1(no)-delp/2 & press<binc1(no)+delp/2);
    dt = diff(iis);
    iid = find(dt>1);
    iid = [[1; iid(:)+1] [iid(:); length(iis)]];
    iid = iid(iid(:,2)-iid(:,1)+1>=min_stop,:);
    for ino = 1:size(iid,1)
        ii = iis(iid(ino,1):iid(ino,2));
        mask1(ii) = binc1(no)+i*ino;
    end
end

bine = [delp/2:delp:7000];
binc2 = .5*(bine(1:end-1)+bine(2:end));
N = histcounts(press, bine);
binc2 = binc2(N>=min_stop);

mask2 = NaN+zeros(size(press));
for no = 1:length(binc2)
    iis = find(press>=binc2(no)-delp/2 & press<binc2(no)+delp/2);
    dt = diff(iis);
    iid = find(dt>1);
    iid = [[1; iid(:)+1] [iid(:); length(iis)]];
    iid = iid(iid(:,2)-iid(:,1)+1>=min_stop,:);
    for ino = 1:size(iid,1)
        ii = iis(iid(ino,1):iid(ino,2));
        mask2(ii) = binc2(no)+i*ino;
    end
end

p1 = NaN+press; p1(real(mask1)>0) = real(mask1(real(mask1)>0));
p2 = NaN+press; p2(real(mask2)>0) = real(mask2(real(mask2)>0));
pstop = nanmean([p1;p2]); 
%not quite right either, still need to separate segments

%combine the two sets of bin definitions
pstop = press; pstop(~real(mask1) & ~real(mask2)) = NaN;
%and find segments again***except there are two overlapping/continuous that
%aren't being separated, need to somehow use average of mask1 and mask2?
isstop = find(~isnan(pstop));
iid = [0 find(diff(isstop)>1) length(isstop)];
stops = NaN+zeros(max(diff(iid)),length(iid)-1);
for ino = 1:length(iid)-1
    ii = isstop(iid(ino)+1:iid(ino+1));
    stops(1:length(ii),ino) = ii;    
end
iid = [[1; iid(:)+1] [iid(:); length(pstop)]];
for ino = 1:size(iid,1)
    ii = iid(ino,1):iid(ino,2)
keyboard


%assign pressures to bins
[psort, iips] = sort(ctd.press);
iibin = interp1(psort, iips, binc, 'nearest');%no, wrong

%select the bins that have stops in them
%iibins = iibin(

bins = [0:delp:7000];

% use histogram to find where the CTD has lingered
N = histcounts(ctd.press,bins);
ass = discretize(ctd.press,bins);
istop = find(N > min_stop);

if ~isempty(istop)
% Stops can only be on the way up find the deepest one to start with
	bot = find(ass == istop(end));
	bot0 = bot(1);
	if max(ctd.press) - ctd.press(bot0) > 25
		fprintf(1,'No bottom stop? \n')
		bb = find(ctd.press == max(ctd.press));
		bot0 = bb(1);
	end


	pstop(1) = -100;  	% Need a value to start with be overwritten
	ic = 0;				% Will count the stops

	for i = length(istop):-1:1
    	bot = find(ass == istop(i));
		bot = bot(bot >= bot0);    % Can't overlap with a preceeding stop
		pst = median(ctd.press(bot));
		if length(bot) > min_stop & min(abs(pstop-pst)) > delp & pst > delp;  
			ivls = find(abs(ctd.press-pst) < 0.5*delp);
			ivls = ivls(ivls >= bot0);
			itail = round(0.025*length(ivls));    % Discard start and end
			ivls = ivls(itail:end-itail+1); 
			if max(diff(ivls)) > 2
				ivls_i = find(diff(ivls) > 2);
				ivls_i = [1;ivls_i;length(ivls)];
				ivls_k = diff(ivls_i);
				ik = find(ivls_k == max(ivls_k)); ik = ik(1);
				ivls = ivls(ivls_i(ik)):ivls(ivls_i(ik+1));
				bot0 = max(ivls);
			end
			if ctd.time(ivls(end))-ctd.time(ivls(1)) > min_stop
				ic = ic+1;
				pstop(ic) = median(ctd.press(ivls)); 
				tstop(ic) = median(ctd.time(ivls)); 
				lstop(ic) = ctd.time(ivls(end))-ctd.time(ivls(1));
				figure(100 + stn)
				plot(ctd.time(ivls)/60,ctd.press(ivls),'LineWidth',2)
				if iopt
% Then look 	at oxygen values during the stop
					ctx.tme = ctd.time(ivls) - ctd.time(ivls(1));
					ctx.press = ctd.press(ivls);
					figure				
					for j = 1:2
						if j == 1
							ctx.oxy = ctd.oxygen1(ivls); 
						else
							ctx.oxy = ctd.oxygen2(ivls); 
						end
						if ireverse
							ctx.oxy = mcoxyhyst_reverse(ctx.oxy,ctx.tme,ctx.press,H1R,H2R,H3R);
						end
						plot(ctx.tme,ctx.oxy)
						hold on;grid on
						abc0  = [mean(ctx.oxy) std(ctx.oxy) 1000];
						abc =  lsqnonlin(@(abc) exp_resid(abc,ctx),abc0,[],[],myopts);
						apprx = abc(1) + abc(2) * exp(-ctx.tme/abc(3));
						plot(ctx.tme,apprx,'k')
						if j == 1
						  txt1 = sprintf('Press %4.0f db Stop %5.0f min Offset = %8.1f, E-fold = %7.0f s \n', ...
						                 pstop(ic),lstop(ic)/60,abc(2),abc(3));
					  	else
	  					  txt2 = sprintf('Press %4.0f db Stop %5.0f min Offset = %8.1f, E-fold = %7.0f s \n', ...
	  					                 pstop(ic),lstop(ic)/60,abc(2),abc(3));
					 	end
					end
					text(0.5*mean(xlim),mean(ylim),[txt1 txt2])
					fprintf(1,'%s',txt1)
					fprintf(1,'%s',txt2)
					title([crs_str ' - Station: ' num2str(stn) ' Press: ' sprintf('%4.0f',pstop(ic))])
				end
			end
		end
	end
end

figure(100+stn)
title([crs_str ' - Station: ' num2str(stn)])
xlabel('Time (min)')	
ylabel('Pressure (db)')

if exist('lstop')
	subplot(2,1,2)
	bar(pstop,lstop/60)
	xlabel('Pressure (db)')
	ylabel('Length of stop (min)')
else
	lstop = 0;
	tstop = 0;
	pstop = 0;
end

if iopt
	fprintf(1,'%s -Station %3.0i. Max press. %4.0f db. Total time %4.0f min, total stops %4.0f min \n',crs_str, ... 
            stn,max(ctd.press),ctd.time(end)/60,sum(lstop)/60)
end
fprintf(1,'%3.0i %4.0f %4.0f %4.0f \n',stn,max(ctd.press),ctd.time(end)/60,sum(lstop)/60)
									
%function dd = exp_resid(abc,ctx)
	dd = ctx.oxy - (abc(1) + abc(2) * exp(-ctx.tme/abc(3)));
					