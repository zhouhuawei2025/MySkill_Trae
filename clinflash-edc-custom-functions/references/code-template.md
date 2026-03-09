# Clinflash EDC Custom Function 代码模板

## 前置条件分析
详细的前置条件分析请参考 SKILL.md 文件中的"前置条件分析"部分。

## 文档模板
# 需求说明

## 需求名称
- **[需求ID]** - [需求名称]

## 功能描述
- 当[触发数据点]发生变化时，自动触发此Custom Function进行[操作]
- [详细功能描述]

## 数据点说明
- **[数据点1]**：位于[访视]的[表单]上，[是否为可添加行]的数据点，存储[数据点含义]
- **[数据点2]**：位于[访视]的[表单]上，[是否为可添加行]的数据点，存储[数据点含义]
- **[数据点3]**：位于[访视]的[表单]上，[是否为可添加行]的数据点，存储[数据点含义]

**数据点关系**：[描述数据点之间的关系，如同一访视、同一表单、层级关系等]

## 触发条件
当[触发数据点]发生变化时，自动触发此Custom Function进行[操作]

## 检查逻辑
1. [步骤1]
2. [步骤2]
3. [步骤3]
4. [步骤4]
5. 检查逻辑：
   - 若[条件1]，则[操作1]
   - 若[条件2]，则[操作2]

## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.baomidou.mybatisplus.toolkit.StringUtils;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.util.List;

public class [ClassName] extends CFunction {
    private static final String CHECK_OID = "[需求ID]";
    private static final String QUERY_MSG = "<font color=\"red\">[质疑消息]</font>";

    @Override
    public int run() {
        // 获取触发数据点
        CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
        Long subjectId = checkDp.getSubjectId();
        
        // 精确定位当前页面，使用dataPageId
        // Long dataPageId = checkDp.getDataPageId();
        
        // 精确定位当前访视，使用instanceId
        // Long instanceId = checkDp.getInstanceId();
        
        // 查询相关数据点
        List<CDataPoint> [dataPoint1]List = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                // 根据需要添加其他条件
                .and().eq("[条件字段]", "[条件值]")
                .and().eq("fieldOid", "[数据点1]")
                , null);
        
        // 检查数据点是否存在
        if ([dataPoint1]List.isEmpty()) return 0;

        //查询数据点的最佳实践：
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
        
        
        // 业务逻辑处理
        // ...
        
        // 执行EDC操作
        // system().openQuery(QUERY_MSG, [targetDataPointId], ClassName);
        // system().closeQuery([targetDataPointId], ClassName);
        
        return 0;
    }
}
```

## 代码优化建议

### 1. 数据点查询优化
- **使用合适的查询条件**：根据数据点类型选择使用dataPageId（主记录）或instanceId（可添加表单/行）
- **添加必要的过滤条件**：如isVisible、datapointActive等，确保只查询有效数据点
- **使用listVisibleDataPoints**：对于需要考虑可见性的数据点，使用此方法

### 2. 错误处理
- **添加空值检查**：对数据点值进行空值检查，避免空指针异常
- **添加异常捕获**：捕获可能的异常，确保代码稳定运行
- **添加日志记录**：在关键步骤添加日志，便于调试和问题排查

### 3. 性能优化
- **减少API调用**：尽量使用一次查询获取多个数据点
- **使用Stream API**：对于数据处理，使用Stream API提高代码可读性和效率
- **缓存重复计算**：对于重复计算的结果，使用变量缓存

### 4. 代码结构
- **模块化**：将复杂逻辑拆分为多个方法
- **命名规范**：使用清晰的变量和方法命名
- **注释**：为关键代码添加注释，提高代码可维护性

### 5. 数据点关系处理
- **层级数据处理**：对于有层级关系的数据点，使用合适的查询和处理方式
- **批量操作**：对于多个数据点的相同操作，使用批量处理
- **数据一致性**：确保数据点之间的一致性，避免逻辑冲突

## 示例：处理可添加行数据点

详细的处理可添加行数据点示例请参考 SKILL.md 文件中的"高级功能"部分和 `references/edc-example-usage.md` 文件中的相关实现。

## 示例：处理日期时间数据

详细的日期时间处理示例请参考 SKILL.md 文件中的"高级功能"部分和 `references/edc-example-usage.md` 文件中的相关实现。
