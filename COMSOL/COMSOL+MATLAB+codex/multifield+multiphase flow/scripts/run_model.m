function report = run_model(cfg)
% Execute a reviewed case in a NEW directory; never overwrite a baseline.
% cfg: caseDir, sourceFiles, buildFcn, studyTag, extractFcn, validateFcn,
%      parameters, inputModel (optional). Callbacks are reviewed trusted code.
required = {'caseDir','sourceFiles','buildFcn','studyTag','extractFcn','validateFcn','parameters'};
assert(all(isfield(cfg,required)),'COMSOLSkill:InvalidConfig','Incomplete case configuration.');
assert(isa(cfg.buildFcn,'function_handle') && isa(cfg.extractFcn,'function_handle') ...
    && isa(cfg.validateFcn,'function_handle'),'COMSOLSkill:InvalidCallback','Use reviewed function handles.');
caseDir = char(cfg.caseDir);
assert(~isfolder(caseDir) && ~isfile(caseDir),'COMSOLSkill:OutputExists', ...
    'Case directory already exists. Choose a new case ID.');
[ok,msg] = mkdir(caseDir); assert(ok,'COMSOLSkill:CreateDirectory','%s',msg);
dirs = {'model','data','figures','logs','diagnostics','source'};
for k=1:numel(dirs), mkdir(fullfile(caseDir,dirs{k})); end
diary(fullfile(caseDir,'logs','matlab_diary.log'));
diaryGuard = onCleanup(@() diary('off'));
report = struct('status','running','stage','provenance','caseDir',caseDir, ...
    'startedAt',char(datetime('now','TimeZone','Asia/Shanghai','Format','yyyy-MM-dd''T''HH:mm:ssXXX')), ...
    'solverCompleted',false,'parameters',cfg.parameters);
model = [];
try
    for k=1:numel(cfg.sourceFiles)
        [~,n,e] = fileparts(cfg.sourceFiles{k});
        dest = fullfile(caseDir,'source',[n e]);
        assert(~isfile(dest),'COMSOLSkill:SourceCollision','Duplicate source basename: %s',dest);
        copyfile(cfg.sourceFiles{k},dest);
    end
    inputModel = ''; if isfield(cfg,'inputModel'), inputModel = cfg.inputModel; end
    report.environment = check_environment(pwd,inputModel,caseDir);
    assert(report.environment.connected,'COMSOLSkill:NotConnected','%s',report.environment.error);
    report.stage = 'build'; model = cfg.buildFcn(cfg);
    report.serverModelTag = char(model.tag);
    report.before = diagnose_model(model);
    assert(ismember(cfg.studyTag,report.before.tree.studies), ...
        'COMSOLSkill:MissingStudy','Configured study is absent: %s',cfg.studyTag);
    report.stage = 'solver';
    % Progress is client-side. Always restore off in this dedicated batch session.
    com.comsol.model.util.ModelUtil.showProgress(fullfile(caseDir,'logs','solver_progress.log'));
    progressGuard = onCleanup(@() com.comsol.model.util.ModelUtil.showProgress(false));
    lastwarn(''); model.study(cfg.studyTag).run;
    report.solverCompleted = true;
    [report.lastMatlabWarning,report.lastMatlabWarningId] = lastwarn;
    report.stage = 'diagnose';
    options = struct('errors',true,'solverTags',{cell(model.sol.tags)});
    report.after = diagnose_model(model,options);
    report.stage = 'extract';
    data = cfg.extractFcn(model,cfg);
    save(fullfile(caseDir,'data','results.mat'),'data','-v7');
    write_json(fullfile(caseDir,'data','results.json'),data);
    report.stage = 'validate';
    report.validation = cfg.validateFcn(model,data,report);
    report.stage = 'save';
    target = fullfile(caseDir,'model','computed.mph');
    assert(~isfile(target),'COMSOLSkill:OutputExists','Model output already exists.');
    mphsave(model,target);
    report.modelFile = target;
    % A saved solution that fails validation stays explicitly unvalidated.
    if report.validation.allPassed, report.status='validated';
    else, report.status='computed_unvalidated'; end
    report.stage = 'finished';
catch ME
    report.status = 'failed';
    report.exception = struct('identifier',ME.identifier,'message',ME.message, ...
        'stack',ME.stack,'extended',getReport(ME,'extended','hyperlinks','off'));
    fprintf(2,'%s\n',report.exception.extended);
    if ~isempty(model)
        report.failureDiagnostics = diagnose_model(model,struct('errors',true));
        try
            mphsave(model,fullfile(caseDir,'model','failed_diagnostic.mph'));
        catch saveError
            report.failureSaveError = getReport(saveError,'extended','hyperlinks','off');
        end
    end
end
report.finishedAt = char(datetime('now','TimeZone','Asia/Shanghai','Format','yyyy-MM-dd''T''HH:mm:ssXXX'));
save(fullfile(caseDir,'diagnostics','report.mat'),'report','-v7');
write_json(fullfile(caseDir,'diagnostics','report.json'),report);
fprintf('CASE_STATUS=%s\nCASE_DIR=%s\n',report.status,caseDir);
end

function write_json(path,value)
[fid,msg] = fopen(path,'w','n','UTF-8');
assert(fid>=0,'COMSOLSkill:WriteFailed','%s',msg);
guard = onCleanup(@() fclose(fid));
fprintf(fid,'%s',jsonencode(value,'PrettyPrint',true));
end
