function report = validate_results(checks, evidence)
% Checks: name, level (2/3), actual, expected, absTol, relTol.
% All values/shape/tolerances must be explicit. Unknown never becomes pass.
if nargin < 2, evidence = struct; end
report = struct('level1','unknown','level2','unknown','level3','unknown', ...
    'checks',{{}},'allPassed',false);
if isfield(evidence,'apiCompleted')
    report.level1 = verdict(isequal(evidence.apiCompleted,true));
end
levels = zeros(1,numel(checks)); passed = false(1,numel(checks));
for k = 1:numel(checks)
    q = checks(k);
    required = {'name','level','actual','expected','absTol','relTol'};
    assert(all(isfield(q,required)),'COMSOLSkill:InvalidCheck','Incomplete check.');
    assert(ismember(q.level,[2 3]) && isscalar(q.level), ...
        'COMSOLSkill:InvalidLevel','Check level must be 2 or 3.');
    assert(isnumeric(q.absTol) && isscalar(q.absTol) && isfinite(q.absTol) && q.absTol>=0 ...
        && isnumeric(q.relTol) && isscalar(q.relTol) && isfinite(q.relTol) && q.relTol>=0, ...
        'COMSOLSkill:InvalidTolerance','Tolerances must be finite nonnegative scalars.');
    sameShape = isequal(size(q.actual),size(q.expected));
    finite = isnumeric(q.actual) && isnumeric(q.expected) && ~isempty(q.actual) ...
        && all(isfinite(q.actual(:))) && all(isfinite(q.expected(:)));
    err = Inf;
    if sameShape && finite
        delta = abs(q.actual-q.expected);
        bound = q.absTol+q.relTol.*abs(q.expected);
        passed(k) = all(delta(:)<=bound(:));
        err = max(delta(:));
    end
    levels(k) = q.level;
    report.checks{k} = struct('name',q.name,'level',q.level,'passed',passed(k), ...
        'sameShape',sameShape,'finite',finite,'maxAbsError',err, ...
        'absTol',q.absTol,'relTol',q.relTol);
end
if isfield(evidence,'solverCompleted') && isfield(evidence,'numericsReviewed')
    if ~isequal(evidence.solverCompleted,true) || ~isequal(evidence.numericsReviewed,true)
        report.level2 = 'fail';
    elseif any(levels==2)
        report.level2 = verdict(all(passed(levels==2)));
    end
end
if isfield(evidence,'physicsReviewed')
    if ~isequal(evidence.physicsReviewed,true)
        report.level3 = 'fail';
    elseif any(levels==3)
        report.level3 = verdict(all(passed(levels==3)));
    end
end
report.allPassed = strcmp(report.level1,'pass') && strcmp(report.level2,'pass') ...
    && strcmp(report.level3,'pass');
end

function text = verdict(ok)
if ok, text = 'pass'; else, text = 'fail'; end
end
