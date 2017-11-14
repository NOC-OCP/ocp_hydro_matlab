unc = nan(100,10);
cor = unc;
for k1 = 1:70;
    for k2 = 1:10
        unc(k1,k2) = 100*k1+10*(k2-1);
        cordep = mcarter(50,-50,unc(k1,k2));
        cor(k1,k2) = cordep.cordep;
    end
end

fprintf(1,'         ');
fprintf(1,'%6.0f ',[0:10:90]);
fprintf(1,'\n\n');

for k1 = 2:70
    crow = cor(k1,:);
    if sum(crow(~isnan(crow))) > 0
        fprintf(1,'%6.0f   ',unc(k1,1));
        fprintf(1,'%6.0f ',crow(~isnan(crow)));
        fprintf(1,'\n');
    end
end