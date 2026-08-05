function m_set_data_time_origin(ncfile,yyyy,mo,dd,hh,mm,ss)

v = [yyyy mo dd hh mm ss];
nc_attput(ncfile.name,nc_global,'data_time_origin',v);
return
