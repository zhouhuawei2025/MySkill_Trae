# 需求说明

## 需求名称
- **NRS010** - 评估日期重复检查

## 功能描述
- 当NRS表单中的QSDAT（评估日期）数据点发生变化时，自动触发此Custom Function进行检查
- 检查同一访视下是否存在重复的QSDAT值
- 若存在重复的评估日期，在所有重复的QSDAT数据点中显示红色质疑
- 若不存在重复的评估日期，关闭对应的QSDAT数据点的质疑

## 数据点说明
- **QSDAT**：位于NRS表单上，可添加行上的数据点，存储评估日期

**数据点关系**：所有QSDAT数据点位于同一访视同一表单上，每个数据点一行，且均属于同一受试者。

## 触发条件
当NRS表单中的QSDAT数据点发生变化时，自动触发此Custom Function进行检查

## 检查逻辑
1. 获取当前触发数据点
2. 查询当前表单下所有激活状态的QSDAT数据点
3. 提取所有非空的QSDAT值
4. 检查每个QSDAT值是否在列表中出现多次
- 若存在重复的评估日期，则在对应的QSDAT数据点中显示红色质疑：[评估日期]与当前页面已有行重复，请核实是否重复录入。
- 若不存在重复的评估日期，关闭对应的QSDAT数据点的质疑

## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.common.utils.StringUtils;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.util.stream.Collectors;
import java.util.List;

public class NRS010 extends CFunction {
    private static final String CHECK_OID = "NRS010";
    private static final String QUERY_MSG = "<font color=\"red\">[评估日期]与当前页面已有行重复，请核实是否重复录入。</font>";
    
    @Override
    public int run() {
        CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
        //获取当前表单下所有的QSDAT的数据点
        List<CDataPoint> dpList = system().listVisibleDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", checkDp.getSubjectId())
                .and().eq("instanceId", checkDp.getInstanceId())
                .and().eq("formOid", "NRS")
                .and().eq("recordActive",1)
                .and().eq("fieldOid", "QSDAT"), null); 
        List<String> QSList=dpList.stream().map(CDataPoint::getDataValue).filter(StringUtils::isNotEmpty).collect(Collectors.toList());
        for (CDataPoint dp : dpList) {
            if(StringUtils.isNotEmpty(dp.getDataValue())&&QSList.size()>1){
                if (hasMultipleOccurrences(QSList, dp.getDataValue())){
                    system().openQuery(QUERY_MSG, dp.getDataPointId(), CHECK_OID);
                }else{
                    system().closeQuery(dp.getDataPointId(), CHECK_OID);
                }
            }else{
                system().closeQuery(dp.getDataPointId(), CHECK_OID);
            }
        }
        return 0;
    }
    
    public static boolean hasMultipleOccurrences(List<String> list, String target) {
        int count = 0;
        for (String str : list) {
            if (target.equals(str)) {
                count++;
            }
            if (count >= 2) {
                return true;
            }
        }
        return false;
    }
}
```