function model = smoke_model(cfg) %#ok<INUSD>
% Environment-only Laplace problem: -u_xx=0 on [0,1 m], u=x/(1 m)
% at both endpoints. Exact solution u=x/(1 m); no research physics is used.
% LaplaceEquation/DirichletBoundary types were checked by loading and
% exporting the installed 6.3 official Equation_Based/point_source example.
import com.comsol.model.util.*
model = ModelUtil.createUnique('CodexSmoke');
model.label('Codex environment smoke test only');
comp = model.component.create('smokeComponent',true);
geom = comp.geom.create('smokeGeometry',1);
geom.lengthUnit('m');
geom.create('unitInterval','Interval');
geom.feature('unitInterval').set('coord',[0 1]);
geom.run;
phys = comp.physics.create('smokeLaplace','LaplaceEquation','smokeGeometry');
bc = phys.create('endpointValues','DirichletBoundary',0);
bc.selection.all;
properties = mphgetproperties(bc);
assert(isfield(properties,'r'),'COMSOLSkill:UnexpectedAPI','Dirichlet r property was not found.');
bc.set('r','x/1[m]');
selection = mphgetselection(bc.selection);
assert(numel(selection.entities)==2,'COMSOLSkill:SelectionMismatch','Expected two endpoints.');
mesh = comp.mesh.create('smokeMesh');
mesh.autoMeshSize(5);
mesh.run;
model.study.create('smokeStudy');
model.study('smokeStudy').create('stationary','Stationary');
fprintf('SMOKE_MODEL_TAG=%s\n',char(model.tag));
end
