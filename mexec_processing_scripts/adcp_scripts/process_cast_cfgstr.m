function [] = process_cast_cfgstr(stn,varargin)
% function [] = process_cast_cfgstr(stn[,cfg])
%
% Process LADCP cast, including GPS, SADCP, and BT data.
%
% Before a cast is processed, [ix_cast_params.m] is called, and sets
% cruise and/or cast-specific parameters based on inputs in structure cfg. 
% After a cast is processed, [post_process_cast.m] is called (if it exists)
% cruise- and/or cast-specific post-processing should be carried out there.
%
% possible fields of cfg: 
%
%    procver: a variable to be passed to set_cast_params.m
%
%    stop:  0 don't stop (default)
%           -1 stop before begin_step
%           1 stop after begin_step
%           2 stop after all steps
%
%    eval_expr is evaluated after loading the checkpoint, just before
%           processing starts; it can be used to override variables
%           saved in the checkpoint.
%
%  plus the fields of f and p listed in default.m
%
% LIST OF STEPS FOR begin_step:
%
%  1: LOAD LADCP DATA
%  2: FIX LADCP-DATA PROBLEMS
%  3: LOAD GPS DATA
%  4: GET BOTTOM-TRACK DATA
%  5: LOAD CTD PROFILE
%  6: LOAD CTD TIME SERIES
%  7: FIND SURFACE & SEA BED
%  8: APPLY PITCH/ROLL CORRECTIONS
%  9: EDIT DATA 
% 10: FORM SUPER ENSEMBLES
% 11: REMOVE SUPER-ENSEMBLE OUTLIERS
% 12: RE-FORM SUPER ENSEMBLES
% 13: (RE-)LOAD SADCP DATA
% 14: CALCULATE INVERSE SOLUTION
% 15: CALCULATE SHEAR SOLUTION
% 16: PLOT RESULTS & SHOW WARNINGS
% 17: SAVE OUTPUT

%======================================================================
%                    P R O C E S S _ C A S T . M 
%                    doc: Thu Jun 24 16:54:23 2004
%                    dlm: Wed Mar 29 12:57:24 2017
%                    (c) 2004 A.M. Thurnherr
%                    uE-Info: 90 39 NIL 0 0 72 0 2 8 NIL ofnI
%======================================================================

% NOTES:
%  - changing this function should not be required, except to fix bugs
%  - in order to preserve state variables across load/save calls in matlab,
%    they must be fields of the pcs structure

% HISTORY:
%  Jun 24, 2004: - created by combining laproc.m presolve.m resolve.m
%  Jun 25, 2004: - IMPROVEMENTS:
%			- save plots only if f.res defined
%			- add processing warnings to fig. 11
%  Jun 27, 2004: - removed the saving of processing structures
%		 - added 0 to debug_steps
%  Jun 28, 2004: - replaced debug_steps by stop parameter
%  Jul  2, 2004: - merged with [do_stn.m]
%  Jul  4, 2004: - added update_figures
%  Jul  9, 2004: - BUG: warnings were not shown if only pwarnp was set
%  Jul 16, 2004: - added support for fig. 14 (edit_data.m)
%  Jul 17, 2004: - changed getinv return params
%  Jul 18, 2004: - added eval_expr parameter
%  Jul 19, 2004: - changed [set_cast_params.m] from function to script
%  Jul 21, 2004: - made checkpoints user-selectable
%		 - made sure [set_cast_params.m] is executed after loading
%		   checkpoint
%  Jul 22, 2004: - changed [post_process_cast.m] from function to script
%		   to allow access to variables from [set_cast_params.m]
%  Jul 23, 2004: - moved all state variables to structure pcs.
%  Nov 23, 2004: - added handle wrapper to prevent printing of empty
%                  figures, which bombs on Matlab 7 R 14 (linux)
%  May 23, 2008: - added test after call to getdpthi() to make sure
%		   results are complete (current getdpthi does not work
%		   with CLIVAR P18 leg1 casts 46, 48, 49 & 50
%  Sep 18, 2008: - BUG: p.navdata was non-existent field when no nav
%			data were loaded
%  Apr 26, 2012: - finally removed finestructure kz code
%  Sep 26, 2014: - added support for p.orig in [saveres.m] (patch by Dan Torres)
%  May 12, 2015: - finally removed entire step 16 (diffusivity)
%  Jul 27, 2016: - added explicit .mat to checkpoints file to allow more
%		   complex filenames
%  Oct 14, 2016: - BUG: ctd_t, ctd_s were set after first pass, sometimes
%			causing inconsistent vector lengths
%  Mar 29, 2017: - added att and da to saveres
%	 	 - added saveplot_pdf
%		 - made fignums 2-digit
%  Jun 01, 2017: ylf change how inputs and settings are specified: add
%                optional input parameter-value pairs to be passed to  
%                ix_cast_params to specify different settings to use:
%                'orient' specifies downlooker ('DL', default), uplooker 
%                   ('UL'), or both ('DL_UL')
%                'constraints' is a cell array specifying whether to use 
%                   bottom tracking ({'BT'}), SADCP ({'SADCP'}), or both
%                   ({'BT', 'SADCP'})
%  Sep 15, 2018: - disabled serial-number code
%  Feb  8, 2019: - added pause before saving figures (TheThinMint requires this)
%  Feb 16, 2019: - move cast post-processing to step 17 so that post-processing
%		   is done before results are saved
%  Aug 30, 2019: - changed error message about p.getdepth
%  Sep  4, 2019: - replaced [getshear2.m] by GK's new [calc_shear3.m]
%
%  Feb ??, 2021: - epa added code to step 1 to combine multiple files in
%                  case instrument has split recording
%  Feb 20, 2023: - ylf added checking for files that are too short (not
%                  enough times or not enough good vertical velocities)
%                  after loading (rather than failing later)
%  Feb 20, 2023: - ylf added code after step 1 to optionally limit times
%                  (for yo-yo cast) 

%----------------------------------------------------------------------
% STEP 0: EXECUTE ALWAYS
%----------------------------------------------------------------------

%pcs structure defaults
pcs.begin_step = 1; %by default, start from scratch
pcs.stop = 0; %by default, no debug stops
pcs.eval_expr = ''; %by default, no variable overrides

%if specified, use cfg to set some parameters in pcs
if ~isempty(varargin)
   cfg = varargin{1};
   if isfield(cfg, 'begin_step'); pcs.begin_step = cfg.begin_step; end
   if isfield(cfg, 'stop'); pcs.stop = cfg.stop; end
   if isfield(cfg, 'eval_expr'); pcs.eval_expr = cfg.eval_expr; end
end

%defaults to pass to ix_cast_params in cfg
if ~exist('cfg','var') || ~isfield(cfg, 'orient')
    cfg.orient = 'DL';
end
if ~isfield(cfg, 'constraints')
    cfg.constraints = {'GPS'};
end

%defaults of f and p
clear f d dr p ps;                      % blank slate

f.ladcpdo = ' ';                        % required by [m/default.m]
default;                                % load default parameters

p = setdefv(p,'checkpoints',[]);        % disable checkpointing by default

%call ix_cast_params to set fields of f and p as specified, and create directories if needed
ix_cast_params %replaces set_cast_params

%close all
%openwindows_fewer;				% open all windows to be used

if length(f.res) > 1			% open log file
    if exist([f.res,'.log'],'file')==exist('loadrdi.m','file')
        eval(['delete ',f.res,'.log'])
    end
    diary([f.res,'.log'])
    diary on
end

disp(p.software);			% show version

if length(f.checkpoints) <= 1		% setup checkpointing
    error('Need to set f.checkpoints to write checkpoint files');
end
eval(sprintf('save %s_0.mat stn',f.checkpoints)); % sentinel

last_checkpoint = pcs.begin_step - 1;	% find last valid checkpoint
while ~exist(sprintf('%s_%d.mat',f.checkpoints,last_checkpoint),'file')
    last_checkpoint = last_checkpoint - 1;
end

pcs.target_begin_step = pcs.begin_step;	% backtrack to last valid checkpoint
if last_checkpoint >= 0 && pcs.begin_step > last_checkpoint+1
    fprintf(1,'Backtracking begin_step from %d to %d',pcs.begin_step,last_checkpoint+1);
    pcs.begin_step = last_checkpoint + 1;
end

while last_checkpoint < 100		% remove now-invalid checkpoints
    last_checkpoint = last_checkpoint + 1;
    if exist(sprintf('%s_%d.mat',f.checkpoints,last_checkpoint),'file')
        delete(sprintf('%s_%d.mat',f.checkpoints,last_checkpoint));
    end
end

tic;					% start timer

%pcs.step_name = 'INITIALIZATION';		% allow debugging of initial params
pcs.cur_step = 0; pcs.update_figures = [];
%end_processing_step;

%----------------------------------------------------------------------
% STEP 1: LOAD LADCP DATA
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
    pcs.step_name = 'LOAD LADCP DATA'; begin_processing_step_cfgstr;
    
    % LOAD RDI BB-raw data
    %  this is a rather complex set of functions
    %  1) load raw data
    %     apply magnetic deviation if given
    %  2) merge down-up data
    %  3) do some fist order error checks
    md = iscell(f.ladcpdo) && ~isempty(f.ladcpdo);
    mu = iscell(f.ladcpup) && ~isempty(f.ladcpup);
    if md && mu
        warning('not configured to process multiple down and multiple uplooker files together; skipping')
        return
    end
    if md || mu
        [d,f,p] = loadrdi_mult(f,p);
    else
        [d,p] = loadrdi(f,p);
    end

    if isfield(p,'time_start_force')
        %for separating out one yo from a yo-yo or tow-yo
        p.time_end = p.time_end_force;
        p.time_start = p.time_start_force;
        iit = find(d.time_jul>=julian(p.time_start) & d.time_jul<=julian(p.time_end));
        fn = fieldnames(d);
        for no = 1:length(fn)
            dat = d.(fn{no});
            s = size(dat);
            if s(1)==p.nt
                if s(1)==s(2)
                    error('cannot split cast %d; cannot tell which dimension is time',p.ladcp_station)
                end
                dat = dat(iit,:,:);
            elseif s(2)==p.nt
                dat = dat(:,iit,:);
            elseif numel(s)>2 && s(3)==p.nt
                dat = dat(:,:,iit);
            end
            d.(fn{no}) = dat;
        end
        p.nt = length(iit);
        %some stats in p like xmc, xmv, outlier_n are not recalculated per yo
    end

    if length(d.time_jul)<10
        warning('not enough data in %s or %s for cast %d; skipping',f.ladcpdo,f.ladcpup,p.ladcp_station)
        return
    end
    if sum(~isnan(d.rw(:)))==0
        warning('no valid vertical velocities in %s or %s for cast %d; skipping',f.ladcpdo,f.ladcpup,p.ladcp_station)
        return
    end

    % get instrument serial number
    %p=getserial(f,p);
    
    end_processing_step;
end % OF STEP 1: LOAD DATA


%----------------------------------------------------------------------
% STEP 2: FIX LADCP-DATA PROBLEMS
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'FIX LADCP-DATA PROBLEMS'; begin_processing_step_cfgstr;

  % fix problems with switched beams on instrument
  if existf(p,'beam_switch')==1, [d,p]=switchbeams(d,p); end

  % fix problems with a compass
  if p.fix_compass>0, [d,p]=fixcompass(d,p); end

  end_processing_step;
end % OF STEP 2: FIX LADCP-DATA PROBLEMS

%----------------------------------------------------------------------
% STEP 3: LOAD GPS DATA
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'LOAD GPS DATA'; begin_processing_step_cfgstr;

  p.navdata = 0;
  if length(f.nav)>1 && exist('loadnav.m','file')==exist('loadrdi.m','file')
    [d,p]=loadnav(f,d,p);
  else
    d.slon=NaN*d.time_jul; d.slat=d.slon;
  end

  end_processing_step;
end % OF STEP 3: LOAD GPS DATA

%----------------------------------------------------------------------
% STEP 4: GET BOTTOM-TRACK DATA
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'GET BOTTOM-TRACK DATA'; begin_processing_step_cfgstr;

  %  Check if hbot values are mostly ==0
  %
  %  some RDI instruments seem to have trouble reporting the distance of the bottom
  %  despite giving reasonable bottom track values.
  %  If this problem is diagnosed we make the distance ourselves.
  %
  ii1=sum(isfinite(d.hbot));
  ii0=sum(d.hbot==0);
  p.hbot_0=ii0/(ii1+1)*100;
  
  if p.hbot_0>80 
   p.bottomdist=1;
   disp([' WARNING found ',int2str(p.hbot_0),'% of  hbot=0  WARNING'])
  end
  
  [d,p]=getbtrack(d,p);  

  end_processing_step;
end % OF STEP 4: GET BOTTOM-TRACK DATA

%----------------------------------------------------------------------
% STEP 5: LOAD CTD PROFILE
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'LOAD CTD PROFILE'; begin_processing_step_cfgstr;

  %  get processed ctd profile data
  %  We provide more than one version to support different file formats
  % 
  if length(f.ctdprof)>1 && exist('loadctdprof.m','file')==exist('loadrdi.m','file')
    [d,p]=loadctdprof(f,d,p);
  end

  end_processing_step;
end % OF STEP 5: LOAD CTD PROFILE

%----------------------------------------------------------------------
% STEP 6: LOAD CTD TIME SERIES
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'LOAD CTD TIME SERIES'; begin_processing_step_cfgstr;

  %  get ctd time series data
  %  We provide more than one version to support different file formats
  % 
  if length(f.ctd)>1 && exist('loadctd','var')==exist('loadrdi','var')
    pcs.update_figures = [pcs.update_figures 4];
    [d,p]=loadctd(f,d,p);
    
  end
 
  end_processing_step;
end % OF STEP 6: LOAD CTD TIME SERIES

%----------------------------------------------------------------------
% STEP 7: FIND SURFACE & SEA BED (fig. 2)
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'FIND SURFACE & SEA BED'; begin_processing_step_cfgstr;
  pcs.update_figures = [pcs.update_figures 2];

  %  Find depth and bottom and surface using ADCP data 
  if p.getdepth==2
   [d,p]=getdpthi(d,p);
   if ~isempty(find(~isfinite(d.izm(1,:)), 1))
     error('Missing values in d.izm --- likely missing values in CTD file (processing with p.getdepth = 1; might work');
   end
  else
   [d,p]=getdpth(d,p);
  end

  % Plot a summary plot of the raw data
  figure(2), clf
  p=plotraw(d,p);
  pause(.01)
  
  end_processing_step;
end % OF STEP 7: FIND SURFACE & SEA BED

%----------------------------------------------------------------------
% STEP 8: APPLY PITCH/ROLL CORRECTIONS
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'APPLY PITCH/ROLL CORRECTIONS'; begin_processing_step_cfgstr;

  if length(p.tiltcor)>1
    pd.dpit=p.tiltcor(1);
    pd.drol=p.tiltcor(2);
    d=uvwrot(d,pd,1);
  end
  
  if length(p.tiltcor)>2
    pu.dpit=p.tiltcor(3);
    pu.drol=p.tiltcor(4);
    d=uvwrot(d,pu,0);
 end

 end_processing_step;
end % OF STEP 8: APPLY PITCH/ROLL CORRECTIONS

%----------------------------------------------------------------------
% STEP 9: EDIT DATA
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
   pcs.step_name = 'EDIT DATA'; begin_processing_step_cfgstr;
   pcs.update_figures = [pcs.update_figures 14];

   d = edit_data(d,p);

  end_processing_step;
end % OF STEP 9: EDIT DATA

%----------------------------------------------------------------------
% STEP 10: FORM SUPER ENSEMBLES
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
   pcs.step_name = 'FORM SUPER ENSEMBLES'; begin_processing_step_cfgstr;
   %pcs.update_figures = [pcs.update_figures 5 6 10]; %only have contents
   %if there is both up and downlooker (to compare), in which case they are
   %added to update_figures below the second time prepinv is called

   [di,p,d]=prepinv(d,p);

  end_processing_step;
end % OF STEP 10: FORM SUPER ENSEMBLES

%----------------------------------------------------------------------
% STEP 11: REMOVE SUPER-ENSEMBLE OUTLIERS
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'REMOVE SUPER-ENSEMBLE OUTLIERS'; begin_processing_step_cfgstr;

  % Reduce scatter by successively removing 1% of the data
  %  in oder to do that we need a first solution
  %
  if ps.outlier>0 || p.offsetup2down>0
     diary off
     if exist('loadsadcp.m','file')==exist('loadrdi.m','file') 
      [di,p]=loadsadcp(f,di,p);
     end
     dino=di;
     lanarrow
     diary on
  end

  end_processing_step;
end % OF STEP 11: REMOVE SUPER-ENSEMBLE OUTLIERS

%----------------------------------------------------------------------
% STEP 12: RE-FORM SUPER ENSEMBLES
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'RE-FORM SUPER ENSEMBLES'; begin_processing_step_cfgstr;

  %
  % once we have a first guess profile we recompute the super ensemble
  %
  if (p.offsetup2down>0 && ~isempty(d.izu))
   pcs.update_figures = [pcs.update_figures 5 6 10];
   diary off
   [di,p,d]=prepinv(d,p,dr);
   diary on
  end
  
  end_processing_step;
end % OF STEP 12: RE-FORM SUPER ENSEMBLES

%----------------------------------------------------------------------
% STEP 13: (RE-)LOAD SADCP DATA
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = '(RE-)LOAD SADCP DATA'; begin_processing_step_cfgstr;

  if exist('loadsadcp.m','file')==exist('loadrdi.m','file') && isfield(ps, 'sadcpfac') && ps.sadcpfac>0
    pcs.update_figures = [pcs.update_figures 9];
    di=loadsadcp(f,di,p);
  end
  
  end_processing_step;
end % OF STEP 13: (RE-)LOAD SADCP DATA

%----------------------------------------------------------------------
% STEP 14: CALCULATE INVERSE SOLUTION
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'CALCULATE INVERSE SOLUTION'; begin_processing_step_cfgstr;
  pcs.update_figures = [pcs.update_figures 3 7 12 14];
  if isfield(p,'btrk_used') && p.btrk_used>0
      pcs.update_figures = [pcs.update_figures 13];
  end
  
  % 
  %  take advantage of presolve if it existed
  %  call the main inversion routine
  %
  [p,dr,ps,de]=getinv(di,p,ps,dr,1);

  %
  % check inversion constraints
  % 
  p=checkinv(dr,di,de,der,p,ps);
  if existf(de,'bvel'), p=checkbtrk(d,di,de,dr,p); end

  end_processing_step;
end % OF STEP 14: CALCULATE INVERSE SOLUTION

%----------------------------------------------------------------------
% STEP 15: CALCULATE SHEAR SOLUTION
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'CALCULATE SHEAR SOLUTION'; begin_processing_step_cfgstr;

  % Compute 'old fashioned' shear based solution 
  %  two choices, fisrt us all data
  %  second use super ensemble data
  ps=setdefv(ps,'shear',1);
  
  if ps.shear>0
   if ps.shear==1
    [ds,dr,ps,p]=getshear2(d,p,ps,dr);
   else
    [ds,dr,ps,p]=getshear2(di,p,ps,dr);
   end
  end

  end_processing_step;
end % OF STEP 15: CALCULATE SHEAR SOLUTION

%----------------------------------------------------------------------
% STEP 16: PLOT RESULTS & SHOW WARNINGS
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'PLOT RESULTS & SHOW WARNINGS'; begin_processing_step_cfgstr;
  pcs.update_figures = [pcs.update_figures 1 11];

  % Plot final results
  figure(1), clf
  plotinv(dr,d,p,ps)
  
  % Convert p.warn to one line of text with newline characters
  p.warnings = [];
  for i = 1:size(p.warnp,1)
     p.warnings = [p.warnings deblank(p.warnp(i,:)) newline];
  end
  
  figure(11)
  clf
  % experimental diagnostic of battery voltage
  %
  p=battery(p);
  
  %
  % complete task by repeating the most important warnings
  %
  if size(p.warn,1) + size(p.warnp,1) > 2
   disp(p.warn)
   disp(' ')
   disp(p.warnp)
   for j=1:size(p.warn,1)
    text(0,1.1-j/10,p.warn(j,:),'color','r','fontsize',14,'fontweight','bold')
   end
   for j=1:size(p.warnp,1)
    text(0,1.1-(size(p.warn,1)+1+j)/10,p.warnp(j,:),'color','r','fontsize',14,'fontweight','bold')
   end
   axis off
  else
   text(0,1.1-1/10,'LADCP profile OK','color','g','fontsize',30,'fontweight','bold')
   axis off
  end
  
  streamer([p.name,' Figure 11']);
  pause(0.01)

  end_processing_step;
end % OF STEP 16: PLOT RESULTS & SHOW WARNINGS

%----------------------------------------------------------------------
% STEP 17: SAVE OUTPUT
%----------------------------------------------------------------------

pcs.cur_step = pcs.cur_step + 1;
if pcs.begin_step <= pcs.cur_step
  pcs.step_name = 'SAVE OUTPUT'; begin_processing_step_cfgstr;

  if existf(d,'ctdprof_p')
    dr.ctd_t=interp1q(d.ctdprof_z,d.ctdprof_t,dr.z);
    dr.ctd_s=interp1q(d.ctdprof_z,d.ctdprof_s,dr.z);
  end
  if existf(d,'ctdprof_ss')
    dr.ctd_ss=interp1q(d.ctdprof_z,d.ctdprof_ss,dr.z);
  end

if exist('post_process_cast','file')	% cruise-specific post-processing
  post_process_cast;
end

  if length(f.res)>1
  
    %
    % save results to ASCII, MATLAB and NETCD files
    %
    disp(' save results ')
    da=savearch(dr,d,p,ps,f,att);
    saveres(dr,p,ps,f,d,att,da)
  
    %
    % save plots
    %
    disp(' save plots ')
    for jj = intersect(p.saveplot,pcs.update_figures)
        fprintf('  figure %d...\n',jj);
        try
            h = get(jj);
        catch
            h = [];
        end
        if ~isempty(h)
            figure(jj); pause(1);
            eval(sprintf('print -f%d -dpsc %s_%02d.ps',jj,f.res,jj))
        end
    end
    for jj = intersect(p.saveplot_png,pcs.update_figures)  
        fprintf('  figure %d...\n',jj);
        try
            h = get(jj);
        catch
            h = [];
        end
        if ~isempty(h)
            figure(jj); pause(1);
            eval(sprintf('print -f%d -dpng %s_%02d.png',jj,f.res,jj))
        end
    end
    for jj = intersect(p.saveplot_pdf,pcs.update_figures)
        fprintf('  figure %d...\n',jj);
        try
            h = get(jj);
        catch
            h = [];
        end
        if ~isempty(h)
            figure(jj); pause(1);
            eval(sprintf('print -f%d -dpdf %s_%02d.pdf',jj,f.res,jj))
        end
    end

    disp(' save protocol ')
    % diary off
    diary off
  
    % save a protocol
    saveprot
  
  end
    
  end_processing_step;
end % OF STEP 17: SAVE OUTPUT

%----------------------------------------------------------------------
% FINAL STEP: CLEAN UP
%----------------------------------------------------------------------

fclose('all');				%  close all files just to make sure

disp(' ')				% final message
disp(['==> The whole task took ',int2str(toc),' seconds'])


