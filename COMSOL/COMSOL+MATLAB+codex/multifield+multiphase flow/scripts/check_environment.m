function info = check_environment(projectPath, modelFile, outputDir)
% Read-only: use an already connected MATLAB session. No setup or savepath.
if nargin < 1, projectPath = pwd; end
if nargin < 2, modelFile = ''; end
if nargin < 3, outputDir = ''; end
info = struct('checkedAt',char(datetime('now','TimeZone','Asia/Shanghai', ...
    'Format','yyyy-MM-dd''T''HH:mm:ssXXX')), ...
    'matlabVersion',version,'matlabRelease',version('-release'), ...
    'projectPath',char(projectPath),'inputModel',char(modelFile), ...
    'outputDir',char(outputDir),'mphversionPath',which('mphversion'), ...
    'connected',false,'comsolVersion','','error','');
try
    info.comsolVersion = mphversion;
    % mphversion alone is supplemented with a read-only server round trip.
    info.serverModelTags = cell(com.comsol.model.util.ModelUtil.tags);
    info.connected = true;
catch ME
    info.error = getReport(ME,'extended','hyperlinks','off');
end
if nargout == 0, disp(info); end
end
