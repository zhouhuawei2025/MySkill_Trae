# Clinflash EDC Custom Functions 技能

## 技能概述

本技能为Java程序员提供Clinflash EDC（易迪希电子数据采集）系统数据点操作的代码生成工具。通过简单的描述，生成高质量的Java代码，用于：

- 获取EDC系统中的数据点
- 对数据点进行处理和转换
- 执行数据验证和质量检查
- 与其他系统集成的数据处理
- 执行各种EDC操作（如激活/隐藏数据点、设置质疑等）

## 技能结构

```
clinflashEDC-custom-functions/
├── SKILL.md              # 技能主文件
├── README.md             # 项目说明文档
└── references/           # 参考文档
    ├── code-template.md  # 代码模板
    ├── edc-api-reference.md  # EDC系统API参考
    ├── edc-example-usage.md  # EDC使用示例
    ├── OpenQuery-operations/  # 质疑操作示例
    │   ├── calculation-validation/  # 计算与验证相关
    │   │   ├── BMI_CalculatorAndValidator.md  # BMI计算与验证
    │   │   ├── QTCF_CalculatorValidator.md  # QTCF计算与验证
    │   │   ├── RR_CalculatorValidator.md  # RR值计算与验证
    │   │   └── TotalScoreValidator.md  # 总分计算与验证
    │   ├── date-time/  # 日期时间相关
    │   │   ├── DateDuplicateValidator.md  # 日期重复检查
    │   │   ├── DateTimeCompareValidator.md  # 跨表单的日期时间比较
    │   │   ├── EarlyExitVisitDateValidator.md  # 跨表单的日期比较
    │   │   └── STDAT_ENDAT_LogicValidator.md  # 可添加行上的开始日期和结束日期逻辑检查
    │   ├── duplicate-check/  # 重复值检查相关
    │   │   ├── IE_DuplicateValidator.md  # 可添加行中数据点的重复检查
    │   │   └── VSTPT_DuplicateValidator.md  # 可添加页中数据点的重复检查
    │   └── other-validation/  # 其他验证相关
    │       ├── AESeverity_LoglineNum_Validator.md  # AE严重程度和日志行行数验证
    │       └── BaselineScoreValidator.md  # 基线评分检查
    ├── RenameBlock-operations/  # 重命名Block操作示例
    │   ├── CF_AE_BlockName.md  # AE表单Block重命名
    │   └── CF_ISR_BlockName.md  # ISR表单Block重命名
    └── SetDatapointValue-operations/  # 设置数据点值操作示例
        ├── calculateEGFR.md  # EGFR计算
        ├── calculateHEARTaverage.md  # 心率平均值计算
        ├── calculateLABAGE.md  # 实验室年龄计算
        ├── calculateQTCFaverage.md  # QTCF平均值计算
        └── getAESTDAT.md  # 获取AESTDAT数据点
```

## 背景知识

### Custom Function 结构

Custom Function的基本结构如下：

```java
import xxxxxxx;
import xxxxxxx;
....
import xxxxxxx;

//ThisCustomFunctionName的名称由用户提供
public class ThisCustomFunctionName extends CFunction {
    @Override
    public int run() {
        //step0: 如果与质疑相关需要下面两行模式代码，配合system().openQuery(msg, xxx.getDataPointId(), checkId); 和 system().closeQuery(xxx.getDataPointId(), checkId);使用
        //String msg = "<font color=\"RED\">query text</font>";
        //String checkId = "ThisCustomFunctionName";

        //step1: 从EDC获取输入数据点参数
        //常用方法和示例见 edc-api-reference.md 章节, 数据查询示例, 获取触发Custom Function的数据点

        //step2: 数据处理、计算或判断，以及其他的复杂操作
        //常用方法和示例见 edc-api-reference.md 章节, 数据查询示例, 获取当前表单的数据点

        //step3: 根据判断结果，进行不同的EDC操作
        //常用方法和示例见 edc-api-reference.md 章节, 数据操作示例

        return 0;
    }

    //可选：step4: 自定义函数(可以有出参，也可以没有出参)
    public void customFunction() {
        // 自定义函数的实现
    }
}
```

### 核心概念

1. **CFunction**：Custom Function的基类，所有Custom Function都需要继承此类
2. **CDataPoint**：数据点类，代表EDC系统中的一个数据点
3. **Context**：上下文对象，用于获取当前操作的相关信息
4. **System**：系统对象，用于执行EDC操作

## 主要功能

### 1. 数据点获取

- 获取触发Custom Function的数据点
- 获取当前表单的数据点集合
- 按层级获取数据点（适用于可添加页和可添加行的表单）
- 从集合中获取单个数据点

### 2. 数据点操作

- 设置数据点值
- 激活/隐藏数据点
- 打开/关闭质疑
- 设置受试者状态
- 添加/更新instance和block
- 添加行结构的一行

### 3. 日期处理

- 处理空日期或UK日期
- 将UK日期转换为完整日期
- 组合日期和时间数据点
- 对日期数据点进行排序

### 4. 其他功能

- 计算年龄
- 数据验证
- 错误处理

## 使用方法

### 基本用法

用户只需描述需要实现的功能，例如：

- "创建一个Java函数，从EDC系统获取患者的实验室数据"
- "编写一个函数，计算两个数据点之间的时间差"
- "生成一个函数，验证数据点的完整性"
- "创建一个函数，处理AE表单中的日期数据"

### 前置条件分析

在书写代码前，需要厘清以下信息：

1. **数据点基本信息**：
   - 访视：数据点所在的访视（folderOid）
   - 表单：数据点所在的表单（formOid）
   - 类型：是否为可添加行上的数据点（gridRow）
   - 字段：数据点的字段标识（fieldOid）

2. **数据点关系**：
   - 同一访视：多个数据点是否位于同一访视
   - 同一表单：多个数据点是否位于同一表单
   - 层级关系：是否存在block、instance、gridRow等层级关系
   - 依赖关系：数据点之间的依赖关系

3. **触发条件**：
   - 触发数据点：哪些数据点的变化会触发此Custom Function
   - 触发时机：数据点变化时的触发时机

4. **业务逻辑**：
   - 功能描述：Custom Function的具体功能
   - 检查逻辑：数据验证或计算的具体逻辑
   - 操作类型：需要执行的EDC操作（如设置质疑、设置数据点值等）

详细的代码模板和示例请参考以下文件，进一步细分示例请参考章节【完整示例分类】的描述：
- `references/code-template.md` - 代码模板
- `references/edc-api-reference.md` - EDC系统API参考
- `references/edc-example-usage.md` - EDC使用示例
- `references/OpenQuery-operations/` - 质疑操作示例
- `references/RenameBlock-operations/` - 重命名Block操作示例
- `references/SetDatapointValue-operations/` - 设置数据点值操作示例

完整的示例分类请参考下面的"完整示例分类"部分。

### 代码生成流程

1. **分析需求**：理解用户描述的功能需求
2. **前置分析**：厘清数据点信息、关系和触发条件
3. **生成代码**：根据需求生成符合Java标准的代码
4. **提供说明**：为生成的代码提供详细的注释和使用说明

## 示例代码

### 基础操作示例

#### 获取触发数据点

```java
// 获取触发Custom Function的数据点
List<Long> dataPointIdList = context().getCheckDataPoints();
Long checkDataPointId = dataPointIdList.get(0);
CDataPoint checkDp = system().getDataPoint(checkDataPointId);
```

#### 获取当前表单数据点

```java
// 获取当前页面ID和受试者ID
Long dataPageId = context().getDataPageId();
Long subjectId = context().getSubjectId();

// 查询特定表单的多个数据点
List<CDataPoint> dataPoints = system().listDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", subjectId)
        .and().eq("dataPageId", dataPageId)
        .and().eq("formOid", "EASI")
        .and().in("fieldOid", Arrays.asList("QSSCORE6", "QSORRES")), null);
```

### 高级功能示例

#### 1. 计算与验证示例

**BMI计算与验证**
```java
// 计算BMI值：BMI = WT / (HT * HT)
BigDecimal ht = new BigDecimal(htDp.getDataValue());
BigDecimal wt = new BigDecimal(wtDp.getDataValue());
BigDecimal bmi = wt.divide(ht.multiply(ht), 2, RoundingMode.HALF_UP);

// 验证BMI值是否与输入值一致
if (!bmi.stripTrailingZeros().toPlainString().equals(bmiDp.getDataValue())) {
    system().openQuery("BMI录入值较计算值存在偏差，请核实。", bmiDp.getDataPointId(), "BMI_CHECK");
} else {
    system().closeQuery(bmiDp.getDataPointId(), "BMI_CHECK");
}
```

**心率平均值计算**
```java
// 计算3个心率值的平均值
if (heartDps.size() == 3) {
    BigDecimal sum = heartDps.stream()
            .map(e -> new BigDecimal(e.getDataValue()))
            .reduce(BigDecimal::add)
            .get();
    BigDecimal average = sum.divide(new BigDecimal("3"), 0, RoundingMode.HALF_UP);
    system().setDataPointValue(heartAvDp.getDataPointId(), average.stripTrailingZeros().toPlainString());
} else {
    system().setDataPointValue(heartAvDp.getDataPointId(), "");
}
```

#### 2. 日期处理示例

**处理日期数据点**
```java
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

public LocalDate processDate(CDataPoint datePoint) {
    String dateStr = datePoint.getDataValue();
    
    // 若日期为空或包含UK，返回默认日期
    if (dateStr == null || dateStr.trim().isEmpty() || dateStr.toUpperCase().contains("UK")) {
        return LocalDate.parse("2050-01-01", DATE_FORMATTER);
    }
    
    try {
        // 解析日期
        return LocalDate.parse(dateStr, DATE_FORMATTER);
    } catch (Exception e) {
        return LocalDate.parse("2050-01-01", DATE_FORMATTER);
    }
}
```

**年龄计算**
```java
// 计算年龄
LocalDate birthDate = LocalDate.parse(birthdayDp.getDataValue(), DATE_FORMATTER);
LocalDate visitDate = LocalDate.parse(visitDp.getDataValue(), DATE_FORMATTER);
long diffDays = birthDate.until(visitDate, ChronoUnit.DAYS);
int age = (int) (diffDays / 365.25);
system().setDataPointValue(ageDp.getDataPointId(), String.valueOf(age));
```

#### 3. 层级数据点处理

```java
// 构建层级Map：BlockRepeatNumber -> GridRow -> FieldOid -> CDataPoint
Map<Integer, Map<Integer, Map<String, CDataPoint>>> dataPointMap = system().listDataPoints(
        new EntityWrapper<CDataPoint>()
                .eq("folderOid", "AE")
                .and().eq("formOid", "AE")
                .and().in("fieldOid", Arrays.asList("AESTDAT", "AEENDAT", "AEACN")), null)
        .stream().collect(Collectors.groupingBy(CDataPoint::getBlockRepeatNumber,
                Collectors.groupingBy(CDataPoint::getGridRow,
                        Collectors.toMap(CDataPoint::getFieldOid, o -> o, (o1, o2) -> o1))));

// 遍历层级数据
for (int blockRepeatNumber : dataPointMap.keySet()) {
    Map<Integer, Map<String, CDataPoint>> rowMap = dataPointMap.get(blockRepeatNumber);
    for (Map.Entry<Integer, Map<String, CDataPoint>> rowEntry : rowMap.entrySet()) {
        int gridRow = rowEntry.getKey();
        Map<String, CDataPoint> fieldMap = rowEntry.getValue();
        
        CDataPoint aestdatDp = fieldMap.get("AESTDAT");
        CDataPoint aeendatDp = fieldMap.get("AEENDAT");
        // 处理数据...
    }
}
```

#### 4. 质疑操作示例

```java
// 打开质疑
String msg = "<font color=\"RED\">RR间期录入值较计算值存在偏差，请核实。</font>";
system().openQuery(msg, rrDp.getDataPointId(), "RR_CHECK");

// 关闭质疑
system().closeQuery(rrDp.getDataPointId(), "RR_CHECK");
```

### 完整示例分类

#### 1. 质疑操作 (OpenQuery-operations)

##### 1.1 计算与验证相关 (calculation-validation)
- **BMI_CalculatorAndValidator.md** - BMI计算与验证
- **QTCF_CalculatorValidator.md** - QTCF计算与验证
- **RR_CalculatorValidator.md** - RR值计算与验证
- **TotalScoreValidator.md** - 总分计算与验证

##### 1.2 日期时间相关 (date-time)
- **DateDuplicateValidator.md** - 日期重复检查
- **DateTimeCompareValidator.md** - 跨表单的日期时间比较
- **EarlyExitVisitDateValidator.md** - 跨表单的日期比较
- **STDAT_ENDAT_LogicValidator.md** - 可添加行上的开始日期和结束日期逻辑检查

##### 1.3 重复值检查相关 (duplicate-check)
- **IE_DuplicateValidator.md** - 可添加行中数据点的重复检查
- **VSTPT_DuplicateValidator.md** - 可添加页中数据点的重复检查

##### 1.4 其他验证相关 (other-validation)
- **AESeverity_LoglineNum_Validator.md** - AE严重程度和日志行行数验证
- **BaselineScoreValidator.md** - 基线评分检查

#### 2. 重命名Block操作 (RenameBlock-operations)
- **CF_AE_BlockName.md** - AE表单Block重命名
- **CF_ISR_BlockName.md** - ISR表单Block重命名

#### 3. 设置数据点值操作 (SetDatapointValue-operations)
- **calculateEGFR.md** - EGFR计算
- **calculateHEARTaverage.md** - 心率平均值计算
- **calculateLABAGE.md** - 实验室年龄计算
- **calculateQTCFaverage.md** - QTCF平均值计算
- **getAESTDAT.md** - 获取AESTDAT数据点

## 注意事项

1. **EDC SDK依赖**：生成的代码假设您已经添加了EDC系统的Java SDK依赖
2. **异常处理**：根据实际EDC系统的异常类型调整异常处理代码
3. **认证配置**：实际使用时需要根据EDC系统的要求配置认证信息
4. **性能优化**：对于大量数据点的操作，可能需要添加缓存或批量处理逻辑
5. **数据验证**：在设置数据点值之前，应进行适当的数据验证

## 最佳实践

1. **代码组织**：将复杂逻辑拆分为多个方法，提高代码可读性
2. **错误处理**：妥善处理异常，避免程序崩溃
3. **性能优化**：使用批量操作减少API调用，使用并行处理提高效率
4. **代码注释**：为关键代码添加详细注释，提高可维护性

## 后续扩展

随着您提供更多的背景信息、已封装的函数和示例，本技能将能够生成更加符合您特定EDC系统需求的代码。

## 联系与支持

如果您在使用本技能过程中遇到任何问题或需要进一步的支持，请随时联系我们。