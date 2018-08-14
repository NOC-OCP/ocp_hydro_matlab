%======================================================================
%                    B E G I N _ P R O C E S S I N G _ S T E P . M 
%                    doc: Fri Jun 25 16:13:41 2004
%                    dlm: Thu Jun 26 13:47:02 2008
%                    (c) 2004 ladcp@
%                    uE-Info: 13 50 NIL 0 0 72 2 2 8 NIL ofnI
%======================================================================

% start new processing step (in [process_cast.m])

% HISTORY:
%   Jun 25, 2004: - created
%   Jun 26, 2008: - BUG: typo related to eval_expr

msg = sprintf('#################### step %d: %s ',pcs.cur_step,pcs.step_name);
while length(msg)<70, msg = [msg '#']; end
disp(msg);
if pcs.cur_step == pcs.begin_step
  save_pcs = pcs; % save state
  disp(sprintf('LOADING CHECKPOINT %s_%d',f.checkpoints,pcs.cur_step-1));
  load(sprintf('%s_%d',f.checkpoints,pcs.cur_step-1));
  disp('RE-LOADING PER-CAST PARAMETERS');
  set_cast_noinv_params_cfgstr
  if ~isempty(save_pcs.eval_expr)
    disp(sprintf('EVALUATING EXPRESSION <%s>...',save_pcs.eval_expr));
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
