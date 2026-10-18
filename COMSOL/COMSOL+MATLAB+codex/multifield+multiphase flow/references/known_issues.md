# 已验证经验与问题记录（发布版去标识摘要）

以下为首次本地验证的去标识摘要，不附原始私有日志或二进制模型；发布打包时未重新运行求解。只登记有真实证据的解决方案；尚未证实的原因标为 hypothesis。项目特定 boundary/domain 编号进项目知识库。新操作先检索 Error signature/Prevention rule，再按当前版本重核。

## ENV-001 — Windows 沙箱阻止 MATLAB 写预设目录

Date: 2026-10-18 Asia/Shanghai

COMSOL version: 6.3 build 290（后续连接实测）

MATLAB version: R2023b Update 9

Model: 无；只读环境探针

Simulation stage: MATLAB startup

### Symptom / Error signature

普通沙箱中启动 matlab.exe 立即退出：“无法访问预设项文件夹 <USER_PROFILE>/AppData/Roaming/MathWorks/MATLAB/R2023b。预设项文件夹必须可写。”

### Root cause

执行沙箱不允许 MATLAB 对现有用户预设目录的正常写入；尚未进入 MATLAB 代码，也未尝试 COMSOL 连接。

### Failed attempts / Incorrect approach

首次常规权限启动失败。未尝试重装、改许可证或改写全局 path；这些与报错层级不符。

### Correct solution

按照用户已授权的本机执行范围，经执行权限审核以提升权限启动已安装 MATLAB，使用现有配置；未手工修改预设文件。

### Verification

同一探针随后运行，输出 MATLAB 23.2.0.2668659 (R2023b) Update 9；连接探针进一步成功调用 mphversion。

### Applicable versions

首次验证时的 Windows 执行沙箱 + MATLAB R2023b；不是 COMSOL 特有错误。

### Prevention rule

先定位启动权限层级；按权限机制处理，不把沙箱问题误诊为 LiveLink/许可证损坏。若审核拒绝，应明确报告而非绕过。当前沙箱中的 CIM/进程查询也可能报不可访问或返回不完整结果；本次提升权限只读查询后才确认现有 server，不能因沙箱中查不到就重启用户环境。

## ENV-002 — 新 MATLAB batch 不继承交互 MATLAB 的 LiveLink 路径

Date: 2026-10-18 Asia/Shanghai

COMSOL version: 6.3 build 290

MATLAB version: R2023b Update 9

Model: 无；独立新进程

Simulation stage: API discovery / connection

### Symptom / Error message

`which('mphversion')` 与 `which('mphstart')` 均为空；“函数或变量 mphversion 无法识别。”

### Root cause

通过普通 matlab.exe -batch 启动的新进程没有交互 MATLAB 中的临时 mli path/Java 连接状态；现有 COMSOL server 本身正常且在 已核实的本机端口监听。

### Failed attempts / Incorrect approach

首次直接 mphversion 不可用。不能从该现象推断原有连接失效；也不能混用另一安装版本的 mli。

### Correct solution

读取现有 server 路径和端口后，仅在新进程执行 `addpath(fullfile(comsolRoot,'mli'))` 与 `mphstart(serverHost,serverPort,comsolRoot)`（变量取自已核实的当前环境）。此为官方文档支持的会话连接操作，没有 savepath/改 startup.m/重启 server。

### Verification

连接探针返回 `CONNECTION_STATUS=verified`，COMSOL 6.3 build 290，MATLAB R2023b Update 9，并成功只读查询 ModelUtil.tags。

### Applicable versions

本次 6.3/R2023b 同机独立 batch；未来确认实际路径/端口/版本。

### Prevention rule

区分安装可用、当前进程路径可见、当前进程已连接三种状态。优先复用已有连接，独立新进程只做局部路径和连接初始化。

## INIT-001 — 最小闭环与错误反馈验证（成功模式）

Date: 2026-10-18 Asia/Shanghai

COMSOL version: 6.3.0.290

MATLAB version: R2023b Update 9

Model: 独立 CodexSmoke 唯一 tag；1D [0,1 m] Laplace equation

Simulation stage: build → stationary solve → extraction → validation → save

### Source / Correct solution

API 来源：本机官方 `applications/COMSOL_Multiphysics/Equation_Based/point_source.mph`，以唯一 tag 只读加载，查询得到 `LaplaceEquation`、`DirichletBoundary`，导出 M-file 检查写法；几何 `Interval.coord`、边界 r、进度日志均核对 6.3 帮助。未直接执行官方导出的全量 M-file，避免默认 Model tag 替换。

新建明确 tag 的 1D 测试组件，端点 selection.all 后查询确为两个点；指定 u=x/(1 m)，解析解为 u=x/(1 m)，积分为 0.5 m。自动建网格，创建 stationary study 并运行，查询实际 solver/dataset 后提取。

### Verification

首轮实际运行：15 个一维网格单元，质量 1；31 个求解自由度及 2 个内部自由度。solver progress 含迭代、缩放、线性误差/残差和完成时间，模型节点 error/warning 数为 0。11 点最大绝对误差 `7.77e-16`，积分误差 `3.33e-16 m`，所有解 DOF 有限，L1/L2/L3 通过（阈值 absTol=relTol=1e-9，限定此测试）。

受控负例：提取阶段请求不存在的 `INTENTIONALLY_MISSING_NODE_FOR_ERROR_TEST` study。真实 COMSOL Java exception“未知研究”与 tag、完整 stack、stage=extract 被保存；wrapper 标记 failed 并保存 `failed_diagnostic.mph`。这证明 API 异常反馈通路，不等于测试过所有非线性收敛失败类型。

覆盖保护拒绝重复案例目录；validation 对 NaN、Inf、空数组、形状不符、缺少 evidence、没有 checks 均拒绝 allPassed。各次模型均使用独立唯一 tag，测试完成只移除测试模型，不关闭原有 server/MATLAB。

### Applicable versions / Prevention rule

仅实测 6.3/R2023b 同机、小型线性稳态问题。可复用的是闭环和证据组织方式，不是地质/多相/HM/THMC 的物理或 solver 结论。

## TOOL-001 — Skill validator 的 Python 缺少 PyYAML

Date: 2026-10-18 Asia/Shanghai

Simulation stage: Skill packaging / validation

### Error signature / Root cause

系统 Python 3.12.1 及桌面 bundled Python 执行 `quick_validate.py` 报 `ModuleNotFoundError: No module named 'yaml'`；validator 依赖的 PyYAML 未存在于这些解释器。

### Incorrect approach / Correct solution

无需联网安装或改系统包；换用本机已有 带 PyYAML 的既有 Python 解释器（开启 UTF-8 模式） 运行同一官方 validator。

### Verification / Prevention rule

返回 `Skill is valid!`。Python 是工具链条件，不是 COMSOL 故障。Windows 中文文档处理显式 UTF-8，避免默认控制台 GBK 在输出注册符号时抛 UnicodeEncodeError；无需改系统编码。

## 新问题记录模板

```text
## Issue ID — short error signature
Date:
COMSOL version:
MATLAB version:
Model / input identity:
Simulation stage / node / physics / study / solver:
Symptom / Error message:
Root cause (confirmed evidence or hypothesis):
Failed attempts / Incorrect approach:
Correct solution (physics changed? diagnostic or final?):
Verification (L1/L2/L3, logs, artifacts, tolerances):
Applicable versions / conditions:
Prevention rule:
```
