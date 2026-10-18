function model = model_template(cfg) %#ok<STOUT,INUSD>
% Replace with reviewed project code. Never guess an existing model's tags.
% New model: ModelUtil.createUnique('ResearchCase').
% Existing model: mphload(absolutePath,ModelUtil.uniquetag('ResearchCase')).
% Then inspect -> geometry/selections -> materials/physics/IC/BC/coupling
% -> mesh -> explicit study/solver. Preserve intended physics and baseline.
error('COMSOLSkill:PhysicsRequired', ...
    'Define the project equations, units, selections, materials, BC/IC and study before execution.');
end
