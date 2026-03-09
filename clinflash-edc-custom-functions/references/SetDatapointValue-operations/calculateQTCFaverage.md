# 需求说明

## 需求名称
AVG_QTcF - QTCF平均值计算

## 功能描述
计算表单中可添加行的QTCF数据点的平均值(需排除空值及被失活的行)，并将结果衍生到当前页面的QTCFAV数据点中；否则，将QTCFAV数据点设置为空。

## 数据点说明
- **QTCF**：位于任意访视的EG表单上，可添加行上的数据点，存储单次QTCF值
- **QTCFAV**：位于任意访视的EG表单上，masterRecord（主记录）中的数据点，用于存储计算得到的QTCF平均值

**数据点关系**：QTCF和QTCFAV位于同一访视同一表单上，且均属于同一受试者。

## 触发条件
当表单中的QTCF数据点发生变化时，自动触发此Custom Function进行计算

## 计算逻辑
1. 获取当前受试者ID和触发数据点
2. 查询当前页面所有激活状态的QTCF数据点
3. 检查是否存在有效QTCF数据点(排除空值及被失活的行)
4. 如果满足条件，计算平均值并设置到QTCFAV
5. 如果不满足条件，将QTCFAV设置为空

## 代码实现：
```java 
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;
import com.baomidou.mybatisplus.toolkit.StringUtils;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;


public class AVG_QTcF extends CFunction {
    @Override
    public int run() {
        Long subjectId = context().getSubjectId();
        List<Long> dataPointIdList = context().getCheckDataPoints();
        Long checkDataPointId = dataPointIdList.get(0);
        List<CDataPoint> dataPointList = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("dataPointId", checkDataPointId), null);
    
        //获取当前触发数据点的页面信息， 得到数据页 id
        Long dataPageId = dataPointList.get(0).getDataPageId();
        List<CDataPoint> dpQTCFs = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", dataPageId)
                .and().eq("fieldOid", "QTCF")
                .and().eq("dataPointActive", 1), null);
        List<CDataPoint> dpQTCFAV = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", dataPageId)
                .and().eq("fieldOid", "QTCFAV"), null);
    
        CDataPoint dp = dpQTCFAV.get(0);
        int count = 0;
        for(int i = 0; i < dpQTCFs.size(); i++)
        {
        if(StringUtils.isNotEmpty(dpQTCFs.get(i).getDataValue()))
         {
             count ++;
         }
        }
    
        if (count > 0) {
            try {
                //计算平均值
                BigDecimal sum = dpQTCFs.stream().map(e -> new BigDecimal(e.getDataValue())).reduce(BigDecimal::add).get();
                BigDecimal val = sum.divide(BigDecimal.valueOf(count), 0, RoundingMode.HALF_UP);
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