function fn = m_add_nc(fn)
% function fn = m_add_nc(fn)
%
% check to see whether fn already has a suffix of .nc; if not, add .nc

if length(fn) < 3 | ~strncmp('.nc',fn(end-2:end),3)
   fn = [fn '.nc'];
end

