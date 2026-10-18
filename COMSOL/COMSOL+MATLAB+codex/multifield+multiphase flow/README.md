# COMSOL with MATLAB Skill

面向 **Codex + COMSOL Multiphysics + LiveLink for MATLAB** 的自动化仿真 Skill。支持读取模型、执行程序、获取反馈、诊断修复、重新运行、三级验证及经验积累，适用于多孔介质、多相流、岩土工程及 HM / THM / HMC / THMC 工作流。

**默认已有正常工作的 COMSOL–MATLAB 连接。** 本仓库不负责重装或重新配置 LiveLink，也不附带 MATLAB、COMSOL、许可证、官方手册或科研模型。

## 核心原则

- 先查询已有模型树、tag 和 selection，再修改。
- 直接执行并根据实际反馈迭代，不停留在代码生成。
- 不覆盖原始 MPH、MATLAB 程序或已有结果。
- 不为了收敛擅自改变物理模型、参数、边界或初值。
- 区分代码/API 成功、数值求解完成和物理结果可信。
- 优先查当前安装版本的官方资料，只积累经验证的经验。

## 目录

```text
comsol-with-matlab/
├── README.md
├── LICENSE
├── SKILL.md
├── agents/openai.yaml
├── references/
│   ├── docs_index.md
│   ├── api_patterns.md
│   ├── solver_patterns.md
│   ├── postprocessing_patterns.md
│   └── known_issues.md
├── scripts/
│   ├── check_environment.m
│   ├── run_model.m
│   ├── diagnose_model.m
│   ├── validate_results.m
│   ├── smoke_model.m
│   └── smoke_case.m
├── templates/
│   ├── model_template.m
│   └── case_config_template.m
├── .gitignore
└── .gitattributes
```

## 安装到 Codex

将整个仓库文件夹以 `comsol-with-matlab` 为目录名，放入当前 Codex 的用户 Skill 目录：已设置 `CODEX_HOME` 时使用其 `skills/` 子目录，否则使用 `~/.codex/skills/`。如果已有同名 Skill，先比较内容并保留本地经验，避免直接覆盖。

安装后让 Codex 重新加载 Skill 清单，或在新聊天中调用：

```text
使用 $comsol-with-matlab 检查当前 COMSOL 项目，读取模型结构，执行程序，
根据反馈诊断，并在不改变物理问题的前提下验证和保存结果。
```

仓库根目录就是 Skill 根目录，`SKILL.md` 不需要再嵌套一层。自动选择策略保存在 [agents/openai.yaml](agents/openai.yaml)。

## MATLAB 最小使用

在已连接 COMSOL 的 MATLAB 会话中，将本仓库 `scripts/` 目录加入**当前进程**的搜索路径；不要 `savepath` 或修改启动配置。

```matlab
skillRoot = pwd; % 在本仓库根目录执行，或改为本次核实的仓库路径。
addpath(fullfile(skillRoot,'scripts'));
info = check_environment(pwd,'','');
assert(info.connected,info.error);
```

如需运行隔离环境测试，明确选择全新且可写的输出目录：

```matlab
caseDir = fullfile(tempdir,['comsol_smoke_' char(datetime('now','Format','yyyyMMdd_HHmmss_SSS'))]);
cfg = smoke_case(caseDir);
report = run_model(cfg);
assert(strcmp(report.status,'validated'),'COMSOLSkill:SmokeFailed','See case diagnostics.');
```

该测试会创建独立 server 模型并实际求解，输出 MPH、CSV、JSON、图像及日志。它不会自动关闭共享 server 或删除 server 模型；需要释放本次测试模型时，先核对 `report.serverModelTag` 再精确移除，不使用 `ModelUtil.clear`。建议在独立自动化 MATLAB 进程中运行；wrapper 会管理该进程的 diary/progress 设置。

新 batch 进程如缺少 LiveLink 路径或连接，按实际安装/现有 server 初始化，详见 [API 与执行模式](references/api_patterns.md)。模板故意在物理、提取或验证定义缺失时停止，需要按实际科研案例补齐；不能把模板当作已完成模型。

## 验证范围与限制

首次本地实测：**COMSOL 6.3.0.290 + MATLAB R2023b Update 9**。一维 Laplace 测试通过 L1/L2/L3 验证，11 点解析解最大误差约 `7.77e-16`，积分误差约 `3.33e-16 m`；同时验证了 COMSOL API 异常捕获、输出覆盖保护，以及 NaN/Inf、空数据和形状不符检查。

本次 GitHub 打包保留 MATLAB 执行代码，进行结构、链接、隐私路径扫描及 ZIP 完整性校验，没有再次启动求解器。历史经验见 [known_issues.md](references/known_issues.md)；包中不含原始本地日志、模型、数据或图像。

上述结果不能证明任意非线性、多相、瞬态或 THMC 模型正确，也不保证其他版本兼容。实际研究仍须确认物理定义、模块许可证、数值收敛、守恒和科学验收标准。时间戳保留原工具的 `Asia/Shanghai` 时区并包含 UTC 偏移；使用其他时区的团队可在其验证分支中调整。

## 上传到 GitHub

1. 创建或选择目标 GitHub 仓库。
2. 将发布 ZIP 解压，上传 `comsol-with-matlab` 文件夹**内部的全部文件和子目录**，包括 `.gitignore`、`.gitattributes`，让 `README.md` 与 `SKILL.md` 位于仓库根目录。
3. 也可在这个目录初始化 Git，提交后推送到自己的仓库。发布包不含 `.git`、预设 remote、账户信息或自动推送脚本。

不要仅把 ZIP 作为唯一仓库文件；展开后的源文件方便 GitHub 预览、版本管理和 Skill 安装。真实科研输入、私有运行记录和输出应保留在仓库之外；`.gitignore` 提供基础排除规则。

## 维护与许可

新增经验应提供错误特征、根因、失败尝试、正确方案、验证证据和适用版本。通用规则进入 `SKILL.md`，项目特定边界编号和敏感数据留在项目知识库。发布仓库不继承原使用者的本机授权，维护与执行均以当前用户授权为准。

本项目的代码与文档采用 **Apache License 2.0**（SPDX：`Apache-2.0`）许可证，完整条款见 [LICENSE](LICENSE)。MATLAB、COMSOL 和 LiveLink 为各自权利人的产品，相关许可不由本仓库授予。
