# EDC系统API参考

## EDC Java包结构

EDC系统使用的Java包主要分为两类：

### 1. 实际项目中使用的包 (`com.jxedc.clinflash`)

**核心包结构：**
- **com.jxedc.clinflash.customfunction**
  - `CFunction`：Custom Function的基类，所有Custom Function都需要继承此类
  - 提供了`context()`和`system()`方法获取上下文和系统对象

- **com.jxedc.clinflash.customfunction.entity**
  - `CDataPoint`：数据点类，代表EDC系统中的一个数据点
  - `CBlock`：Block（页面）类，代表EDC系统中的一个页面
  - `CInstance`：Instance（访视实例）类，代表EDC系统中的一个访视实例

- **com.jxedc.clinflash.common.utils**
  - `StringUtils`：字符串工具类，提供字符串处理方法

### 2. 示例中使用的包 (`com.edc.sdk`)

**核心包结构：**
- **com.edc.sdk**
  - `EdcClient`：EDC客户端类，用于与EDC系统进行交互
  - `EdcQuery`：EDC查询构建器类，用于构建查询参数
  - `EdcApiException`：EDC API异常类，用于处理API调用异常

## 核心类和接口

### CFunction

**功能**：Custom Function的基类，所有Custom Function都需要继承此类

**主要方法**：
- `run()`：Custom Function的主方法，包含主要业务逻辑
- `context()`：获取上下文对象，用于获取当前数据点、页面和受试者信息
- `system()`：获取系统对象，用于执行EDC操作

### CDataPoint

**功能**：数据点类，代表EDC系统中的一个数据点

**主要属性**：
- `subjectId`：受试者ID
- `dataPageId`：数据页面ID
- `fieldOid`：数据点字段OID
- `dataPointActive`：数据点是否激活（1表示激活，0表示未激活）
- `dataPointValue`：数据点的值
- `dataPointTimestamp`：数据点的时间戳
- `isVisible`：数据点是否可见（1表示可见，0表示隐藏）

**主要方法**：
- `getUnit()`：获取单位
- `getSpecifyValue()`：获取详细说明的值
- `getDataDicEntryId()`：获取数据字典条目id
- `getDataDictionaryId()`：获取数据字典id
- `getModuleId()`：获取所属模块id
- `getModuleOid()`：获取所属模块OID
- `getDataPointId()`：获取数据点id
- `getDataPageId()`：获取数据页面，即表单id
- `getFolderOid()`：获取访视oid
- `getFieldOid()`：获取表单字段oid
- `getFormOid()`：获取表单oid
- `getDataValue()`：获取数据点的值
- `getDicEntryOid()`：获取数据字典oid
- `getGridRow()`：获取行号
- `getInstanceId()`：获取所在instance，即访视的id
- `getBlockId()`：获取所在块id
- `getBlockRepeatNumber()`：获取block的重复号
- `getInstanceRepeatNumber()`：获取instance，即访视的重复号
- `getIsFrozen()`：获取数据点是否被冻结，1：冻结  0：未冻结
- `getDataPointActive()`：获取数据点是否激活，1：激活  0：隐藏
- `getRecordActive()`：获取数据点所在的行是否激活，1：激活 0：隐藏
- `getLower()`：获取实验室指标下限
- `getUpper()`：获取实验室指标上限

### Context

**功能**：上下文对象，用于获取当前操作的相关信息

**主要方法**：
- `getCheckDataPoints()`：获取触发Custom Function的数据点ID列表
- `getDataPageId()`：获取当前页面ID
- `getSubjectId()`：获取当前受试者ID

### System

**功能**：系统对象，用于执行EDC操作

**主要方法**：
- `getDataPoint(Long dataPointId)`：根据ID获取数据点
- `listDataPoints(EntityWrapper<CDataPoint> wrapper, RowBounds rowBounds)`：根据条件查询数据点列表
- `setDataPointValue(Long datapointId, String value)`：设置数据点值
- `setDataPointValue(CDataPoint datapoint)`：设置数据点值（用于数据字典）
- `setDataPointActive(List<Long> dataPointIdList, Boolean active)`：激活或隐藏数据点
- `setBlockActive(Long blockId, Boolean active)`：激活或隐藏block(页面)
- `setInstanceActive(Long instanceId, Boolean active)`：激活或隐藏instance(访视)
- `closeQuery(Long dataPointId, String checkName)`：关闭质疑
- `openQuery(String queryMessage, Long dataPointId, String checkName)`：打开质疑
- `setSubjectStatus(Long subjectId, String status)`：设置受试者状态
- `addInstance(Long folderId, String unscheduledName)`：添加instance，自定义名称
- `addInstance(Long folderId)`：添加instance，使用默认名称
- `addBlock(Long instanceId, Long moduleId, String unscheduledName)`：添加block，自定义名称
- `addBlock(Long instanceId, Long moduleId)`：添加block，使用默认名称
- `addGridDataPoint(List<CDataPoint> dataPointList)`：添加行结构的一行
- `updateInstance(Long instanceId, String unscheduledName)`：更新instance
- `updateBlock(Long blockId, String unscheduledName)`：更新block
- `age(Date start, Date end)`：按年月日计算年龄

## 数据查询的最佳实践

### 1. 获取触发Custom Function的数据点

```java
// 获取触发Custom Function的数据点ID
List<Long> dataPointIdList = context().getCheckDataPoints();
Long checkDataPointId = dataPointIdList.get(0);

// 获取数据点对象
CDataPoint checkDp = system().getDataPoint(checkDataPointId);
```

### 2. 获取当前表单的数据点

```java
// 获取当前页面ID和受试者ID
Long dataPageId = context().getDataPageId();
Long subjectId = context().getSubjectId();

// 查询特定表单的多个数据点
List<CDataPoint> dataPoints = system().listDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", subjectId)
        .and().eq("dataPageId", dataPageId)
        .and().eq("formOid", "EASI")
        .and().in("fieldOid", Arrays.asList("QSSCORE6", "QSORRES"))
        .and().eq("dataPointActive", 1), null);
```

### 3. 按层级获取数据点（适用于可添加页和可添加行的表单）
```java
// 构建层级Map：BlockRepeatNumber -> GridRow -> FieldOid -> CDataPoint
Map<Integer, Map<Integer, Map<String, CDataPoint>>> dataPointMap = system().listDataPoints(
        new EntityWrapper<CDataPoint>()
                .eq("folderOid", "AE")
                .and().eq("formOid", "AE")
                .and().in("fieldOid", Arrays.asList("AESTDAT", "AEENDAT", "AEACN"))
                .and().eq("isVisible", 1)
                .and().eq("dataPointActive", 1), null)
        .stream().collect(Collectors.groupingBy(CDataPoint::getBlockRepeatNumber,
                Collectors.groupingBy(CDataPoint::getGridRow,
                        Collectors.toMap(CDataPoint::getFieldOid, o -> o, (o1, o2) -> o1))));

// 使用层级Map获取数据
for (int blockRepeatNumber : dataPointMap.keySet()) {
    Map<Integer, Map<String, CDataPoint>> rowMap = dataPointMap.get(blockRepeatNumber);
    for (Map.Entry<Integer, Map<String, CDataPoint>> rowEntry : rowMap.entrySet()) {
        int gridRow = rowEntry.getKey();
        Map<String, CDataPoint> fieldMap = rowEntry.getValue();
        
        CDataPoint aestdatDp = fieldMap.get("AESTDAT");
        CDataPoint aeendatDp = fieldMap.get("AEENDAT");
        CDataPoint aeacnDp = fieldMap.get("AEACN");
        
        // 处理数据...
    }
}
```

## 数据操作示例

### 1. 设置数据点值

```java
// 通过ID设置数据点值
system().setDataPointValue(dataPointId, "123");

// 通过数据点对象设置值（适用于数据字典）
CDataPoint dataPoint = system().getDataPoint(dataPointId);
dataPoint.setDataValue("123");
system().setDataPointValue(dataPoint);
```

### 2. 激活或隐藏数据点

```java
// 激活数据点
system().setDataPointActive(Arrays.asList(dataPointId1, dataPointId2), true);

// 隐藏数据点
system().setDataPointActive(Arrays.asList(dataPointId1, dataPointId2), false);
```

### 3. 打开和关闭质疑

```java
// 打开质疑
system().openQuery("数据异常，请核实", dataPointId, "DataCheck");

// 关闭质疑
system().closeQuery(dataPointId, "DataCheck");
```

## 日期处理示例
详细的日期处理示例请参考 SKILL.md 文件中的"高级功能"部分和 `references/edc-example-usage.md` 文件中的相关实现。


## 错误处理

### 常见错误场景

1. **数据点不存在**：当尝试获取不存在的数据点时
2. **权限不足**：当尝试执行没有权限的操作时
3. **数据格式错误**：当设置的数据格式不符合要求时
4. **系统异常**：当EDC系统出现内部错误时

### 异常处理最佳实践

```java
try {
    // EDC操作
    CDataPoint dataPoint = system().getDataPoint(dataPointId);
    // 处理数据
} catch (Exception e) {
}

// 成功执行
return 0;
```

## 性能优化

1. **批量操作**：使用listDataPoints一次性获取多个数据点，减少API调用
2. **缓存机制**：对于频繁访问的数据，可以考虑使用缓存
3. **并行处理**：对于大量数据点的处理，可以使用并行流
4. **条件过滤**：在查询时使用精确的条件，减少返回的数据量

## 安全考虑

1. **数据验证**：在设置数据点值之前，进行数据验证
2. **权限检查**：确保执行的操作符合用户权限
3. **审计日志**：记录重要操作的审计日志
4. **错误处理**：妥善处理错误，避免敏感信息泄露