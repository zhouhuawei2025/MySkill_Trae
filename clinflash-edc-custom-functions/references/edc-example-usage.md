# EDC Example Usage（仅端到端案例）

> 本文档只放场景案例，不重复 API 字典和模板定义。  
> API 字典见 [edc-api-reference.md](./edc-api-reference.md)，推荐模板见 [code-template.md](./code-template.md)。

## 快速导航

- 场景 A：普通表单集合取单点 + OpenQuery
- 场景 B：可添加表单/可添加行（AE）Map 分层处理
- 场景 C：重复值检查（Set）

## 场景 A：普通表单集合取单点 + OpenQuery

```java
List<CDataPoint> dataPoints = system().listDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", subjectId)
        .and().eq("dataPageId", dataPageId)
        .and().eq("formOid", "EASI")
        .and().in("fieldOid", Arrays.asList("QSORRES", "QSSCORE6"))
        .and().eq("dataPointActive", 1), null);

if (dataPoints.isEmpty()) return 0;

CDataPoint qsorresDp = dataPoints.stream()
        .filter(dp -> "QSORRES".equals(dp.getFieldOid()))
        .findAny().get();

if (StringUtils.isEmpty(qsorresDp.getDataValue())) return 0;

String checkId = "QSORRES_CHECK";
String msg = "<font color=\"RED\">QSORRES 异常，请核实。</font>";
system().openQuery(msg, qsorresDp.getDataPointId(), checkId);
```

使用说明：复用 `Template 2 + Template 5(OpenQuery)`。

## 场景 B：可添加表单/可添加行（AE）Map 分层处理

```java
Map<Integer, Map<Integer, Map<String, CDataPoint>>> dataPointMap = system().listDataPoints(
        new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("folderOid", "AE")
                .and().eq("formOid", "AE")
                .and().in("fieldOid", Arrays.asList("AESTDAT", "AEENDAT", "AEACN"))
                .and().eq("isVisible", 1)
                .and().eq("dataPointActive", 1), null)
        .stream().collect(Collectors.groupingBy(CDataPoint::getBlockRepeatNumber,
                Collectors.groupingBy(CDataPoint::getGridRow,
                        Collectors.toMap(CDataPoint::getFieldOid, o -> o, (o1, o2) -> o1))));

for (Map<Integer, Map<String, CDataPoint>> rowMap : dataPointMap.values()) {
    for (Map<String, CDataPoint> fieldMap : rowMap.values()) {
        CDataPoint aeStart = fieldMap.get("AESTDAT");
        CDataPoint aeEnd = fieldMap.get("AEENDAT");
        CDataPoint aeAction = fieldMap.get("AEACN");
        if (aeStart == null || aeEnd == null || aeAction == null) continue;

        // 业务逻辑...
    }
}
```

使用说明：复用 `Template 3`，这是“推荐范式的例外场景”，不是偏离规范。

## 场景 C：重复值检查（Set）

```java
List<CDataPoint> dpList = system().listVisibleDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", subjectId)
        .and().eq("formOid", "VS")
        .and().eq("fieldOid", "VSTPT")
        .and().eq("isVisible", 1)
        .and().eq("dataPointActive", 1), null);

Set<String> vstptSet = dpList.stream()
        .map(CDataPoint::getDicEntryOid)
        .filter(StringUtils::isNotEmpty)
        .collect(Collectors.toSet());

if (vstptSet.size() < dpList.size()) {
    CDataPoint triggerDp = system().getDataPoint(context().getCheckDataPoints().get(0));
    system().openQuery("<font color=\"RED\">VSTPT 存在重复值，请核实。</font>", triggerDp.getDataPointId(), "VSTPT_DUP_CHECK");
}
```

使用说明：复用 `Template 1 + Template 4 + Template 5(OpenQuery)`。

## 选型建议

- 优先使用 [code-template.md](./code-template.md) 的推荐模板。
- 需要跨 block/gridRow 的层级处理时，优先使用 Map 分层方案。
- 需要去重/交集判断时，使用 Set。
- 若出现与模板不同的写法，应在说明中标注原因。
