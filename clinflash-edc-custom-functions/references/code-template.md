# Clinflash EDC Code Template（仅推荐模板）

> 本文档只提供可复用模板，不展开 API 解释。  
> API 说明请看 [edc-api-reference.md](./edc-api-reference.md)，端到端案例请看 [edc-example-usage.md](./edc-example-usage.md)。

## 快速导航

- 最小骨架：`Template 0`
- 质疑模式前置段：`Template 0.1`
- 单点查询：`Template 1`
- 多点查询 + 集合取单点：`Template 2`
- 可添加表单/可添加行 Map 分层：`Template 3`
- Set 去重：`Template 4`
- OpenQuery/SetDataPointValue/RenameBlock：`Template 5`

## Template 0：最小可运行骨架

```java
import com.jxedc.clinflash.customfunction.CFunction;

public class XxxFunction extends CFunction {
    @Override
    public int run() {
        return 0;
    }
}
```

## 标准思路框架（Step0-Step4）

> 该框架是 Custom Function 的推荐主线。涉及质疑时，优先使用 Step0 前置段并放在 `run()` 开头。

```java
import xxxxxxx;
import xxxxxxx;
....
import xxxxxxx;

// ThisCustomFunctionName 的名称由用户提供
public class ThisCustomFunctionName extends CFunction {
    @Override
    public int run() {
        // step0: 若与质疑相关，优先在方法最前放置下面两行，
        // 配合 system().openQuery(msg, xxx.getDataPointId(), checkId);
        // 和 system().closeQuery(xxx.getDataPointId(), checkId); 使用
        // String msg = "<font color=\"RED\">query text</font>";
        // String checkId = "ThisCustomFunctionName";

        // step1: 从 EDC 获取输入数据点参数
        // 常用方法见: edc-api-reference.md（System API 速查、查询定位建议）
        // 推荐模板见: Template 1 / Template 2 / Template 3

        // step2: 数据处理、计算或判断，以及其他复杂操作
        // 场景案例见: edc-example-usage.md（场景 A/B/C）

        // step3: 根据判断结果，执行 EDC 操作
        // 常用操作见: Template 5（open/close query、set value、rename block）

        return 0;
    }

    // step4 (可选): 自定义函数（可有出参，也可无出参）
    public void customFunction() {
        // 自定义函数实现
    }
}
```

## Template 0.1：质疑模式前置段（放在 `run()` 最前）

> 当需求涉及 `openQuery` / `closeQuery` 时，优先在 `run()` 开头放置以下三行（紧跟触发点读取前后均可，但应位于业务逻辑前）。

```java
// 如需质疑，使用以下两行，配合 openQuery/closeQuery
String msg = "<font color=\"RED\">query text</font>";
String checkId = "ThisCustomFunctionName";
```

推荐位置示例：

```java
@Override
public int run() {
    // 质疑模式前置段（建议放在方法最前）
    String msg = "<font color=\"RED\">query text</font>";
    String checkId = "ThisCustomFunctionName";

    CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
    Long subjectId = checkDp.getSubjectId();

    // ...后续查询与判断
    return 0;
}
```

## Template 0.2：固定定位前置段（推荐默认写法）

> 除非用户明确要求“脱离触发点单独批处理”，否则建议在所有查询前先写这段。  
> 目的：以触发数据点为入口，锁定当前受试者与页面/访视上下文，避免跨受试者或跨页面误查。

```java
// 获取触发数据点（固定入口）
CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
Long subjectId = checkDp.getSubjectId();

// 按需启用以下定位信息
Long dataPageId = checkDp.getDataPageId();
Long instanceId = checkDp.getInstanceId();
```

推荐后续查询方式：

```java
List<CDataPoint> dps = system().listDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", subjectId)
        .and().eq("dataPageId", dataPageId)
        .and().eq("fieldOid", "FIELD_OID"), null);
```

禁止写法（未在 reference API 中定义）：

```java
// List<CDataPoint> visdatList = system().listDataPoints("ET", "SV", "VISDAT");
```

## 查询规范（强约束）

### 1) 唯一合法查询骨架（优先直接复用）

```java
CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
Long subjectId = checkDp.getSubjectId();
Long dataPageId = checkDp.getDataPageId();   // 按需使用
Long instanceId = checkDp.getInstanceId();   // 按需使用

List<CDataPoint> dps = system().listDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", subjectId)
        // .and().eq("dataPageId", dataPageId)   // 同页面
        // .and().eq("instanceId", instanceId)   // 同访视实例
        .and().eq("formOid", "FORM_OID")
        .and().eq("fieldOid", "FIELD_OID")
        .and().eq("isVisible", 1)
        .and().eq("dataPointActive", 1), null);
```

### 2) 禁止模式清单（不要生成）

- `new EntityWrapper("ET", "SV", null)` 及同类位置参数构造器写法
- `system().listDataPoints("ET", "SV", "VISDAT")` 及同类三参数快捷写法
- 未经 `subjectId` 约束直接查跨表单数据点（除非用户明确要求全库批处理）

### 3) 类型约束

- `subjectId` 必须是 `Long`，不要写成 `String`
- `dataPageId` 必须是 `Long`
- `instanceId` 必须是 `Long`

## Template 1：查询单个数据点（推荐）

```java
List<CDataPoint> dpList = system().listVisibleDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", subjectId)
        .and().eq("formOid", "FORM_OID")
        .and().eq("fieldOid", "FIELD_OID")
        .and().eq("isVisible", 1)
        .and().eq("dataPointActive", 1), null);

if (dpList.isEmpty()) return 0;
CDataPoint targetDp = dpList.get(0);
```

适用：查询条件已定位到单一目标点。

## Template 2：多点查询 + 从集合中取单点（优先推荐）

```java
List<CDataPoint> dataPoints = system().listDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", subjectId)
        .and().eq("dataPageId", dataPageId)
        .and().eq("formOid", "EASI")
        .and().in("fieldOid", Arrays.asList("QSSCORE6", "QSORRES"))
        .and().eq("dataPointActive", 1), null);

// 普通表单（masterRecord）
CDataPoint qsorresDp = dataPoints.stream()
        .filter(dataPoint -> "QSORRES".equals(dataPoint.getFieldOid()))
        .findAny().get();

// 可添加行（固定行）
CDataPoint qsorresRow3Dp = dataPoints.stream()
        .filter(dataPoint -> "QSORRES".equals(dataPoint.getFieldOid()) && dataPoint.getGridRow() == 3)
        .findAny().get();
```

适用：同一批结果内按 `fieldOid` 或 `fieldOid + gridRow` 定位。

## Template 3：可添加表单/可添加行 Map 分层（推荐例外）

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
```

适用：可添加页/可添加行、层级关系明显、需要批量联动判断。

## Template 4：Set 去重（可选）

```java
Set<String> valueSet = dataPoints.stream()
        .map(CDataPoint::getDataValue)
        .filter(StringUtils::isNotEmpty)
        .collect(Collectors.toSet());
```

适用：重复值检查、集合对比、批量存在性判断。

## Template 5：常见动作模板

### OpenQuery

```java
system().openQuery(msg, targetDp.getDataPointId(), checkId);
```

### CloseQuery

```java
system().closeQuery(targetDp.getDataPointId(), checkId);
```

### SetDataPointValue

```java
system().setDataPointValue(targetDp.getDataPointId(), "123");
```

### RenameBlock

```java
system().updateBlock(blockId, "NEW_BLOCK_NAME");
```

## 推荐输出清单（供生成代码前自检）

- 是否优先复用上述模板，而不是从零自创
- 若涉及质疑，`msg/checkId` 是否作为前置段放在 `run()` 开头
- 集合取单点是否优先使用 `fieldOid` / `fieldOid + gridRow`
- 如采用 Map/Set 方案，是否说明“因可添加行/层级处理需要”
- 是否包含必要空值检查与有效性条件
