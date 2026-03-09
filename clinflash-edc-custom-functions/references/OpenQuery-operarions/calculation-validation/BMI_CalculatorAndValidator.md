# 需求说明

## 需求名称
- **HTWT006** - 计算并校验BMI值

## 功能描述
- 当HT、WT、BMI任意一个数据点发生变化时，自动触发此Custom Function进行计算
- 计算BMI值：BMI = WT / (HT * HT)
- 将计算得到的BMI值设置到BMI数据点中
- 校验BMI值是否与计算值相等，并进行质疑的打开或关闭

## 数据点说明
- **HT**：位于任意访视的HTWT表单上，masterRecord（主记录）中的数据点，存储身高值（米）
- **WT**：位于任意访视的HTWT表单上，masterRecord（主记录）中的数据点，存储体重值（千克）
- **BMI**：位于任意访视的HTWT表单上，masterRecord（主记录）中的数据点，存储计算得到的BMI值

**数据点关系**：HT、WT、BMI位于同一访视同一表单上，且均属于同一受试者。

## 触发条件
当HT、WT、BMI任意一个数据点发生变化时，自动触发此Custom Function进行计算

## 计算逻辑
1. 获取当前受试者ID和触发数据点
2. 查询并获取当前页面的HT、WT、BMI数据点的值
3. 计算BMI值：BMI = WT / (HT * HT)
4. 将计算得到的BMI值设置到BMI数据点中
5. 校验BMI值是否与计算值相等
- 若不相等，则在BMI数据点中显示红色质疑：BMI录入值较计算值存在偏差，请核实。
- 若相等，关闭对应的BMI数据点的质疑


## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.baomidou.mybatisplus.toolkit.StringUtils;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.text.ParseException;


public class HTWT006 extends CFunction {
    @Override
    public int run() {
        Long subjectId = context().getSubjectId();
        String msg = "<font color=\"RED\">BMI录入值较计算值存在偏差，请核实。</font>";
        String checkId = "HTWT006";
        
        //获取发生变化的数据点
        CDataPoint checkDP = system().getDataPoint(context().getCheckDataPoints().get(0));
   		Long dataPageId = checkDP.getDataPageId();

        List<CDataPoint> htDp = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", dataPageId)                
                .and().eq("fieldOid", "HT"), null);
        if (htDp.size() == 0) return 0;
			
        List<CDataPoint> wtDp = system().listDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", subjectId)
        .and().eq("dataPageId", dataPageId)
        .and().eq("fieldOid", "WT"), null);
        if (wtDp.size() == 0) return 0;

        List<CDataPoint> bmiDp = system().listDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", subjectId)
        .and().eq("dataPageId", dataPageId)
        .and().eq("fieldOid", "BMI"), null);
        if (bmiDp.size() == 0) return 0;

        if(StringUtils.isEmpty(htDp.get(0).getDataValue()) || 
            StringUtils.isEmpty((wtDp.get(0).getDataValue())) ||
            StringUtils.isEmpty((bmiDp.get(0).getDataValue()))) return 0;
                
        Long datapointId = bmiDp.get(0).getDataPointId();

        String bmi = "";
        try
        {
            BigDecimal ht = new BigDecimal(htDp.get(0).getDataValue());
            BigDecimal wt = new BigDecimal(wtDp.get(0).getDataValue());
            BigDecimal htPer100 = ht.divide(BigDecimal.valueOf(100), 10, RoundingMode.HALF_UP);
            BigDecimal htSquare = htPer100.multiply(htPer100);
            bmi = wt.divide(htSquare, 1, RoundingMode.HALF_UP).stripTrailingZeros().toPlainString();

            if(!bmi.equals(bmiDp.get(0).getDataValue())){
                system().openQuery(msg, datapointId, checkId);
            }
            else{
                system().closeQuery(datapointId, checkId);
            }
        } 
        catch (Exception ignored) {
        }
        return 0;
		}
}
```