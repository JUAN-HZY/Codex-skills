function cfg = case_config_template(projectRoot, uniqueCaseId)
% Copy into the project and adapt callbacks and explicitly inspected tags.
cfg = struct;
cfg.caseDir = fullfile(projectRoot,'results',uniqueCaseId);
cfg.inputModel = ''; % Explicit absolute baseline path if applicable.
cfg.parameters = struct; % Include values, units, sources and sign conventions.
cfg.sourceFiles = {[mfilename('fullpath') '.m']}; % Add all final program dependencies.
cfg.buildFcn = @model_template;
cfg.studyTag = ''; % Read from imported model, or explicitly create a new one.
cfg.extractFcn = @extract_required;
cfg.validateFcn = @validation_required;
end

function data = extract_required(model,cfg) %#ok<STOUT,INUSD>
error('COMSOLSkill:ExtractionRequired','Specify expressions, dataset, units, coordinates, times and parameter indices.');
end

function report = validation_required(model,data,runReport) %#ok<STOUT,INUSD>
error('COMSOLSkill:ValidationRequired','Provide explicit L1/L2/L3 evidence and scientific acceptance checks.');
end
