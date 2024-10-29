%======================================================================
%          I X_ C A S T _ P A R A M S . M 
%                    doc: Mon Oct 30 23:25:48 2006
%                    dlm: Fri Aug 19 13:50:14 2011
%                    (c) 2006 ladder@
%                    uE-Info: 9 22 NIL 0 0 72 0 2 4 NIL ofnI
%
%   YLF Sep 2017 based on set_cast_params.m
%   selects options using cfg passed through from
%   process_cast_cfgstr
%
% required fields: 
% stnstr (string station number/name)
% pdir_root (root of processing directory, e.g. data/ladcp/ix
% rawdir (location of raw files)
% orient ('DL', 'UL', or 'DLUL')
% constraints (cell array list of one or more of 'GPS', 'BT', 'SADCP')
% f, structure containing information on nav/ctd file and (if used)
%   sadcp file
%
% optional fields:
% p, structure containing processing parameters (otherwise set by default)
%   as well as cruise_id, whoami, ladcp_station
%
%======================================================================

cd(cfg.pdir_root)

%set directories
if strcmp(cfg.orient, 'DL')
    isdo = 1; isup = 0;
elseif strcmp(cfg.orient, 'UL')
    isdo = 0; isup = 1;
elseif strcmp(cfg.orient, 'DLUL') || strcmp(cfg.orient, 'ULDL')
    isdo = 1; isup = 1;
else
   error('orientation must be one of: DL, UL, DLUL, or ULDL')
end

%enable (or not) SADCP and/or bottom tracking constraints,
%and set up output directories accordingly
ps.botfac = 0; ps.sadcpfac = 0;
if isempty(cfg.constraints)
   subdir = [cfg.orient '_SHR']; %***not sure this will work--what happens if f.ctd is not set?
else
   subdir = [cfg.orient cell2mat(cellfun(@(x) ['_' x],cfg.constraints,'UniformOutput',false))];
   if sum(strcmp(cfg.constraints, 'BT')); ps.botfac = 1; end
   if sum(strcmp(cfg.constraints, 'SADCP')); ps.sadcpfac = 1; end
end
subdir = fullfile(cfg.pdir_root, subdir, 'processed');
if ps.sadcpfac && isfield(cfg, 'SADCP_inst')
   subdir = [subdir '_' cfg.SADCP_inst];
end
if ~exist(subdir, 'dir')
   mkdir(subdir); mfixperms(subdir, 'dir');
end

%transfer from cfg (but some fields of f and p may already have been set by
%setdefv)
fn = fieldnames(cfg.f);
for no = 1:length(fn); f.(fn{no}) = cfg.f.(fn{no}); end
fn = fieldnames(cfg.p);
for no = 1:length(fn); p.(fn{no}) = cfg.p.(fn{no}); end

if ~exist(f.ctd,'file')
    f.ctd = ' ';
end
if ~exist(f.sadcp,'file')
    f.sadcp = ' ';
end

%find files and set f.ladcpdo and f.ladcpup (if applicable)
%this code allows for the possiblity of multiple files
f.ladcpdo = {}; f.ladcpup = {};
if isdo
   d = dir(fullfile(cfg.rawdir, cfg.dnpat));
   n = 1;
   while ~isempty(d)
      if d(1).bytes>1024
          f.ladcpdo{n} = fullfile(cfg.rawdir, d(1).name);
          n = n+1;
      end
      d(1) = [];
   end
end
if isup
   d = dir(fullfile(cfg.rawdir, cfg.uppat));
   n = 1;
   while ~isempty(d)
      if d(1).bytes>1024
          f.ladcpup{n} = fullfile(cfg.rawdir, d(1).name);
          n = n+1;
      end
      d(1) = [];
   end
end
if isempty(f.ladcpdo) && isempty(f.ladcpup)
    error('no down or up files found')
end
if length(f.ladcpdo)==1
    f.ladcpdo = f.ladcpdo{1};
end
if length(f.ladcpup)==1
    f.ladcpup = f.ladcpup{1};
end
if isdo && ~isup % downlooker only
   f.ladcpup = ' ';
elseif ~isdo && isup % uplooker only, put it in ladcpdo as required by code
   f.ladcpdo = f.ladcpup;
   f.ladcpup = ' ';
end

if ~isfield(f,'res') || length(f.res)<=1
    f.res = fullfile(subdir, sprintf('%03d',p.ladcp_station));
end
if ~isfield(f,'checkpoints')
    f.checkpoints = fullfile(cfg.pdir_root, 'checkpoints', sprintf('%03d',p.ladcp_station));
end

%======================================================================

[s,~,~] = fileparts(subdir); [~,s,~] = fileparts(s);
p.name = sprintf('%s cast #%d (processing version %s)',p.cruise_id,p.ladcp_station,s);

p.saveplot = [];
p.saveplot_png = [];
if ~isfield(p,'saveplot_pdf') || isempty(p.saveplot_pdf)
    p.saveplot_pdf	= [1:7 10:14];
    if isfield(f,'sadcp')
        p.saveplot_pdf = [p.saveplot_pdf 9]; 
    end
    if strcmp(cfg.orient,'DL') || strcmp(cfg.orient,'UL')
        p.saveplot_pdf = setdiff(p.saveplot_pdf,[8 10]);
    end
end
