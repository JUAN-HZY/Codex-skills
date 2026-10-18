function out = diagnose_model(model, options)
% Query actual tags. Optional expensive diagnostics are selected explicitly.
if nargin < 2, options = struct; end
out = struct('tree',struct,'queryFailures',{{}});
try
    out.tree.components = cell(model.component.tags);
    out.tree.studies = cell(model.study.tags);
    out.tree.solvers = cell(model.sol.tags);
    out.tree.datasets = cell(model.result.dataset.tags);
    for k = 1:numel(out.tree.components)
        tag = out.tree.components{k};
        c = model.component(tag);
        out.tree.componentDetails(k) = struct('tag',tag, ...
            'geometries',{cell(c.geom.tags)},'physics',{cell(c.physics.tags)}, ...
            'materials',{cell(c.material.tags)},'meshes',{cell(c.mesh.tags)}, ...
            'selections',{cell(c.selection.tags)});
    end
catch ME
    out.queryFailures{end+1} = getReport(ME,'extended','hyperlinks','off');
end
if isfield(options,'errors') && options.errors
    try
        % evalc preserves human-readable node messages; list can contain Java objects.
        out.nodeMessagesText = evalc('nodeMessages = mphshowerrors(model); disp(nodeMessages);');
        out.nodeMessageCount = size(nodeMessages,1);
    catch ME
        out.queryFailures{end+1} = getReport(ME,'extended','hyperlinks','off');
    end
end
if isfield(options,'solverTags')
    out.solutions = cell(1,numel(options.solverTags));
    for k = 1:numel(options.solverTags)
        try
            out.solutions{k} = mphsolinfo(model,'soltag',options.solverTags{k});
        catch ME
            out.queryFailures{end+1} = getReport(ME,'extended','hyperlinks','off');
        end
    end
end
if isfield(options,'meshTags')
    out.meshes = cell(1,numel(options.meshTags));
    for k = 1:numel(options.meshTags)
        try
            out.meshes{k} = mphmeshstats(model,options.meshTags{k});
        catch ME
            out.queryFailures{end+1} = getReport(ME,'extended','hyperlinks','off');
        end
    end
end
end
