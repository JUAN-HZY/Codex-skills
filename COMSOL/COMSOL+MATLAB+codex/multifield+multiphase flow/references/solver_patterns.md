# Solver 诊断与数值策略

## 使用前提

本文件区分诊断原则与已实测配置。初始化 smoke test 只验证最小稳态模型；**没有**可泛化到两相/非线性 THMC 的万能 solver 设置。以后每个成功模式注明模型、方程、适用版本、参数范围、网格、误差指标与证据。

## 先分类

| 症状 | 优先检查与证据 |
|---|---|
| undefined variable/API property | 节点/tag、变量作用域、selection、dataset、当前版本 property，不先调容差 |
| singular matrix | 约束/刚体模态/压力参考、空 selection、退化参数、断连区域、方程闭合 |
| failed initialization/inconsistent values | IC/BC 一致性、DAE 约束、初始稳态、耦合和单位 |
| 非线性失败 | 残差/迭代、变量尺度、材料函数平滑性与适用区间、耦合强度、网格 |
| 时间步不断缩小 | 不连续载荷/事件、陡峭前沿、初值、变量尺度、最小步及局部误差日志 |
| segregated 振荡 | 分组与耦合、松弛、尺度、分组残差，考虑 fully coupled 对照 |
| 内存/线性迭代失败 | DOF、fill-in、矩阵条件、迭代残差/预条件器；不凭空删除物理 |

允许比较 fully coupled/segregated、Newton damping、scaling、continuation、auxiliary sweep、BDF、步长上限/下限、相对/绝对容差、direct/iterative/preconditioner，前提是按当前文档确认 feature/property。一次只验证有因果假设的最小变动。

## 不改变目标问题

- 初始值调整若改变真实物理 IC，必须讨论；求解器初始猜测与物理初始条件必须区分。
- Continuation 的最终参数必须回到目标值；中间诊断参数不当正式结果。
- 减小步长不等于缩短真实模拟时间；保存输出时刻不等于内部时间步。
- 更改容差、scaling、网格都要检查结果敏感性；无依据放宽验收标准不算修复。
- 诊断简化需独立配置/文件、说明差异、用途、证据，不能自动替换正式模型。

每轮记录：症状 → 根因假设 → 文档来源 → 修改前后数值设置 → 运行结果 → 验证 → 下一步。相同已失败方法不重复。合理诊断后仍无进展，向用户说明证据及需要的物理/研究路线决策。

## 已验证模式登记

初始化实测数据填入 `known_issues.md`；只有经多个适用案例证明稳定的 solver 配置才作为可复用成功模式升级到此处。不要把线性 smoke test 的默认 stationary solver 当作两相流/HM 的推荐方案。
