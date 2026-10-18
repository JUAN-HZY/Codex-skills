function cfg = smoke_case(caseDir)
% Isolated exact-solution test. Not a porous-media or THMC benchmark.
here = fileparts(mfilename('fullpath'));
cfg = struct('caseDir',char(caseDir),'inputModel','', ...
    'parameters',struct('length_m',1,'equation','-u_xx = 0', ...
    'boundary','u=x/1[m] at both endpoints','expected','u=x/1[m]'), ...
    'sourceFiles',{{fullfile(here,'smoke_case.m'),fullfile(here,'smoke_model.m'), ...
    fullfile(here,'run_model.m'),fullfile(here,'check_environment.m'), ...
    fullfile(here,'diagnose_model.m'),fullfile(here,'validate_results.m')}}, ...
    'buildFcn',@smoke_model,'studyTag','smokeStudy', ...
    'extractFcn',@extract_smoke,'validateFcn',@validate_smoke);
end

function data = extract_smoke(model,cfg)
datasets = cell(model.result.dataset.tags);
assert(numel(datasets)==1,'COMSOLSkill:DatasetAmbiguous','Inspect multiple datasets before choosing.');
data.dataset = datasets{1};
data.x_m = linspace(0,1,11);
[data.u,data.unit] = mphinterp(model,'u','coord',data.x_m, ...
    'dataset',data.dataset,'solnum',1,'matherr','on');
[data.integral,data.integralUnit] = mphint2(model,'u','line', ...
    'dataset',data.dataset,'solnum',1);
data.mesh = mphmeshstats(model,'smokeMesh');
data.solvers = cell(model.sol.tags);
data.solution = mphsolinfo(model,'soltag',data.solvers{1});
data.dofValues = mphgetu(model,'soltag',data.solvers{1});
data.selection = mphgetselection(model.component('smokeComponent').physics('smokeLaplace').feature('endpointValues').selection);
writetable(table(data.x_m(:),data.u(:),'VariableNames',{'x_m','u_dimensionless'}), ...
    fullfile(cfg.caseDir,'data','profile.csv'));
fig = figure('Visible','off'); guard=onCleanup(@() close(fig));
plot(data.x_m,data.u,'o-',data.x_m,data.x_m,'--');
xlabel('x (m)'); ylabel('u (dimensionless)');
legend('COMSOL','Exact u=x/(1 m)','Location','best'); grid on;
title('Environment smoke test: 1D Laplace equation');
exportgraphics(fig,fullfile(cfg.caseDir,'figures','exact_solution.png'),'Resolution',150);
end

function report = validate_smoke(model,data,runReport)
q = struct('name','','level',2,'actual',[],'expected',[],'absTol',1e-9,'relTol',1e-9);
checks = repmat(q,1,5);
checks(1).name='All solution DOFs finite';
checks(1).actual=all(isfinite(data.dofValues(:))) && ~isempty(data.dofValues);
checks(1).actual=double(checks(1).actual); checks(1).expected=1;
checks(2).name='Mesh complete without reported problems';
checks(2).actual=double(data.mesh.iscomplete && ~data.mesh.isempty && ~data.mesh.hasproblems);
checks(2).expected=1;
checks(3).name='Analytic profile'; checks(3).level=3;
checks(3).actual=data.u; checks(3).expected=data.x_m;
checks(4).name='Integral equals 0.5 m'; checks(4).level=3;
checks(4).actual=data.integral; checks(4).expected=0.5;
checks(5).name='Two endpoint selections'; checks(5).level=3;
checks(5).actual=numel(data.selection.entities); checks(5).expected=2;
messages = mphshowerrors(model);
progressFile = fullfile(runReport.caseDir,'logs','solver_progress.log');
hasProgress = isfile(progressFile) && dir(progressFile).bytes>0;
evidence = struct('apiCompleted',true,'solverCompleted',runReport.solverCompleted, ...
    'numericsReviewed',isempty(messages) && hasProgress && isempty(runReport.after.queryFailures) ...
        && ~isempty(data.dofValues) && data.solution.size>0, ...
    'physicsReviewed',strcmp(data.unit{1},'1') && strcmp(data.integralUnit{1},'m'));
report = validate_results(checks,evidence);
report.scope = 'Environment-only stationary linear Laplace test; not validation of research physics.';
report.progressCaptured = hasProgress;
report.nodeMessageCount = size(messages,1);
report.units = struct('u',{data.unit},'integral',{data.integralUnit});
end
