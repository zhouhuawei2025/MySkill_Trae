# EDC API Reference（仅 API 字典）

> 本文档只提供 API 与数据结构说明，不提供业务模板或完整场景代码。  
> 模板请看 [code-template.md](./code-template.md)，端到端案例请看 [edc-example-usage.md](./edc-example-usage.md)。

## 快速导航

- 查方法签名：见 `System` / `Context` / `CDataPoint`
- 查“该用 dataPageId 还是 instanceId”：见“查询定位建议”
- 查集合取单点、Map 分层处理、Set 去重：见 [code-template.md](./code-template.md)

## 包与核心类型

### 核心包

- `com.jxedc.clinflash.customfunction`
  - `CFunction`
- `com.jxedc.clinflash.customfunction.entity`
  - `CDataPoint`
  - `CBlock`
  - `CInstance`
- `com.jxedc.clinflash.common.utils`
  - `StringUtils`

### CFunction

- `int run()`：Custom Function 入口
- `context()`：获取上下文对象
- `system()`：获取 EDC 系统操作对象

### Context

- `getCheckDataPoints()`：触发点 ID 列表
- `getDataPageId()`：当前页面 ID
- `getSubjectId()`：当前受试者 ID

### CDataPoint 常用字段/方法

- 标识与定位：
  - `getDataPointId()`
  - `getSubjectId()`
  - `getFolderOid()`
  - `getFormOid()`
  - `getFieldOid()`
  - `getDataPageId()`
  - `getInstanceId()`
  - `getGridRow()`
  - `getBlockRepeatNumber()`
- 值与状态：
  - `getDataValue()`
  - `getDicEntryOid()`
  - `getDataPointActive()`
  - `getRecordActive()`
  - `getIsFrozen()`
  - `getLower()`
  - `getUpper()`

## System API 速查

### 查询

- `getDataPoint(Long dataPointId)`
- `listDataPoints(EntityWrapper<CDataPoint> wrapper, RowBounds rowBounds)`
- `listVisibleDataPoints(EntityWrapper<CDataPoint> wrapper, RowBounds rowBounds)`

### 写入与状态

- `setDataPointValue(Long datapointId, String value)`
- `setDataPointValue(CDataPoint datapoint)`
- `setDataPointActive(List<Long> dataPointIdList, Boolean active)`
- `setBlockActive(Long blockId, Boolean active)`
- `setInstanceActive(Long instanceId, Boolean active)`

### Query 与流程

- `openQuery(String queryMessage, Long dataPointId, String checkName)`
- `closeQuery(Long dataPointId, String checkName)`
- `setSubjectStatus(Long subjectId, String status)`

### 结构变更

- `addInstance(Long folderId)`
- `addInstance(Long folderId, String unscheduledName)`
- `updateInstance(Long instanceId, String unscheduledName)`
- `addBlock(Long instanceId, Long moduleId)`
- `addBlock(Long instanceId, Long moduleId, String unscheduledName)`
- `updateBlock(Long blockId, String unscheduledName)`
- `addGridDataPoint(List<CDataPoint> dataPointList)`

### 工具

- `age(Date start, Date end)`

## 查询定位建议（决策表）

- 当前表单主记录优先：`subjectId + dataPageId + formOid + fieldOid`
- 跨访视/跨页面：`subjectId + folderOid/instanceId + formOid/dataPageId + fieldOid`
- 可添加行：在筛选或映射时显式使用 `gridRow`
- 可添加页/复杂层级：使用 `blockRepeatNumber + gridRow + fieldOid` 分层
- 仅处理有效记录时：增加 `isVisible = 1`、`dataPointActive = 1`（按业务需要）

## 使用边界

- API 以本文件为准。
- 业务写法以 [code-template.md](./code-template.md) 推荐模板为准。
- 场景组合方式以 [edc-example-usage.md](./edc-example-usage.md) 为准。
