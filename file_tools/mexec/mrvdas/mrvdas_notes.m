% Notes about rvdas
% 
% *****************************************
% 1 Feb 2021
% 
% altitude in posmv_pos_gpgga
% is missing the units metres
% 
% 
% *****************************************
% 1 Feb 2021
% 
% There are non-printing characters in the .json files
% eg posmv_pos-jc.json
% This line appears OK on a linux screen
% "name": "GGPGGK – Time, Position, Position Type, DOP values",
% 
% But it prodces this when displayed in matlab
% "GGPGGK â Time, Position, Position Type, DOP values"
% 
% linux od -c produces this
% 
% 0002600       "   n   a   m   e   "   :       "   G   G   P   G   G   K
% 0002620     342 200 223       T   i   m   e   ,       P   o   s   i   t
% 0002640   i   o   n   ,       P   o   s   i   t   i   o   n       T   y
% 0002660   p   e   ,       D   O   P       v   a   l   u   e   s   "   ,
% 
% and od -x produces
% 
% 0002600 2220 616e 656d 3a22 2220 4747 4750 4b47
% 0002620 e220 9380 5420 6d69 2c65 5020 736f 7469
% 0002640 6f69 2c6e 5020 736f 7469 6f69 206e 7954
% 0002660 6570 202c 4f44 2050 6176 756c 7365 2c22
% 
% The problem are the hex chars in row 2 of that fragment
% e2 93 80 
% octal 342 223 200
% which aren't conventional printing ascii chracters. The rest are ok
% 
% 
% *****************************************
% 1 Feb  2021
% 
% Most of the json file names are of the form 
% A_B-jc.json
% Some aren't. It would be really more satisfactory of they all had -jc.json in the filename.
% 
% 
% *****************************************
% 1 Feb 2021
% 
% seapath_pos-jc.json has
%  "sentencesNo": 9
%  
% But in fact it has 10 sentences
%
%
% *****************************************
% 1 Feb 2021
% 
% The UTctime in dps116_gps_gpgga seems to be integer seconds
% in rvdas, rather than SS.FFF
%
% *****************************************


 
 
 
 

