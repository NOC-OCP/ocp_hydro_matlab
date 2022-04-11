%======================================================================
%                    B E G I N _ P R O C E S S I N G _ S T E P . M 
%                    doc: Fri Jun 25 16:13:41 2004
%                    dlm: Wed Jul 27 14:03:04 2016
%                    (c) 2004 ladcp@
%                    uE-Info: 17 85 NIL 0 2 72 0 2 8 NIL ofnI
%======================================================================

% start new processing step (in [process_cast.m])

% HISTORY:
%   Jun 25, 2004: - created
%   Jun 26, 2008: - BUG: typo related to eval_expr
%   Apr 22, 2015: - added evaluation of eval_expr before re-loading set_cast_params.m
%		    to allow setting of processing_version
%   Feb 26, 2016: - added station number to begin-step message
%   Jul 27, 2016: - added .mat to checkpoint filename to allow more complex filenames

msg = sprintf('################ [%03d] step %d: %s ',stn,pcs.cur_step,pcs.step_name);
while length(msg)<70, msg = [msg '#']; end
disp(msg);
if pcs.cur_step == pcs.begin_step
  save_pcs = pcs; % save state
  disp(sprintf('LOADING CHECKPOINT %s_%d',f.checkpoints,pcs.cur_step-1));
  load(sprintf('%s_%d.mat',f.checkpoints,pcs.cur_step-1));
  if ~isempty(save_pcs.eval_expr)
    disp(sprintf('EVALUATING EXPRESSION <%s>...',save_pcs.eval_expr));
    eval(save_pcs.eval_expr);
  end
  disp('RE-LOADING PER-CAST PARAMETERS');
  set_cast_params_cfgstr;
  if ~isempty(save_pcs.eval_expr)
    disp(sprintf('RE-EVALUATING EXPRESSION <%s>...',save_pcs.eval_expr));
    eval(save_pcs.eval_expr);
  end
  pcs = save_pcs; % restore state
  clear save_pcs;
end
if pcs.stop < 0 & pcs.cur_step == pcs.target_begin_step
  pcs.stop = 0; % can be overridden interactively
  disp(sprintf('entering DEBUG mode BEFORE step %d (%s)',pcs.cur_step,pcs.step_name));
  disp(sprintf('(next stop = %d; type "return" to continue, "dbquit" to abort)',pcs.stop));
  keyboard;
  more off; % just in case...
end
last_toc = toc;
