function actualDate = actualDate(year,decimal_day)
%
%  Function to create a datetime index from decimal day data
%  
%  Inputs:
%    year         - year to which decimal_day is referenced
%    decimal_day  - decimal day values 
%
%  Returns:
%    actualDate   - datetime in format dd-mm-yyyy hh:mm:ss
%
%  Adam Blaker (02/02/2026)
%

baseDate = datetime(year,1,1);
actualDate = baseDate + decimal_day;
