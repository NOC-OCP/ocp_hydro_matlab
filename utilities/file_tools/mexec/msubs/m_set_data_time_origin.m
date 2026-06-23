function m_set_data_time_origin(ncfile,yyyy,mo,dd,hh,mm,ss)

% % % % % % Set the data time origin variable relative to the mstar_time_origin
% % % % % tref = nc_attget(ncfile.name,nc_global,'mstar_time_origin'); % This is the reference time for mstar data time origin and file update, stored as a recognisable 6 element vector
% % % % % 
% % % % % torg = datenum(tref);
% % % % % 
% % % % % tnew = datenum(yyyy,mo,dd,hh,mm,ss);
% % % % % 
% % % % % nc_varput(ncfile.name,'data_time_origin',tnew-torg); 
% % % % % m_uprlwr(ncfile,'data_time_origin');

v = [yyyy mo dd hh mm ss];
nc_attput(ncfile.name,nc_global,'data_time_origin',v);
return
