# 需求说明

## 需求名称
AVGHR - 心率平均值计算

## 功能描述
当表单中存在3行有效的可添加行，且每行的HEART数据点值均不为空时，计算这3个心率值的平均值，并将结果衍生到当前页面的HEARTAV数据点中；否则，将HEARTAV数据点设置为空。

## 数据点说明
- **HEART**：位于任意访视的EG表单上，可添加行上的数据点，存储单次心率值
- **HEARTAV**：位于任意访视的EG表单上，masterRecord（主记录）中的数据点，用于存储计算得到的心率平均值

## 触发条件
当表单中的HEART数据点发生变化时，自动触发此Custom Function进行计算

**数据点关系**：HEART和HEARTAV位于同一访视同一表单上，且均属于同一受试者。

## 计算逻辑
1. 获取当前受试者ID和触发数据点
2. 查询当前页面所有激活状态的HEART数据点
3. 检查是否存在3个有效的HEART数据点
4. 如果满足条件，计算平均值并设置到HEARTAV
5. 如果不满足条件，将HEARTAV设置为空

## 代码实现：
```java 

import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

public class AVGHR extends CFunction {
    @Override
    public int run() {
        Long subjectId = context().getSubjectId();
        List<Long> dataPointIdList = context().getCheckDataPoints();
        Long checkDataPointId = dataPointIdList.get(0);
        List<CDataPoint> dataPointList = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("dataPointId", checkDataPointId), null);

        //获取当前触发数据点的页面信息， 得到数据页 id
        Long dataPageId = dataPointList.get(0).getDataPageId();
        List<CDataPoint> dpHEARTs = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", dataPageId)
                .and().eq("fieldOid", "HEART")
                .and().eq("dataPointActive", 1), null);
        List<CDataPoint> dpHEARTAV = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", dataPageId)
                .and().eq("fieldOid", "HEARTAV"), null);

        CDataPoint dp = dpHEARTAV.get(0);


        if (dpHEARTs.size() == 3) {
            try {
                //计算平均值
                BigDecimal sum = dpHEARTs.stream().map(e -> new BigDecimal(e.getDataValue())).reduce(BigDecimal::add).get();
                BigDecimal val = sum.divide(new BigDecimal("3"), 0, RoundingMode.HALF_UP);
                system().setDataPointValue(dp.getDataPointId(), val.stripTrailingZeros().toPlainString());
            } catch (Exception e) {
                system().setDataPointValue(dp.getDataPointId(), "");
            }
        } else {
            system().setDataPointValue(dp.getDataPointId(), "");
        }

        return 0;
    }
}
```