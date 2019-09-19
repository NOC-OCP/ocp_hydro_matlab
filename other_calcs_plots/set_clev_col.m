function c = set_clev_col_jc159(c)

% bak jc159 25 march 2018 set clevs and colours for use in plot_cont.m

z = c.zlist; % variable to be plotted

switch z
    case 'potemp'
        c.clev = [0 .25 .5 1 2 2.5 3 3.5 4 5 6 7 8 9 10 12 15 18 21 25];
        cbound = [1 2 3 4 8 10 15]; % from AO_theta.cpt, but does not match A10 plots
        cbound = [1 2 3 4 10 15 20]; % read from A10 plots, online WOCE atlas
        cols = [
            001 146 191
            065 171 206
            127 198 222
            191 226 238
            252 192 184
            250 128 124
            250 066 075
            251 000 038
            ]/255;
        
    case 'psal'
        c.clev = [ 34.3:.1:35.5 35.5:.5:38 34.88 34.96];
        c.clev = round(1e8*c.clev)/1e8;
        cbound = [34 34.3 34.7 34.94 35 35.5 36.0  ];
        cols = [
            001 146 191
            065 171 206
            127 198 222
            191 226 238
            254 231 186
            254 207 122
            254 182 064
            255 158 015
            ]/255;
        
    case {'oxygen' 'botoxy'}
        c.clev = [150:10:300];
        cbound = [140 195 245 255 275]; % from AO_oxygen.cpt, but does not match A10 plots
        cbound = [140 170 200 220 240]; % read from A10 plots, online WOCE atlas 140 1nad 170 are guesses; lowest value on pdf plot is < 180
        cols = [
            255 255 000
            255 255 102
            255 255 204
            220 183 217
            188 117 183
            157 058 153
            ]/255;
        
    case {'fluor' }
        c.clev = [0:.05:.5];
        cbound = [0.02 .05 .1 .4 .5  ];
        cols = [
            255 255 102
            255 255 204
            255 255 204
            220 183 217
            188 117 183
            157 058 153
            ]/255;
        
    case {'silc' 'silc_per_kg'}
        c.clev = [ 1 2 5 10:10:70 70:20:130]; c.clev = unique(c.clev);
        cbound = [ 2 5 10.5 11.5 13 20 30 80]; % AO_silcat.cpt
        cbound = [2 5 15 20 40 60 80]; % read off pdf plot
        cols = [
            255 255 000
        %    255 255 076
            255 255 128
            255 255 178
            255 255 200
            255 204 204
            255 153 153
            255 076 076
            255 000 000
            ]/255;
        
    case {'phos' 'phos_per_kg'}
        c.clev = [0:.2:3]; c.clev = unique(c.clev);
        cbound = [0.5 1.1 1.175 1.4 1.5]; % AO_phspht.cpt
        cbound = [0.5 0.8 1.0 1.2 1.8 2.2 3]; % read off A10 pdf plot
        cols = [
% % %             255 157 076 % AO_phspht.cpt This has 3 oranges, A10 pdf has 4
% % %             255 186 128
% % %             255 211 178
% % %             204 255 204
% % %             128 255 128
% % %             000 255 000
%             
            
            255 158 015 %IO_phspht.cpt
            254 182 064
            254 207 122
            254 231 186
            188 255 188
            150 255 150
            110 255 110
            000 255 000
            ]/255;
        
    case {'totnit' 'totnit_per_kg'}
        c.clev = [0:2:40]; c.clev = unique(c.clev);
%         cbound = [20 30 34 36 40 45];
%         cols = [
%             110 255 110
%             150 255 150
%             188 255 188
%             220 183 217
%             188 117 183
%             157 058 153
%             129 001 126
%             ]/255;
        cbound = [10 15 17.5 18 22]; % AO_nitrat.cpt
        cbound = [10 20 25 30 35 40 45]; % read from A10 pdf plot, 4 greens taken from Indian cpt
%         cols = [ AO_nirtat_cpt
%             000 255 000
%             128 255 128
%             204 255 204
%             230 153 255
%             229 128 255
%             204 102 255
%             ]/255;
         cols = [
             000 255 000
             110 255 110
             150 255 150
             188 255 188
             220 183 217
             188 117 183
             157 058 153
             129 001 126
             ]/255;
        
        
    case 'dic'
        c.clev = [2050:20:2250]; c.clev = unique(c.clev);
%         cbound = [1900 2100 2200 2250 2300 2360];
%         cols = [
%             001 146 191
%             065 171 206
%             127 198 222
%             191 226 238
%             255 255 204
%             255 255 102
%             255 255 000
%             ]/255;
        cbound = [1900 2100 2200 2250 2300 2360]; % IO_tcarbn.cpt;
        cbound = [1900 2000 2100 2200 2250]; % AO_tcarbn.cpt;
        cbound = [2000 2100 2150 2200 2250 2300]; % read from A10 pdf;
        cols = [
%             000 153 255 % Atlantic_cpt_cont
%             000 255 255
%             082 255 255
%             164 255 255
%             255 255 178
%             255 255 076
            001 146 191 % IO_tcarbn.cpt
            065 171 206
            127 198 222
            191 226 238
            255 255 204
            255 255 102
            255 255 000
            ]/255;
        
        
    case 'alk'
        c.clev = [2250:20:2490]; c.clev = unique(c.clev);
        cbound = [2300 2320 2360 2390 2420];% read off I03 pdf
        cols = [
            157 058 153 % IO_alkali.cpt
            188 117 183
            220 183 217
            254 231 186
            254 207 122
            254 182 064
            ]/255;
        
        
        
    case 'cfc11'
        c.clev = [0.01 0.02 0:0.05:.25 .5 1:.5:5 ]; c.clev = unique(c.clev);
        cbound = [0.02 .25 0.5 1 2 8];% read off I03 pdf and from AO_cfc11.cpt
        cols = [
            039 164 126 % AO_cfc11.cpt
            092 188 149
            147 212 179
            201 234 214
            251 192 223
            248 129 191
            244 068 159
            ]/255;
        
    case 'cfc12'
        c.clev = [ 0.01 0.02 0:0.05:.2 .5 1 1.25 1.5:.1:2 2:.2:4]; c.clev = unique(c.clev);
        cbound = [0.02 .25 0.5 1 2 8]/2;% read off I03 pdf
        cols = [
            039 164 126 % AO_cfc12.cpt
            092 188 149
            147 212 179
            201 234 214
            251 192 223
            248 129 191
            244 068 159
            ]/255;
        

    case 'f113'
        c.clev = [0.01 0.02 0:0.05:.25 .5 1:.5:5 ]/10; c.clev = unique(c.clev);
        cbound = [0.02 .25 0.5 1 2 8]/10;% no previous plots
        cols = [
            039 164 126 % AO_cfc11.cpt
            092 188 149
            147 212 179
            201 234 214
            251 192 223
            248 129 191
            244 068 159
            ]/255;
        
    case 'ccl4'
        c.clev = [0.01 0.02 0:0.05:.25 .5 1:.5:5 ]; c.clev = unique(c.clev);
        cbound = [0.02 .25 0.5 1 2 8];% no previous plots
        cols = [
            039 164 126 % AO_cfc12.cpt
            092 188 149
            147 212 179
            201 234 214
            251 192 223
            248 129 191
            244 068 159
            ]/255;
        
    case 'sf6'
        c.clev = [0 .01 .02 .05 .1:.05:.3 .2:.2:2 .7 ]; c.clev = unique(c.clev);
        cbound = [0.02 .25 0.5 1 2 8]/2;% no previous plots
        cols = [
            039 164 126 % AO_cfc12.cpt
            092 188 149
            147 212 179
            201 234 214
            251 192 223
            248 129 191
            244 068 159
            ]/255;

    otherwise
        fprintf(2,'%s\n','Must set a recognised parameter in set_clev_col');
        error('exit')
end

c.clev = unique([c.clev cbound]); % add colour boundaries to clevs if not already there
clev = c.clev;

cd = setdiff(cbound,clev);
if ~isempty(cd)
    fprintf(2,'%s\n','colour bounding contour levels must be a chosen contour')
    error('exit');
end

if length(cols) ~= length(cbound)+1
    fprintf(2,'%s\n','must define extactly one more colour than the number of colour boundaries')
    error('exit');
end

cbound = [-inf cbound inf];
ctab = [];

for kl = 1:length(cbound)-1
    k = find(clev > cbound(kl) & clev <= cbound(kl+1));
    nkl = length(k);
    if kl == length(cbound)-1; nkl = nkl+1; end
    ctab = [ctab; repmat(cols(kl,:),nkl,1)];
end
c.colortable = ctab;

return
