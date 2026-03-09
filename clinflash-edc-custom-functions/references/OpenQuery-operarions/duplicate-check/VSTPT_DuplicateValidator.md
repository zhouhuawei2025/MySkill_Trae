# 需求说明

## 需求名称
- **VS2013** - 检查时间点重复检查

## 功能描述
- 当VS2表单中的VSTPT（检查时间点）数据点发生变化时，自动触发此Custom Function进行检查
- 检查当前访视中所有VS2表单的VSTPT是否重复，并进行质疑的打开或关闭

## 数据点说明
- **VSTPT**：位于任意访视的VS2表单上，存储检查时间点

**数据点关系**：所有VSTPT数据点位于同一访视中，属于同一受试者，同一访视下可以存在多张VS2表单。

## 触发条件
当VS2表单中的VSTPT数据点发生变化时，自动触发此Custom Function进行检查

## 检查逻辑
1. 获取当前触发数据点
2. 查询当前访视中所有VS2表单（gridRow=1）的VSTPT数据点
3. 提取所有非空的VSTPT值（使用DicEntryOid）
4. 检查每个VSTPT值是否在列表中出现多次
5. 检查逻辑：
   - 若存在重复的检查时间点，则在触发数据点显示红色质疑
   - 若不存在重复的检查时间点，则关闭对应的质疑

## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.common.utils.StringUtils;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.util.stream.Collectors;
import java.util.List;

public class VS2013 extends CFunction {
    private static final String CHECK_OID = "VS2013";
    private static final String QUERY_MSG = "<font color=\"red\">[检查时间点]重复，请核实。</font>";
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
    @Override
    public int run() {
        CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
        //获取VSTPT的数据点
        List<CDataPoint> dpList = system().listVisibleDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", checkDp.getSubjectId())
                .and().eq("instanceId", checkDp.getInstanceId())
                .and().eq("formOid", "VS2")
                .and().eq("gridRow",1)
                .and().eq("fieldOid", "VSTPT"), null);
        List<String> VSTPTList=dpList.stream().map(CDataPoint::getDicEntryOid).filter(StringUtils::isNotEmpty).collect(Collectors.toList());
        for (CDataPoint dp : dpList) {
            if(StringUtils.isNotEmpty(dp.getDicEntryOid())&&VSTPTList.size()>1){
                if (hasMultipleOccurrences(VSTPTList,dp.getDicEntryOid())){
                    system().openQuery(QUERY_MSG, checkDp.getDataPointId(), CHECK_OID);
                }else{
                    system().closeQuery(dp.getDataPointId(), CHECK_OID);
                }
            }else{
                system().closeQuery(dp.getDataPointId(), CHECK_OID);
            }
        }
        return 0;
    }
}
```