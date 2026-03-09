# 需求说明

## 需求名称
- **EG010** - 计算RR值

## 功能描述
- 当HEART或RR数据点发生变化时，自动触发此Custom Function进行计算
- 逐行计算RR值：RR = 60000 / HEART
- 逐行校验RR值与计算值相等，并进行质疑的打开或关闭

## 数据点说明
- **HEART**：位于任意访视的EG表单上，可添加行上的数据点，存储心率值（次/分）
- **RR**：位于任意访视的EG表单上，可添加行上的数据点，存储RR间期值（毫秒）

**数据点关系**：HEART和RR位于同一访视同一表单的同一行上，且均属于同一受试者。

## 触发条件
当表单中的HEART或RR数据点发生变化时，自动触发此Custom Function进行计算

## 计算逻辑
1. 获取当前受试者ID和触发数据点
2. 查询并获取当前行的HEART和RR数据点的值
3. 计算RR值：RR = 60000 / HEART
4. 校验RR值是否与计算值相等
- 若不相等，则在RR数据点中显示红色质疑：RR间期录入值较计算值存在偏差，请核实。
- 若相等，关闭对应的RR数据点的质疑

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


public class EG010 extends CFunction {
    @Override
    public int run() {
        Long subjectId = context().getSubjectId();
        String msg = "<font color=\"RED\">RR间期录入值较计算值存在偏差，请核实。</font>";
        String checkId = "EG010";
        
        //传入变化的数据点
        CDataPoint checkDP = system().getDataPoint(context().getCheckDataPoints().get(0));
    		Long dataPageId = checkDP.getDataPageId();
        

        List<CDataPoint> heartDp = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", dataPageId)
                .and().eq("gridRow", checkDP.getGridRow())
                .and().eq("fieldOid", "HEART"), null);
        if (heartDp.size() == 0) return 0;
		
			List<CDataPoint> rrDp = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", dataPageId)
                .and().eq("gridRow", checkDP.getGridRow())
                .and().eq("fieldOid", "RR"), null);
        if (rrDp.size() == 0) return 0;
			if(StringUtils.isEmpty(heartDp.get(0).getDataValue()) || StringUtils.isEmpty((rrDp.get(0).getDataValue()))) return 0;
			 
			Long datapointId = rrDp.get(0).getDataPointId();

        String rr = "";
        try
        {
            BigDecimal hr = new BigDecimal(heartDp.get(0).getDataValue());
            rr = BigDecimal.valueOf(60000).divide(hr, 0, BigDecimal.ROUND_HALF_UP).stripTrailingZeros().toPlainString();
				
				
            if(!rr.equals(rrDp.get(0).getDataValue())){
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