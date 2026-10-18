---
name: comsol-with-matlab
license: Apache-2.0
description: Execute, inspect, diagnose, repair, validate, and document COMSOL Multiphysics simulations through LiveLink for MATLAB. Use for new or existing MPH and MATLAB models, especially porous media, multiphase flow, geomechanics, HM, THM, HMC, and THMC coupling.
---

# COMSOL with MATLAB 自动化科研

## 核心约定

- 默认已有可用的 COMSOL–MATLAB 连接。先读项目，必要时用 `mphversion` 做最小检查；不要重装、重配 LiveLink、修改许可证、保存 MATLAB path 或修改全局首选项。文档定位与版本基线见 [docs_index.md](references/docs_index.md)，以使用者实际环境为准，版本升级后重核。
- 默认直接执行：**inspect → implement → run → observe → diagnose → modify → rerun → validate**。权限、物理定义、许可证操作或原始数据破坏风险确实阻塞时，准确说明原因；不把自己能查、能跑的操作推给用户。
- **inspect first, modify second**：已有 MPH 的 component、geometry、physics、material、selection、study、solver、dataset、变量和实体 ID 必须先查，不能假定 `comp1/geom1/std1/sol1/dset1`。新建模型可明确创建固定 tag。加载和创建模型使用唯一 server tag，避免替换其他会话模型；不得 `ModelUtil.clear`。
- 未明确授权不得覆盖原始 MPH、MATLAB 程序或结果。保留 `models/baseline/`，改动写入 `models/generated/` 或独立案例目录；最小必要修改，不随意重写、删功能、重构。诊断模型单独保存，不能替代正式模型。
- **Numerical troubleshooting must not silently alter the intended physics.** 不得为了收敛擅改材料、孔隙率、渗透率、弹性模量、压力、流量、本构、毛细压力、耦合、边界、初值、相数、非线性或真实模拟时长。涉及这些选择，说明所需信息及其对结果的影响并与用户讨论。临时诊断简化须注明修改、理由、诊断身份、结论，并恢复正式问题。
- 不猜 API/property/solver 写法。按下述来源顺序核实当前版本；历史模式也须核对版本、模型结构和方程适用性。

## 知识来源顺序

1. 当前安装版本的官方帮助；2. LiveLink for MATLAB User's Guide；3. Programming Reference Manual；4. `mphdoc`/MATLAB 官方函数帮助；5. Desktop 验证成功后导出的 MATLAB M-file；6. 官方 Application Library；7. 官方 KB/论坛；8. 本 Skill 已验证经验；9. 其他资料。

文档与网络示例冲突时以安装版本为准。不要复制整本手册。查文档入口用 [docs_index.md](references/docs_index.md)；操作前检索相关 [known_issues.md](references/known_issues.md) 和已验证模式。

## 新项目与运行流程

1. 列目录，识别 `.mph/.m/.txt/.csv/.xlsx`、图像和说明；确定主程序、主模型、研究目的。先读现有项目，不直接另起无关模型。
2. 记录一次版本、工程路径、输入模型、输出目录。确认控制方程、参数来源、单位、符号、量纲、初始/边界条件、研究目标；可查到的先自行查。未知物理假设、本构、简化权限、研究路线或科研验收标准需要用户决定时尽早提出具体问题，同时继续不依赖该回答的工作。
3. 查询模型树和实际 selections，依次核对 Geometry → Selections → Materials → Physics → Initial conditions → Boundary conditions → Multiphysics → Mesh → Study → Solver。新增几何后重新验证实体选择。
4. 制定可追踪的最小修改，关键注释解释设置的原因。按项目需要组织 parameters/geometry/selections/materials/physics/BC/mesh/study/solver/postprocessing/validation，无需形式化大重构。
5. 执行程序并收集 MATLAB stdout/stderr、完整 exception/cause/stack、COMSOL 节点 error/warning、solver progress、求解信息、网格和关键数据。详见 [api_patterns.md](references/api_patterns.md)。
6. 失败先定位阶段、node、physics、study、solver、变量，再分类：代码/API/模型设置/初值或边界/材料/网格/非线性或时间步/物理/后处理。不要只改最后一行报错。合理范围内循环修复；每次记录假设、单项修改和证据。相同无效修复不重复；三次无进展或资源预算耗尽后重新评估并说明已确认、已排除、每次尝试、最可能原因和所需信息。
7. 数值调整遵循 [solver_patterns.md](references/solver_patterns.md)，必须记录修改、原因、效果及物理一致性。不得靠无依据放宽容差伪造收敛。求解成功不等于验证成功。
8. 完成三级验证，导出数据、关键图像、最终脚本和 MPH；记录 dataset/time/parameter/solution 选择与单位，参见 [postprocessing_patterns.md](references/postprocessing_patterns.md)。失败也保存复现信息。
9. 把有证据的解决方案和稳定成功模式写入本 Skill 或项目知识库。未验证推测不得标为已解决。

## 三级验证（缺证据应为 unknown，不自动 pass）

- **L1 代码/API**：脚本和 API 完成、预期模型树存在，无未处理异常。
- **L2 数值**：目标 study/solver 完成，解确实存在且属于本次运行；结合日志检查非线性、segregated/时间步收敛、初始化、奇异矩阵、步长回退、内存、严重 warning、网格质量及 NaN/Inf。输出时间点不是内部自适应时间步证据；解对象存在也不是收敛证明。
- **L3 物理**：单位、数量级、范围、初边值、守恒、对称性、单调性、极限解；按研究目标与理论、独立数值结果或实验对照。必要时做网格/时间步/容差敏感性。单个 smoke test 不能证明真实科研模型正确。
- 多孔/多相问题按方程检查 `porosity > 0`（常见还需 ≤1）、permeability/density/viscosity >0，`0≤S≤1`、相和约束、残余饱和度、毛细压力、相对渗透率、mobility、相压/通量、总质量和注入量；不要机械套用不适用的相变量或残余定义。
- 固体/HM/THM/HMC/THMC 检查位移、应变、有效/总应力、孔压、热/体积应变、拉压及变形符号约定、Biot 耦合、力/水/热边界和化学耦合；记录量纲和数量级。

## 复用脚本与案例组织

- `scripts/check_environment.m`：只读查询现有连接，不自行启动或重配。
- `scripts/run_model.m`：接收显式 case 配置，独立目录、diary/progress、分阶段反馈、保存新 MPH、JSON 结果；失败保留证据。
- `scripts/diagnose_model.m`：查询树，按配置选取 error/solver/mesh 诊断，诊断自身失败单独记录。
- `scripts/validate_results.m`：显式数值检查与 L1/L2/L3 判定；拒绝空、非有限、形状不符等伪成功。
- `templates/model_template.m`、`templates/case_config_template.m`：给实际项目定制；模板故意拒绝缺失的物理定义，不能把空模板当完成模型。
- `scripts/smoke_model.m`、`scripts/smoke_case.m`：专用环境测试，与科研模型无关；运行前读来源和测试范围。
- 执行入口、连接与验证示例见 [api_patterns.md](references/api_patterns.md)。脚本不自动调整物理或 solver；Agent 根据诊断决定最小修复后再次调用。

每个正式案例独立保存 `results/<case-id>/{model,data,figures,logs,diagnostics}`。至少包括最终源代码与配置、输入身份/关键参数/单位、版本、最终 MPH、数据、关键图、stdout/stderr、diary、solver progress、warning/exception 和说明。运行 wrapper 不代替外层进程日志与超时监管；不可无日志后台放任运行。

## 学习和维护

仅在当前用户授权范围内维护 **comsol-with-matlab Skill**；本发布包不代表其他用户已授权持久写入。每次有实际价值的成功修复，按 [known_issues.md](references/known_issues.md) 模板记录 Error signature、Root cause、Incorrect approach、Correct solution、Verification、COMSOL/MATLAB versions、Prevention rule。案例特定实体编号只进项目记录；经过验证且可泛化的规则才升级到本文件。稳定成功模式分别进入 API/solver/postprocessing reference，注明证据、适用版本、条件和限制。Skill 安装目录受权限限制时先在项目中准备补丁，再按当前权限机制安装，不假装已更新。不要把此授权扩展到其他 Codex memory、科研模型或全局软件配置。

## 较大任务汇报

按用户需要列出：任务、完成情况、修改内容、运行情况、Solver 情况、三级验证、输出文件、发现/已解决/仍存在的问题、新增经验。只摘关键证据，不堆正常日志；明确未验证的部分及自动闭环限制。
