function m_print_header(h)
% function m_print_header(h)
%
% print header h to screen

m_common
    
m_print_global_attributes(h);
m_print_varsummary(h);
m_print_comments(h);

disp(['File last updated : ' h.last_update_string ]);
disp(' ');
openflag = h.openflag;
if strcmp(openflag,'W')
    disp('This file has the openflag set to ''W''')
    disp(' ')
end

end
   