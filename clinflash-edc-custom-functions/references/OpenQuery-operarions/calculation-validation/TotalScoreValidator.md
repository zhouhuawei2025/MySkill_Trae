# 需求说明

## 需求名称
- **POEM011** - 患者湿疹自我评价总分检查

## 功能描述
- 当POEM表单中的相关数据点发生变化时，自动触发此Custom Function进行检查
- 检查[患者湿疹自我评价总分]是否等于各项之和， 并进行质疑的打开或关闭

## 数据点说明
- **QSQ1**：位于任意访视的POEM表单上，患者湿疹自我评价问题1
- **QSQ2**：位于任意访视的POEM表单上，患者湿疹自我评价问题2
- **QSQ3**：位于任意访视的POEM表单上，患者湿疹自我评价问题3
- **QSQ4**：位于任意访视的POEM表单上，患者湿疹自我评价问题4
- **QSQ5**：位于任意访视的POEM表单上，患者湿疹自我评价问题5
- **QSQ6**：位于任意访视的POEM表单上，患者湿疹自我评价问题6
- **QSQ7**：位于任意访视的POEM表单上，患者湿疹自我评价问题7
- **QSORRES**：位于任意访视的POEM表单上，患者湿疹自我评价总分

**数据点关系**：所有数据点均属于同一受试者，且位于同一访视。

## 触发条件
当POEM表单中的任一相关数据点（QSQ1、QSQ2、QSQ3、QSQ4、QSQ5、QSQ6、QSQ7、QSORRES）发生变化时，自动触发此Custom Function进行检查

## 检查逻辑
1. 获取当前触发数据点
2. 查询同一页面POEM表单上的QSQ1-QSQ7和QSORRES数据点
3. 检查QSORRES是否为空，若为空则直接返回
4. 计算QSQ1-QSQ7的得分之和（将DicEntryOid减1作为得分）
5. 检查逻辑：
   - 若QSORRES不等于各项之和，则显示质疑
   - 若等于，则关闭质疑

## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.text.DecimalFormat;
import java.util.Collections;
import java.util.Arrays;
import java.util.stream.Collectors;
import com.baomidou.mybatisplus.toolkit.StringUtils;

public class POEM011 extends CFunction {
private static final String CHECK_OID = "POEM011";
private static final String QUERY_MSG = "<font color=\"red\">[患者湿疹自我评价总分]不等于各项之和，请核实。</font>";
//private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
@Override
public int run()
    {
        CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
		List<CDataPoint> list = system().listDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", context().getSubjectId())
        .and().eq("dataPageId", context().getDataPageId())
        .and().eq("formOid","POEM")																										
        .and().in("fieldOid", Arrays.asList("QSQ1","QSQ2","QSQ3","QSQ4","QSQ5","QSQ6","QSQ7","QSORRES")), null);

		// 检查QSQ1数据点，为空则结束
		CDataPoint qssumDp = list.stream().filter(dataPoint -> "QSORRES".equals(dataPoint.getFieldOid())).findAny().get();
		if (StringUtils.isEmpty(qssumDp.getDataValue())) return 0;
		CDataPoint qsscore1Dp = list.stream().filter(dataPoint -> "QSQ1".equals(dataPoint.getFieldOid())).findAny().get();
		CDataPoint qsscore2Dp = list.stream().filter(dataPoint -> "QSQ2".equals(dataPoint.getFieldOid())).findAny().get();
		CDataPoint qsscore3Dp = list.stream().filter(dataPoint -> "QSQ3".equals(dataPoint.getFieldOid())).findAny().get();
		CDataPoint qsscore4Dp = list.stream().filter(dataPoint -> "QSQ4".equals(dataPoint.getFieldOid())).findAny().get();
		CDataPoint qsscore5Dp = list.stream().filter(dataPoint -> "QSQ5".equals(dataPoint.getFieldOid())).findAny().get();
		CDataPoint qsscore6Dp = list.stream().filter(dataPoint -> "QSQ6".equals(dataPoint.getFieldOid())).findAny().get();
		CDataPoint qsscore7Dp = list.stream().filter(dataPoint -> "QSQ7".equals(dataPoint.getFieldOid())).findAny().get();

		int qsscore1 = StringUtils.isEmpty(qsscore1Dp.getDicEntryOid())?0:(Integer.parseInt(qsscore1Dp.getDicEntryOid()) - 1);
		int qsscore2 = StringUtils.isEmpty(qsscore2Dp.getDicEntryOid())?0:(Integer.parseInt(qsscore2Dp.getDicEntryOid()) - 1);
		int qsscore3 = StringUtils.isEmpty(qsscore3Dp.getDicEntryOid())?0:(Integer.parseInt(qsscore3Dp.getDicEntryOid()) - 1);
		int qsscore4 = StringUtils.isEmpty(qsscore4Dp.getDicEntryOid())?0:(Integer.parseInt(qsscore4Dp.getDicEntryOid()) - 1);
		int qsscore5 = StringUtils.isEmpty(qsscore5Dp.getDicEntryOid())?0:(Integer.parseInt(qsscore5Dp.getDicEntryOid()) - 1);
		int qsscore6 = StringUtils.isEmpty(qsscore6Dp.getDicEntryOid())?0:(Integer.parseInt(qsscore6Dp.getDicEntryOid()) - 1);
		int qsscore7 = StringUtils.isEmpty(qsscore7Dp.getDicEntryOid())?0:(Integer.parseInt(qsscore7Dp.getDicEntryOid()) - 1);

	  int qs1to10 = qsscore1 + qsscore2 + qsscore3 + qsscore4 + qsscore5 + qsscore6 + qsscore7;
		
		if(!qssumDp.getDataValue().equals(String.valueOf(qs1to10)))
        {
          system().openQuery(QUERY_MSG, qssumDp.getDataPointId(), CHECK_OID);
        }
        else{
            system().closeQuery(qssumDp.getDataPointId(), CHECK_OID);
        } 
        return 0;
    }

}
```