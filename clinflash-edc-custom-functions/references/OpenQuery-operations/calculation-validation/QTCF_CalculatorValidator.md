# 需求说明

## 需求名称
- **EG011** - 计算QTCF值

## 功能描述
- 当QT、HEART、QTCF任意一个数据点发生变化时，自动触发此Custom Function进行计算
- 逐行计算QTCF值：QTCF = QT / HEART
- 逐行校验QTCF值与计算值相等，并进行质疑的打开或关闭

## 数据点说明
- **QT**：位于任意访视的EG表单上，可添加行上的数据点，存储QT值（秒）
- **HEART**：位于任意访视的EG表单上，可添加行上的数据点，存储HEART值（次/分）
- **QTCF**：位于任意访视的EG表单上，可添加行上的数据点，存储QTCF值（秒/次）

**数据点关系**：QT、HEART、QTCF位于同一访视同一表单上，且均属于同一受试者。

## 触发条件
当表单中的QT或HEART数据点发生变化时，自动触发此Custom Function进行计算

## 计算逻辑
1. 获取当前受试者ID和触发数据点
2. 查询并获取当前页面所有QT、HEART、QTCF数据点的值
3. 逐行计算QTCF值：QTCF = QT / HEART
4. 逐行校验QTCF值是否与计算值相等
- 若不相等，则在QTCF数据点中显示红色质疑：QTCF间期录入值较计算值存在偏差，请核实。
- 若相等，关闭对应的QTCF数据点的质疑

## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import com.baomidou.mybatisplus.toolkit.StringUtils;
import java.text.ParseException;


/**
 * QTCF自动计算
 */
public class EG011 extends CFunction {
    @Override
    public int run() {
        CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
		String checkId = "EG011";
		String msg = "<font color=\"red\">QTCF间期录入值较计算值存在偏差，请核实。</font>";

        String qtField = "QT";
        String hrField = "HEART";
        String qtcfField = "QTCF";

        List<CDataPoint> dps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("dataPageId", checkDp.getDataPageId())
                .and().in("fieldOid", Arrays.asList(qtcfField, qtField, hrField)), null);
        for (CDataPoint dp : dps.stream().filter(e -> qtcfField.equals(e.getFieldOid())).collect(Collectors.toList())) {
            if (dp.getIsLocked()==1 || (dp.getIsFrozen()==1 && dp.getDerivedVariableFlag()==0)) {
                continue;
            }
            int gridRow = dp.getGridRow();
            CDataPoint qtDp = dps
                    .stream()
                    .filter(e -> qtField.equals(e.getFieldOid()) && e.getGridRow().equals(gridRow))
                    .collect(Collectors.toList())
                    .get(0);
            CDataPoint hrDp = dps
                    .stream()
                    .filter(e -> hrField.equals(e.getFieldOid()) && e.getGridRow().equals(gridRow))
                    .collect(Collectors.toList())
                    .get(0);
					 CDataPoint qtcfDp = dps
                    .stream()
                    .filter(e -> qtcfField.equals(e.getFieldOid()) && e.getGridRow().equals(gridRow))
                    .collect(Collectors.toList())
                    .get(0);
					 if(StringUtils.isEmpty(hrDp.getDataValue()) || StringUtils.isEmpty((qtDp.getDataValue())) || StringUtils.isEmpty((qtcfDp.getDataValue()))) return 0;
            String val = setQtcfVal(qtDp, hrDp);
					
					
					if(!val.equals(qtcfDp.getDataValue())){
                system().openQuery(msg, qtcfDp.getDataPointId(), checkId);
            }
            else{
                system().closeQuery(qtcfDp.getDataPointId(), checkId);
            }
					
        }

        return 0;
    }

    /**
     * QTCF自动计算及赋值
     * @param QT
     * @param HR
     * @param targetDp
     */
    private String setQtcfVal(CDataPoint QT, CDataPoint HR) {
       String val = "";
			try {            
            BigDecimal hr = new BigDecimal(HR.getDataValue());
            BigDecimal qt = new BigDecimal(QT.getDataValue());
            val = qt.divide(BigDecimal.valueOf(Math.pow(60L/hr.doubleValue(), 0.33)), 0, RoundingMode.HALF_UP).stripTrailingZeros().toPlainString();
				
        } 
			catch (Exception ignored) {           
        }
			return val;
    }
}
```