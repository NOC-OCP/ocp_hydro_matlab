function matlist = msnames
% function matlist = msnames
%
% approximate triplets of mexec short names, rvs streams and scs streams 
% for JR195
% If called with no output arguments, list is printed to terminal.
%
% entries are
% mexec short name; rvs name; scs name

% JC032. If you need to add lines, that is harmless. If you need a whole
% new set of correspondences, retain this list but comment it out, and add
% your new list.

m_common

matlist = cell(0);

if strncmp(MEXEC_G.Mshipdatasystem,'scs',3)

matlist = {
            'posfur'                  ' '                             'GPS-Furuno-GGA'
            'singleb'                 ' '                             'SingleBeam-Knudsen-PKEL99'
            'gyro'                    ' '                             'Gyro1-HDT'
            'sbe21'                    ' '                             'TSG1-SBE21'
            'sbe45'                    ' '                             'TSG2-SBE45'
            'dopplerlog'               ' '                             'SpeedLog-Furuno-VBW'
            'winch'                    ' '                             'Win1'
            'abxtwo'                   ' '                             'GNSS-ABXTWO-PASHR'
%            'ashtech'                  ' '                                'ashtech'
%         'furuno_gga'                  ' '                             'furuno-gga'
%         'furuno_gll'                  ' '                             'furuno-gll'
%         'furuno_rmc'                  ' '                             'furuno-rmc'
%         'furuno_vtg'                  ' '                             'furuno-vtg'
%         'furuno_zda'                  ' '                             'furuno-zda'
%            'glonass'                  ' '                                'glonass'
%             'gyro_s'                  ' '                                   'gyro'
%         'seatex_gga'                  ' '                             'seatex-gga'
%         'seatex_gll'                  ' '                             'seatex-gll'
%         'seatex_hdt'                  ' '                             'seatex-hdt'
% %        'seatex_psxn'                  ' '                            'seatex-psxn'  % format errors on seatex-psxn         
%         'seatex_vtg'                  ' '                             'seatex-vtg'
%         'seatex_zda'                  ' '                             'seatex-zda'
%             'tsshrp'                  ' '                                 'tsshrp'
%         'netmonitor'                  ' '                             'netmonitor'
%         'anemometer'                  ' '                             'anemometer'
% %        'surfmet'                  ' '                             'anemometer'
%         'dopplerlog'                  ' '                             'dopplerlog'
% %            'ea600m'                  ' '                                  'ea600'
%             'ea600'                  ' '                                  'ea600'
% %              'em120'                  ' '                                  'em120'
%              'em122'                  ' '                                  'em122'  % bak on jr281, em122 instead of em120
%          'emlog_vhw'                  ' '                              'emlog-vhw'
%          'emlog_vlw'                  ' '                              'emlog-vlw'
%        'oceanlogger'                  ' '                            'oceanlogger'
%             'seaspy'                  ' '                                 'seaspy'
%           'usbl_gga'                  ' '                               'usbl-gga' % added bak 27 march 2013 on jr281 for completeness. unlikely to be used
%              'winch'                  ' '                                  'winch'
%               'fake'                  ' '                                   'fake'    % for test purposes
             };

end

if nargout ==0
   fprintf(1,'\n%20s %20s %45s\n\n',['mexec short name'],['rvs stream name'],['    scs stream name']);
   for kstream = 1:size(matlist,1)
      fprintf(1,'%20s %20s %45s\n',['''' matlist{kstream,1} ''''],['''' matlist{kstream,2} ''''],['''' matlist{kstream,3} '''']);
   end
end