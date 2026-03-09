# 需求说明

## 需求名称
- **CF_ISR_BlockName** - 重命名ISR访视的ISR表单上的块名称

## 功能描述
- 当ISR访视的ISR表单上的ISRAE数据点发生变化时，自动触发此Custom Function进行计算
- 从当前页面的ISRAE数据点中获取值
- 将获取到的值设置到对应的ISR块名称中

## 数据点说明
- **ISRAE**：位于ISR访视的ISR表单上，masterRecord（主记录）中的数据点，存储注射部位反应量表值

## 触发条件
当表单中的ISRAE数据点发生变化时，自动触发此Custom Function进行计算

## 计算逻辑
1. 获取当前受试者ID和触发数据点
2. 查询并获取当前页面的ISRAE数据点的值
3. 将获取到的值设置到对应的ISR块名称中
- 若ISRAE值为空，则将ISR块名称设置为空字符串
- 若ISRAE值不为空，则将ISR块名称设置为ISRAE值

## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.common.utils.StringUtils;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class CF_ISR_BlockName extends CFunction {
    @Override
	 	public int run() {
        CDataPoint checkedDataPoint = system().getDataPoint(context().getCheckDataPoints().get(0));
        Long dataPageId= context().getDataPageId();
        String israeField="ISRAE";
        List<CDataPoint> dps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("dataPageId", dataPageId)
                .and().in("fieldOid",   Arrays.asList(israeField)), null);
        CDataPoint israeDp = dps
                .stream()
                .filter(e -> israeField.equals(e.getFieldOid()) )
                .collect(Collectors.toList())
                .get(0);
	
      system().updateBlock(checkedDataPoint.getBlockId(), israeDp.getDataValue());
        return 0;
    }
}
```