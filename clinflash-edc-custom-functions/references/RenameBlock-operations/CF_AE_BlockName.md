# 需求说明

## 需求名称
- **CF_AE_BlockName** - 重命名AE访视的AE表单上的块名称

## 功能描述
- 当AE访视的AE表单上的AETERM或第一行AESTDAT数据点发生变化时，自动触发此Custom Function进行计算
- 从当前页面的AETERM和AESTDAT数据点中获取值
- 将获取到的值设置到对应的不良事件块名称中，格式为：AETERM+"+"+AESTDAT

## 数据点说明
- **AETERM**：位于AE访视的AE表单上，masterRecord（主记录）中的数据点，存储不良事件名称
- **AESTDAT**：位于AE访视的AE表单上，可添加行上的数据点，存储不良事件每次发生的开始日期

**数据点关系**：AETERM和AESTDAT位于同一访视同一表单上，且均属于同一受试者。

## 触发条件
当表单中的AETERM或第一行AESTDAT数据点发生变化时，自动触发此Custom Function进行计算

## 计算逻辑
1. 获取当前受试者ID和触发数据点
2. 查询并获取当前页面的AETERM和第一行AESTDAT数据点的值
3. 将获取到的值设置到对应的不良事件块名称中，格式为：AETERM+"+"+AESTDAT

## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.common.utils.StringUtils;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;


public class CF_AE_BlockName extends CFunction {
    @Override
    public int run() {
        CDataPoint checkedDataPoint = system().getDataPoint(context().getCheckDataPoints().get(0));
        Long dataPageId= context().getDataPageId();
        String aetermField="AETERM";
        String aestdatField = "AESTDAT";
        List<CDataPoint> dps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("dataPageId", dataPageId)
                .and().in("fieldOid",  Arrays.asList(aetermField, aestdatField)), null);
        CDataPoint aetermDp = dps
                .stream()
                .filter(e -> aetermField.equals(e.getFieldOid()) )
                .collect(Collectors.toList())
                .get(0);
			
			List<CDataPoint> list = system().listDataPoints(new EntityWrapper<CDataPoint>()
                    .eq("subjectId",context().getSubjectId())
                    .and().eq("formOid","AE")
                    .and().eq("dataPageId",dataPageId)
                    .and().eq("fieldOid",aestdatField)
					.and().eq("GridRow",1), null);
            CDataPoint aestdatDp = list.get(0);
			
        system().updateBlock(checkedDataPoint.getBlockId(), aetermDp.getDataValue()+"+"+aestdatDp.getDataValue());
        return 0;
    }
}
```