# 需求说明

## 需求名称
- **GetAESTDAT** - 获取第一行AESTDAT值

## 功能描述
- 当第一行AESTDAT数据点发生变化时，自动触发此Custom Function进行计算
- 从当前页面的第一行AESTDAT数据点中获取值
- 将获取到的值设置到对应的AEPSTDAT数据点中

## 数据点说明
- **AESTDAT**：位于AE访视的AE表单上，可添加行上的数据点，存储不良事件每次发生的开始日期
- **AEPSTDAT**：位于AE访视的AE表单上，masterRecord（主记录）中的数据点，用于存储不良事件第一次发生的开始日期

**数据点关系**：AESTDAT和AEPSTDAT位于同一访视同一表单上，且均属于同一受试者。

## 触发条件
当表单中的AESTDAT数据点发生变化时，自动触发此Custom Function进行计算

## 计算逻辑
1. 获取当前受试者ID和触发数据点
2. 查询并获取第一行AESTDAT数据点的值
3. 将获取到的值设置到AEPSTDAT数据点中

## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.baomidou.mybatisplus.toolkit.StringUtils;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.util.List;
import java.util.stream.Collectors;


public class GetAESTDAT extends CFunction {
    @Override
    public int run() {

    Long subjectId = context().getSubjectId();
    CDataPoint checkDP = system().getDataPoint(context().getCheckDataPoints().get(0));
    Long dataPageId = checkDP.getDataPageId();

        List<CDataPoint> dpHIDDENs = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", dataPageId)
                .and().eq("fieldOid", "AEPSTDAT"), null);
                                
                CDataPoint dpHIDDEN = dpHIDDENs.get(0);
                        
        List<CDataPoint> dpAESTDATs = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", dataPageId)
                .and().eq("fieldOid", "AESTDAT")
                .and().eq("gridRow", 1), null);
                        
                CDataPoint dpAESTDAT = dpAESTDATs.get(0);
                                
    try
    {                                
            system().setDataPointValue(dpHIDDEN.getDataPointId(), dpAESTDAT.getDataValue());
    }
    catch (Exception ignored)
    {
            system().setDataPointValue(dpHIDDEN.getDataPointId(), "");
    }
        return 0;
    }
}
```