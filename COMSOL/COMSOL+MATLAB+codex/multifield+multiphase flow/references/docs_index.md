# 文档定位与版本基线

## 版本策略与来源优先级

每个新项目首次记录 `mphversion`、`version`、`which('mphversion')`、工程/输入/输出路径；环境未变不重复大规模扫描。同机多版本以实际连接 server 为准，不混用不同版本的 mli/Java 类与 server。

优先级固定：安装版本帮助 → LiveLink User's Guide → Programming Reference Manual → `mphdoc`/MATLAB help → Desktop 验证导出 M-file → Application Library → 官方 KB/论坛 → 本 Skill 已验证经验 → 其他网络资料。

## 当前环境的文档入口

本发布包不包含某位使用者的用户名、安装盘符、实际监听端口或工程路径。以下 `COMSOL_ROOT` 表示使用者核实的当前安装根目录；路径形状仅作定位线索，以实际安装和当前版本帮助为准。

| 内容 | 相对于 COMSOL_ROOT 的常见位置 |
|---|---|
| MATLAB 函数帮助与 LiveLink 实现 | `mli/` |
| LiveLink HTML | `doc/help/wtpwebapps/ROOT/doc/com.comsol.help.llmatlab/` |
| COMSOL HTML/API | `doc/help/wtpwebapps/ROOT/doc/com.comsol.help.comsol/` |
| Programming Reference PDF | COMSOL HTML 根中的 `COMSOL_ProgrammingReferenceManual.pdf` |
| Java API | COMSOL HTML 根中的 `api/index.html` |
| 官方模型库 | `applications/` |

普通 MATLAB batch 不继承其他交互 MATLAB 进程的临时 path 和连接。连接正常时直接使用；只有新进程缺少路径/连接时才在该进程中初始化，不 `savepath`、不改 startup.m、不自动重启 server。

## 历史验证基线

首次实际验证日期为 2026-10-18：COMSOL 6.3.0.290、MATLAB R2023b Update 9，同机已有 server。通过独立一维 Laplace 模型完成求解、解析解对照、日志和错误捕获。这是历史测试范围，不是当前机器的安装状态或其他版本的兼容保证。详见 [known_issues.md](known_issues.md)。

## 已核对的 6.3 页面

下表相对于 LiveLink HTML 根，文件名只对应已核对的 6.3 帮助；其他版本需重新定位。

| 接口 | HTML 文件 |
|---|---|
| mphglobal | `llmatlab_ug_ref.9.32.html` |
| mphinterp | `llmatlab_ug_ref.9.36.html` |
| mphload | `llmatlab_ug_ref.9.39.html` |
| mphmeshstats | `llmatlab_ug_ref.9.45.html` |
| mphsave | `llmatlab_ug_ref.9.58.html` |
| mphshowerrors | `llmatlab_ug_ref.9.64.html` |
| mphsolinfo | `llmatlab_ug_ref.9.65.html` |
| mphstart | `llmatlab_ug_ref.9.67.html` |
| mphstartcomsolmphserver | `llmatlab_ug_ref.9.68.html` |
| mphtags | `llmatlab_ug_ref.9.72.html` |

`ModelUtil.showProgress(filename)`、`uniquetag`、`createUnique`、`remove` 的定义见 COMSOL HTML 根中的 `comsol_api_general.47.15.html` 及 Java API。LiveLink 中不使用面向独立 Java 的 `initStandalone`。

## 官方在线后备入口

- [6.3 LiveLink for MATLAB User's Guide](https://doc.comsol.com/6.3/doc/com.comsol.help.llmatlab/html_LiveLinkForMATLABManual.html)
- [6.3 Programming Reference Manual](https://doc.comsol.com/6.3/doc/com.comsol.help.comsol/html_COMSOLMultiphysicsProgrammingReferenceManual.html)
- [官方 Knowledge Base](https://www.comsol.com/support/knowledgebase)
- [官方 Application Gallery](https://www.comsol.com/models)

本地当前版本帮助优先；不因在线有新版本就升级或重配环境。property 不确定时查 help、mphdoc、mphgetproperties、当前版本 API 或 Desktop 导出代码，再做隔离验证。
