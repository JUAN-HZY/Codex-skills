# 后处理、导出与验证

以下接口依据本机 6.3 官方帮助，具体科研表达式和 dataset 必须从模型中查。

| 需求 | 方法与限制 |
|---|---|
| 指定坐标取值/剖面 | `mphinterp`；coord 每列一个点、行数对应空间维数，明确 edim/dataset/selection |
| FE 节点/场数据 | `mpheval`；检查 p/t/d1…/unit 的尺寸及复数策略 |
| 全局量/已定义积分算子 | `mphglobal`；空间场不能无依据直接作为 global |
| 几何积分与守恒 | `mphint2`；选择 line/surface/volume、域/边界、通量符号、时间与单位 |
| 几何平均 | 根据官方定义选择 `mphmean`，不要把节点算术平均当体积平均 |

## 明确解的身份

1. 列 `model.result.dataset.tags`、`mphsolinfo`，确认目标 study/solver 对应的 dataset。
2. 记录 expression、单位、edim、selection、coord、solnum、outersolnum、t。参数扫描需检查全部目标组合，不能仅验证默认第一个外层解。
3. `solnum` 选保存解，`t` 可能进行时间插值；不得把插值输出当实际 solver 时间步。
4. `mphinterp` 检查域外点、NaN、Inf、空结果和形状；不要自动 extrapolate 来掩盖坐标/单位错误。单位要求不一致时 COMSOL 可能回退默认单位，必须核对返回 unit。

## 三级证据

`validate_results` 支持显式 actual/expected、absTol/relTol 和 level=2/3。它验证有限值、非空和严格相同形状，避免 MATLAB implicit expansion 导致假通过。evidence 中 apiCompleted、solverCompleted、numericsReviewed、physicsReviewed 必须基于本次运行日志与模型事实；不能全部硬编码为 true。

通用模板不会替研究者决定验收阈值。物理约束、单位核对、边界条件、守恒和模型比较，应由案例 callback 明确实现并作为 checks/evidence 返回；没有提供时保持 unknown/未验证。质量指标、负压、应力和通量符号按模型定义，不套统一范围。

## 数据和图

CSV 输出数值与单位列/伴随 JSON；MAT 使用明确的 `-v7`（大数据按需 -v7.3）；记录坐标顺序、时间、参数、复数数据约定。绘图写坐标/单位、色标、物理量、时间/参数；禁止为美观裁去异常值。正式项目保留关键图和源数据；自动图仍需目视检查布局和含义。

网格/时间步/容差敏感性、质量/能量守恒、极限情形、理论/实验对照按研究目标选择，结果收敛和 solver 收敛分别报告。环境 smoke test 的解析解对照不能推广为真实多物理耦合模型的验证结论。
