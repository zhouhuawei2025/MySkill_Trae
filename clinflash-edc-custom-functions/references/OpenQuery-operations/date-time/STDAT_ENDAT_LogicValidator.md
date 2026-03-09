# 需求说明

## 需求名称
- **AE005** - 不良事件日期逻辑检查

## 功能描述
- 当AE表单中的AESTDAT或AEENDAT数据点发生变化时，自动触发此Custom Function进行检查
- 检查当前行的AESTDAT是否等于前一行的AEENDAT或前一行AEENDAT的后一天
- 若不满足条件，在AESTDAT数据点中显示红色质疑
- 若满足条件，关闭对应的AESTDAT数据点的质疑

## 数据点说明
- **AESTDAT**：位于AE表单上，可添加行上的数据点，存储不良事件开始日期
- **AEENDAT**：位于AE表单上，可添加行上的数据点，存储不良事件结束日期

**数据点关系**：AESTDAT和AEENDAT位于同一访视同一表单的同一行上，且均属于同一受试者。

## 触发条件
当AE表单中的AESTDAT或AEENDAT数据点发生变化时，自动触发此Custom Function进行检查

## 检查逻辑
1. 获取当前页面所有激活状态的AESTDAT和AEENDAT数据点
2. 按行号对数据点进行排序
3. 从第二行开始逐行检查，跳过inactive的record
4. 检查当前行的AESTDAT是否等于前一行的AEENDAT或前一行AEENDAT的后一天
- 若不满足条件，则在AESTDAT数据点中显示红色质疑：不良事件[开始日期]不等于[结束日期]或不等于上一条[结束日期]的后一天，请核实。
- 若满足条件，关闭对应的AESTDAT数据点的质疑
- 若日期解析失败，也关闭质疑

## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Comparator;
import java.util.stream.Collectors;

public class AE005 extends CFunction {

    private final DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    public int run() {
        String queryStr = "<FONT COLOR=\"RED\">不良事件[开始日期]不等于[结束日期]或不等于上一条[结束日期]的后一天，请核实。</FONT>";
        List<CDataPoint> AESTDAT = getField("AESTDAT");
        List<CDataPoint> AEENDAT = getField("AEENDAT");
        AESTDAT.sort((o1, o2) -> Integer.compare(o1.getGridRow(), o2.getGridRow()));
		AEENDAT.sort((o1, o2) -> Integer.compare(o1.getGridRow(), o2.getGridRow()));
		//从第二行开始检查，跳过inactive的record
        for(int i = 1; i < AESTDAT.size();i++)
        {
            try {
                    LocalDate lastEndDate = LocalDate.parse(AEENDAT.get(i-1).getDataValue(), fmt);
                    LocalDate date = LocalDate.parse(AESTDAT.get(i).getDataValue(), fmt);
                    if (!date.isEqual(lastEndDate.plusDays(1)) && !date.isEqual(lastEndDate)) {
                        system().openQuery(queryStr, AESTDAT.get(i).getDataPointId());
                    } else {
                        system().closeQuery(AESTDAT.get(i).getDataPointId());
                    }
                }
                catch (Exception e) {
                    system().closeQuery(AESTDAT.get(i).getDataPointId());
                }
        }
        return 0;
    }

    private List<CDataPoint> getField(String fieldOid) {
        return system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("dataPageId", context().getDataPageId())
                .and().eq("fieldOid", fieldOid)
                .and().eq("recordActive", "1"), null);
    }
}
```
