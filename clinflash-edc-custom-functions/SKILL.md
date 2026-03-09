---
name: Clinflash EDC Custom Functions
description: 为Java程序员提供EDC（电子数据采集）系统数据点操作的代码生成工具。用于快速创建获取EDC系统数据点、进行数据处理和操作的Java函数。适用于需要与EDC系统集成、处理临床试验数据的开发场景。
---

# EDC Custom Functions

## 功能概述

本技能为Java程序员提供Clinflash EDC（易迪希电子数据采集）系统数据点操作的代码生成能力。通过简单的描述，生成高质量的Java代码，用于：

- 获取EDC系统中的数据点
- 对数据点进行处理和转换
- 执行数据验证和质量检查
- 与其他系统集成的数据处理
- 执行各种EDC操作（如设置质疑、重命名Block、计算衍生值等）

## 使用方法

### 基本用法

用户只需描述需要实现的功能，例如：

- "创建一个Java函数，从EDC系统获取患者的实验室数据"
- "编写一个函数，计算两个数据点之间的时间差"
- "生成一个函数，验证数据点的完整性"

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

详细的代码模板和示例请参考以下文件：
- `references/code-template.md` - 代码模板（必读）
- `references/edc-api-reference.md` - EDC系统API参考（必读）
- `references/edc-example-usage.md` - EDC使用示例（必读）
- `references/OpenQuery-operarions/` - 质疑操作示例
  - `references/OpenQuery-operarions/calculation-validation/` - 计算与验证相关
    - `BMI_CalculatorAndValidator.md` - BMI计算与验证
    - `QTCF_CalculatorValidator.md` - QTCF计算与验证
    - `RR_CalculatorValidator.md` - RR值计算与验证
    - `TotalScoreValidator.md` - 总分计算与验证
  - `references/OpenQuery-operarions/date-time/` - 日期时间相关
    - `DateDuplicateValidator.md` - 日期重复检查
    - `DateTimeCompareValidator.md` - 跨表单的日期时间比较
    - `EarlyExitVisitDateValidator.md` - 跨表单的日期比较
    - `STDAT_ENDAT_LogicValidator.md` - 可添加行上的开始日期和结束日期逻辑检查
  - `references/OpenQuery-operarions/duplicate-check/` - 重复值检查相关
    - `IE_DuplicateValidator.md` - 可添加行中数据点的重复检查
    - `VSTPT_DuplicateValidator.md` - 可添加页中数据点的重复检查
  - `references/OpenQuery-operarions/other-validation/` - 其他验证相关
    - `AESeverity_LoglineNum_Validator.md` - AE严重程度和日志行行数验证
    - `BaselineScoreValidator.md` - 基线评分检查
- `references/RenameBlock-operations/` - 重命名Block操作示例
  - `CF_AE_BlockName.md` - AE表单Block重命名
  - `CF_ISR_BlockName.md` - ISR表单Block重命名
- `references/SetDatapointValue-operations/` - 设置数据点值操作示例
  - `calculateEGFR.md` - EGFR计算
  - `calculateHEARTaverage.md` - 心率平均值计算
  - `calculateLABAGE.md` - 实验室年龄计算
  - `calculateQTCFaverage.md` - QTCF平均值计算
  - `getAESTDAT.md` - 获取AESTDAT数据点

### 代码生成流程

1. **分析需求**：理解用户描述的功能需求
2. **前置分析**：厘清数据点信息、关系和触发条件
3. **生成代码**：根据需求生成符合Java标准的代码
4. **提供说明**：为生成的代码提供详细的注释和使用说明

## 代码结构

生成的代码通常包含以下部分：

1. **导入语句**：必要的Java包导入
2. **函数定义**：完整的函数实现
3. **参数说明**：函数参数的详细说明
4. **返回值**：函数返回值的类型和含义
5. **异常处理**：可能的异常情况处理
6. **使用示例**：函数的使用示例

## 示例模板

### 基础数据点获取函数

```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;
import java.util.List;

public class EdcDataFetcher extends CFunction {
    @Override
    public int run() {
        //如需质疑，取消注释下面两行，配合system().openQuery(msg, xxx.getDataPointId(), checkId); 和 system().closeQuery(xxx.getDataPointId(), checkId);使用
        //String msg = "<font color=\"RED\">query text</font>";
        //String checkId = "ThisCustomFunctionName";

        // 获取触发数据点
        CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
        Long subjectId = checkDp.getSubjectId();
        
        //查询数据的最佳实践：
        // 1. 查询单个数据点
        List<CDataPoint> dpList = system().listVisibleDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("formOid", "FORM_OID")
                .and().eq("fieldOid", "FIELD_OID")
                .and().eq("isVisible", 1)
                .and().eq("datapointActive", 1), null);
        
        // 处理数据点
        if(dpList.isEmpty()) return 0;

        CDataPoint targetDp = dpList.get(0);
        String value = targetDp.getDataValue();
        // 处理数据...

        // 2. 查询特定表单的多个数据点
        List<CDataPoint> dataPoints = system().listDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", subjectId)
        .and().eq("dataPageId", dataPageId)
        .and().eq("formOid", "EASI")
        .and().in("fieldOid", Arrays.asList("QSSCORE6", "QSORRES"))
        .and().eq("dataPointActive", 1), null);

        // 从集合中获取单个数据点
        // a. 如果表单为普通表单（只包含masterRecord，不包含可添加行）
        // QSORRES为masterRecord上的单个数据点
        CDataPoint qsorredDp = dataPoints.stream()
                .filter(dataPoint -> "QSORRES".equals(dataPoint.getFieldOid()))
                .findAny().get();
        if(StringUtils.isEmpty(qsorredDp.getDataValue())) return 0;

        // b. 如果表单为复合表单（包含masterRecord和可添加行）
        // QSORRES为masterRecord上的单个数据点
        CDataPoint qsorredDp2 = dataPoints.stream()
                .filter(dataPoint -> "QSORRES".equals(dataPoint.getFieldOid()) && dataPoint.getGridRow() == 1)
                .findAny().get();
        if(StringUtils.isEmpty(qsorredDp2.getDataValue())) return 0;

        // QSSCORE6为可添加行上的数据点
        for(CDataPoint qsscore6Dp : dataPoints.stream()
                .filter(dataPoint -> "QSSCORE6".equals(dataPoint.getFieldOid()))
                .collect(Collectors.toList())) {
            // 处理可添加行上的数据点...
        }

        // c. 获取QSSCORE6在第三行上的数据点（一般用于固定行）
        CDataPoint qsscore6DpThird = dataPoints.stream()
                .filter(dataPoint -> "QSSCORE6".equals(dataPoint.getFieldOid()) && dataPoint.getGridRow() == 3)
                .findAny().get();
        if(StringUtils.isEmpty(qsscore6DpThird.getDataValue())) return 0;
        // 处理数据...     
        
        return 0;
    }
}
```

## 高级功能

### 1. 计算与验证

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

### 2. 日期处理

**年龄计算**
```java
// 计算年龄
LocalDate birthDate = LocalDate.parse(birthdayDp.getDataValue(), DATE_FORMATTER);
LocalDate visitDate = LocalDate.parse(visitDp.getDataValue(), DATE_FORMATTER);
long diffDays = birthDate.until(visitDate, ChronoUnit.DAYS);
int age = (int) (diffDays / 365.25);
system().setDataPointValue(ageDp.getDataPointId(), String.valueOf(age));
```

### 3. 层级数据点处理

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
```

### 4. 质疑操作

```java
// 打开质疑
String msg = "<font color=\"RED\">RR间期录入值较计算值存在偏差，请核实。</font>";
system().openQuery(msg, rrDp.getDataPointId(), "RR_CHECK");

// 关闭质疑
system().closeQuery(rrDp.getDataPointId(), "RR_CHECK");
```



## 注意事项

1. **EDC SDK依赖**：生成的代码假设您已经添加了EDC系统的Java SDK依赖
2. **异常处理**：根据实际EDC系统的异常类型调整异常处理代码
3. **认证配置**：实际使用时需要根据EDC系统的要求配置认证信息
4. **性能优化**：对于大量数据点的操作，可能需要添加缓存或批量处理逻辑

## 后续扩展

随着您提供更多的背景信息、已封装的函数和示例，本技能将能够生成更加符合您特定EDC系统需求的代码。