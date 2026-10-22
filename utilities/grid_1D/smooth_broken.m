function data = smooth_broken(data)
%
% smooth a broken time series, extending the smoothed series across the
% breaks
%
% e.g. for TSG data with breaks where system was off for cleaning, ***