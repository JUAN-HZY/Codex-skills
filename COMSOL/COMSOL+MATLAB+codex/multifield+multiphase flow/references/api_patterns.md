# API 与执行模式

状态标签：**文档核对**与**实际执行验证**分开。初始化执行证据及限制见 `known_issues.md` 和首次验证记录。这里的接口针对 COMSOL 6.3 / MATLAB R2023b，换版本重核。

已实测的成功模式：唯一 tag 加载官方模型并导出核对 API；`smoke_model` 新建 1D Laplace 模型；`run_model` 完成求解/日志/提取/验证/另存；错误注入保存 COMSOL exception 与 failed diagnostic。`known_issues.md` 的 INIT-001 给出证据和适用范围。尚未实测的研究接口不可因这些成功模式自动视为可用。

## 连接：复用现有 server，不持久改配置

本次已实测：普通 batch 未继承交互会话的 mli path；仅测试进程内使用：

```matlab
% comsolRoot must be the verified installation matching the running server.
addpath(fullfile(comsolRoot,'mli'));
mphstart(serverHost,serverPort,comsolRoot);
info = check_environment(projectRoot,inputMph,caseDir);
assert(info.connected,info.error);
```

已有连接的会话先 `mphversion`，不要重复 mphstart；不要自动启动/杀死 server。新进程调用不会把已连接交互 MATLAB 的变量带进来。Windows MATLAB 初始化需写现有偏好目录，沙箱阻塞时按执行权限机制处理，不以重装或更改许可证“修复”。

## 进程执行与反馈

PowerShell 示例（替换成已审查的绝对入口和独立日志）：

```powershell
# Set these variables to reviewed paths in the current environment.
& $matlabExe -sd $projectWork -logfile $processLog -batch $reviewedEntry
```

使用工具的 stdout/stderr 捕获；外层为每次运行单独保留 process log、退出码和超时信息。`-logfile`/diary 不保证涵盖外部 server 的全部输出，必须另启 client progress 文件并查询模型 error nodes。wrapper 返回 report，外层必须把 `status~='validated'` 或 `validation.allPassed=false` 转成非零退出码；不能以 MATLAB 进程正常退出代替检查。

```matlab
r = run_model(cfg);
assert(strcmp(r.status,'validated'),'COMSOLSkill:CaseFailed','See case diagnostics.');
```

运行前指定时间/内存/核数预算；MATLAB 同步 study.run 无内置通用硬超时，使用外层进程监督。不要终止用户原有 MATLAB/server。若 server 忙，先判断其他客户端状态，不无限等待/抢占。

## 先查询，再加载或修改

```matlab
import com.comsol.model.util.*
tag = ModelUtil.uniquetag('Case');
model = mphload(absoluteBaseline,tag);
tree = diagnose_model(model);
% 新建模型使用 model = ModelUtil.createUnique('Case');
% 读取 tree.tree.componentDetails 后再选择 component/physics/mesh。
```

`mphload` 不查锁文件，同 tag 可替换已加载模型。不要默认 tag='Model'，不要 `ModelUtil.clear`，不得操作其他客户端模型。实体选择用 `mphgetselection`、`mphselectcoords` 或命名 selection 核实维度/非空/实体含义；几何改变后旧数字 ID 可能失效。

`mphtags(node)` 可读 tags/labels；`.tags` 是明确节点集合的另一入口。`mphgetproperties(node)` 帮助核实属性与允许值；`mphgetexpressions` 适用于实际存在的表达式节点，不能当成枚举所有解变量的万能函数。按任务选择诊断，不机械调用全部接口。

## 分层反馈

```matlab
ModelUtil.showProgress(fullfile(caseDir,'logs','solver_progress.log'));
model.study(inspectedStudyTag).run;
messages = mphshowerrors(model);
info = mphsolinfo(model,'soltag',inspectedSolverTag);
stats = mphmeshstats(model,inspectedMeshTag);
ModelUtil.showProgress(false);
```

- `showProgress(filename)` 记录客户端进度，日记记录 MATLAB 输出；用 onCleanup 释放本测试进程的 logging 设置。
- `mphshowerrors` 返回 N×3 cell：节点、消息、包含错误信息的树节点；保存可读文本。无消息不证明全部数值过程合格。
- `mphsolinfo` 文档 syntax 行出现过 `solname`，同页 property 表、示例以及实测应优先核对 `soltag`，不要盲抄冲突文字。
- `mphmeshstats` 看 `isempty/iscomplete/hasproblems/minquality/numelem`，质量阈值由模型决定；单个质量值不能代表所有物理精度。
- 完整 MATLAB exception 用 `getReport(ME,'extended','hyperlinks','off')`，含 cause/stack；保留发生 stage。诊断失败必须单独记录，不覆盖原始异常。
- `lastwarn` 只包含最后一条 MATLAB warning；完整 warning 依赖日志，不能宣称收集齐所有 warnings。诊断函数不替代 solver log 和物理核查。

## 安全保存与可复现

`run_model` 拒绝已存在案例目录，运行前复制源程序，输出 `computed.mph` 或 `failed_diagnostic.mph`；只对新目录写文件。保留输入绝对路径、版本和参数，重要项目另保存输入/源代码 SHA256 与 dependency manifest。服务器路径和客户端路径可能不同，远程运行必须明确文件归属；本次仅验证同机。

模板有明确拒绝占位的错误；只把完整 reviewed callbacks 传入 run_model。不得执行来历不明的启动动作、MATLAB 程序或反序列化对象。执行隔离测试须处于当前用户授权范围；分发此 Skill 不授予访问其他用户文件或会话的权限。
