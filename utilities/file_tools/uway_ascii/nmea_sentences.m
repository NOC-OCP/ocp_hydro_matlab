function nmeas = nmea_sentences
% nmeas = nmea_sentences
% conventional and custom sentences divided into variable names and units
% (where possible) corresponding to columns produced by readtable with , as
% delimiter

nmeas.CR6 = {'msg',  'lat', 'lon',   'airtemp', 'airpress',      'sst', 'humidity',                    'winddir', 'windspdrounded', 'truewindspeed','junk1', 'shipheading',             'junk2',  'junk3', 'timestamp';
              ' ', 'degrees N', 'degrees E', 'degrees C',       'Pa', 'degrees C',   'unknown', 'degrees relative to true N',     'm/s',        'm/s',       'unknown', 'degrees relative to N', 'unknown', 'unknown',         ' '};

nmeas.DBS = {'msg', 'depthft', 'feet', 'depth_below_surface', 'metres', 'depthfa', 'fathomschecksum';
              ' ',       ' ',    ' ',                   'm',      ' ',       ' ',              ' '};

nmeas.DBT = {'msg', 'depthft', 'feet', 'depth_below_transducer', 'metres', 'depthfa', 'fathomschecksum';
              ' ',       ' ',    ' ',                      'm',      ' ',       ' ',               ' '};

nmeas.DPT = {'msg', 'depth_below_transducer', 'offset_relative_to_transducer', 'max_range_scale', 'checksum';
              ' ', 'm', 'm', ' ', ' '};

nmeas.HDG = {'msg',             'head',        'deviation', 'devdir (E/W)',        'variation', 'vardir (E/W)', 'checksum';
              ' ', 'degrees magnetic', 'degrees magnetic',           'ew', 'degrees magnetic',           'ew',        ' '};

nmeas.HDT = {'msg', 'head_true', 'checksum'; %THS replaces this?
              ' ',       'true',        ' '};

nmeas.GGA = {'msg', 'utctime', 'nslatitude', 'ns', 'ewlongitude', 'ew', 'ggaqual',   'sats',   'hdop', 'altitude', 'altval', 'geosep', 'geoval', 'dgpsage', 'dgpsref_checksum';
               ' ',       ' ',   'cdegrees', 'ns',    'cdegrees', 'ew',  'number', 'number', 'number',   ' ',      ' ',      ' ',      ' ',       ' ',                ' '};

nmeas.GLL = {'msg',   'nslatitude', 'ns',   'ewlongitude', 'ew',       'timeUTC', 'status (A valid V not valid)', 'checksum';
               ' ',  'dd mm, mmmm', 'ns', 'dddd mm, mmmm', 'ew', 'utc hhmmss.ss',                         'flag',        ' '};

nmeas.PAAI = {'msg', 'temp1', 'turbidity', 'temp2', 'cond', 'temp3', 'sspd', 'psal', 'dens', 'sys_press', 'temp4', 'oxy', 'a12', 'checksum';
                ' ',  'degrees C',  'ftu',  'degrees C',  'mS/cm',  'degrees C',  'm/s',  'psu',  'kg/m3',  'kPa',   'degrees C',   'uM/unknown',   ' ',        ' '};

nmeas.PASHR = {'msg', 'timestamp', 'head',       'T',    'roll',   'pitch', 'heave', 'roll_accuracy', 'pitch_accuracy', 'heading_accuracy',   'qual', 'alignment_status', 'checksum';
                ' ',         ' ', 'true',       'T', 'degrees', 'degrees',     'm',        'number',         'number',           'number', 'number',                ' ',        ' '};

nmeas.PSXN = {'msg', 'linetype',    'roll',   'pitch', 'heading', 'psxn_heave';
               ' ',        ' ', 'degrees', 'degrees', 'degrees', 'm_checksum'};

nmeas.ROT = {'msg', '  rate_of_turn', 'checksum';
               ' ', 'degrees/minute',        ' '};

nmeas.VHW = {'msg', 'heading_true', 'T',      'heading_mag', 'M', 'speed relative to water'; %VBW
               ' ',           'nm', ' ', 'degrees magnetic', ' ',                      'kt'};

nmeas.VTG = {'msg',         'tmg',  'T',             'tmgm', 'M', 'speedkt', 'N',     'sog', 'K', 'mode';% (A autonomous D differential E estimated M manual S simulator N not valid);
              ' ', 'degrees true',  ' ', 'degrees magnetic', ' ',      'kt', ' ', 'km/hour', ' ',    ' '};

nmeas.WIMWD = {'msg',      'winddir', 'T', 'm1', 'm2', 'windspd', 'N', 'm3', 'checksum';
                ' ', 'degrees true', ' ',  ' ',  ' ',     'm/s', ' ',  ' ',        ' '};

% nmeas.ZDA = {'msg', 'utc', 'day', 'month', 'year',  'tzoff', 'tzoff', 'checksum';
%               ' ',   ' ',   ' ',     ' ',    ' ',  'hours',  'mins',        ' '};

