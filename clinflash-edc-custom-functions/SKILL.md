---
name: clinflash-edc-custom-functions
description: 为 Java 开发者生成 Clinflash EDC Custom Function 代码，涵盖数据点查询、校验计算、质疑管理、重命名 Block 与设置数据点值等场景。优先遵循 references 中的数据查询最佳实践，尤其是“从集合中提取单个数据点”的推荐范式；在可添加表单/可添加行等复杂层级场景可使用 Map/Set 分层处理。
---

# Clinflash EDC Custom Functions

## 适用场景

当用户需要以下任一任务时，使用本技能：

- 编写或重构 Clinflash EDC Custom Function（Java）
- 查询/聚合数据点并进行业务判断
- 打开或关闭质疑（OpenQuery）
- 重命名 Block（RenameBlock）
- 设置数据点值（SetDataPointValue）

## 强制工作流（必须执行）

在输出代码前，严格按顺序执行：

1. 先读取通用参考（必读）：
- [代码模板](./references/code-template.md)
- [EDC API 参考](./references/edc-api-reference.md)
- [EDC 用法示例](./references/edc-example-usage.md)

2. 若涉及“从集合中取单个数据点”或“质疑操作”，建议优先阅读：
- [代码模板](./references/code-template.md) 中“从集合中获取单个数据点”与“Template 0.1 质疑模式前置段”
- [EDC 用法示例](./references/edc-example-usage.md) 中集合筛选与场景示例

2.1 在任何查询代码前，优先采用固定定位前置段：
- 先获取 `checkDp`：`system().getDataPoint(context().getCheckDataPoints().get(0))`
- 至少获取 `subjectId`，并按需获取 `dataPageId` / `instanceId`
- 再执行 `listDataPoints(EntityWrapper..., null)` 或 `listVisibleDataPoints(EntityWrapper..., null)`

3. 再按需求读取场景参考（至少命中一类）：
- OpenQuery 场景：读取 [OpenQuery 目录](./references/OpenQuery-operations/)
- RenameBlock 场景：读取 [RenameBlock 目录](./references/RenameBlock-operations/)
- SetDataPointValue 场景：读取 [SetDataPointValue 目录](./references/SetDatapointValue-operations/)

3.1 在场景目录内，必须额外读取“最可能相关的 1 个具体 `.md` 示例文件”：
- 目标是看到一个完整可运行的端到端例子，而不是只看目录名或片段
- 优先选择与当前需求最接近的文件名（按操作类型、表单名、字段名匹配）
- 若无法唯一判断，选择最接近的 1 个并在输出说明中写明“参考文件名”

4. 明确输入上下文后再写代码：
- folderOid、formOid、fieldOid 是否完整
- 是否涉及 blockRepeatNumber、gridRow、instance
- 触发数据点与目标数据点是否在同一访视/表单

5. 输出前自检：
- 查询条件是否包含 `isVisible`/`dataPointActive`（按需求）
- 空值处理是否完备
- 对应操作（open/close query、setDataPointValue、rename block）是否与需求一致
- 若涉及 openQuery/closeQuery，`msg`/`checkId` 是否在 `run()` 开头作为前置段声明
- 是否先通过 `checkDp` 拿到 `subjectId`（及按需 `dataPageId` / `instanceId`）再查询
- 是否已读取 1 个最相关的场景示例 `.md`（完整例子）再生成代码
- 若涉及集合取单点，是否优先使用本技能推荐范式；若未使用，是否给出合理原因

不要在未读取参考文档时直接生成最终代码。

## 集合取单点推荐规则（高优先级，非强制）

当任务需要“从 `List<CDataPoint>` 中定位单个数据点”时，优先遵循以下规则（非强制）：

1. 推荐范式（优先使用）
- 普通表单（masterRecord）：
```java
CDataPoint dp = dataPoints.stream()
        .filter(dataPoint -> "FIELD_OID".equals(dataPoint.getFieldOid()))
        .findAny().get();
```
- 可添加行/指定行：
```java
CDataPoint dp = dataPoints.stream()
        .filter(dataPoint -> "FIELD_OID".equals(dataPoint.getFieldOid()) && dataPoint.getGridRow() == row)
        .findAny().get();
```

2. 不推荐项（有充分理由时可例外）
- 不要自创与 reference 不一致的“取单点”封装方式（如自行设计通用定位 DSL 或新风格 helper），除非用户明确要求重构
- 不要用 `list.get(0)` 代替 `fieldOid` 过滤（除非查询条件已唯一锁定该字段且用户明确接受）
- 不要引入 reference 未出现的 EDC 私有 API

3. 例外场景（允许偏离推荐范式）
- 可添加表单/可添加行存在复杂层级关系时，可优先使用按 `blockRepeatNumber`/`gridRow` 分组的 `Map` 结构（参考 `edc-api-reference.md` 与 `edc-example-usage.md`）
- 需要去重或批量判断时，可结合 `Set` 提升可读性与性能
- 仍建议优先“复用 reference 骨架 + 替换业务字段”，避免无依据自创

## 场景索引（按需读取）

### OpenQuery（质疑）

- 计算与验证：
  - [BMI 计算与验证](./references/OpenQuery-operations/calculation-validation/BMI_CalculatorAndValidator.md)
  - [QTCF 计算与验证](./references/OpenQuery-operations/calculation-validation/QTCF_CalculatorValidator.md)
  - [RR 计算与验证](./references/OpenQuery-operations/calculation-validation/RR_CalculatorValidator.md)
  - [总分验证](./references/OpenQuery-operations/calculation-validation/TotalScoreValidator.md)
- 日期时间：
  - [日期重复检查](./references/OpenQuery-operations/date-time/DateDuplicateValidator.md)
  - [跨表单日期时间比较](./references/OpenQuery-operations/date-time/DateTimeCompareValidator.md)
  - [提前退出访视日期检查](./references/OpenQuery-operations/date-time/EarlyExitVisitDateValidator.md)
  - [开始/结束日期逻辑检查](./references/OpenQuery-operations/date-time/STDAT_ENDAT_LogicValidator.md)
- 重复值检查：
  - [IE 重复检查](./references/OpenQuery-operations/duplicate-check/IE_DuplicateValidator.md)
  - [VSTPT 重复检查](./references/OpenQuery-operations/duplicate-check/VSTPT_DuplicateValidator.md)
- 其他验证：
  - [AE 严重程度与日志行校验](./references/OpenQuery-operations/other-validation/AESeverity_LoglineNum_Validator.md)
  - [基线评分校验](./references/OpenQuery-operations/other-validation/BaselineScoreValidator.md)

### RenameBlock（重命名 Block）

- [AE 表单 Block 重命名](./references/RenameBlock-operations/CF_AE_BlockName.md)
- [ISR 表单 Block 重命名](./references/RenameBlock-operations/CF_ISR_BlockName.md)

### SetDataPointValue（设置数据点值）

- [EGFR 计算](./references/SetDatapointValue-operations/calculateEGFR.md)
- [心率平均值计算](./references/SetDatapointValue-operations/calculateHEARTaverage.md)
- [实验室年龄计算](./references/SetDatapointValue-operations/calculateLABAGE.md)
- [QTCF 平均值计算](./references/SetDatapointValue-operations/calculateQTCFaverage.md)
- [获取 AESTDAT](./references/SetDatapointValue-operations/getAESTDAT.md)

## 需求澄清模板（先问再写）

在信息不完整时，先补齐以下字段：

- 触发点：`folderOid/formOid/fieldOid`
- 目标点：`folderOid/formOid/fieldOid`
- 是否可添加行：`gridRow` 是否固定或遍历
- 是否跨表单/跨访视
- 操作类型：`openQuery` / `closeQuery` / `setDataPointValue` / `renameBlock`
- 质疑检查号：`checkId`（如涉及质疑）

## 生成约束

- 代码语言：Java
- 类定义：`public class Xxx extends CFunction`
- 入口：`public int run()`，默认 `return 0;`
- 查询前优先写固定定位段：`checkDp -> subjectId -> (dataPageId/instanceId)`
- 查询优先使用 `system().listVisibleDataPoints` 或 `system().listDataPoints`（与参考一致）
- 若涉及质疑，优先将 `String msg` 与 `String checkId` 放在 `run()` 方法最前位置，再在后文复用
- 不使用 reference API 未定义的方法签名（例如 `listDataPoints("ET","SV","VISDAT")`）
- 不引入参考文档中未出现的 EDC 私有 API

## 冲突处理优先级

当多个参考存在差异时，按以下优先级处理：

1. [EDC API 参考](./references/edc-api-reference.md)
2. 场景专项示例（OpenQuery/RenameBlock/SetDataPointValue）
3. [代码模板](./references/code-template.md)

## 输出格式

输出应包含：

1. 完整 Java 代码
2. 关键逻辑说明（数据来源、判断条件、执行动作）
3. 可选风险提示（空值、日期格式、重复记录、跨表单一致性）
4. 若涉及集合取单点，补充一句“已优先按 reference 最佳实践使用 `fieldOid`/`gridRow` 过滤”；如采用 Map/Set 方案，说明原因
5. 若涉及质疑，补充一句“已将 `msg`/`checkId` 前置到 `run()` 开头并全程复用”
6. 补充一句“本次参考的最相关完整示例文件：`xxx.md`”
