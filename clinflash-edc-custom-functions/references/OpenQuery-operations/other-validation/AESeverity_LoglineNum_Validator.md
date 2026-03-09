# 需求说明

## 需求名称
- **AE031** - 不良事件严重程度变化与可添加行行数检查

## 功能描述
- 当AE表单中的AESEVCH、AESTDAT任意一个数据点发生变化时，自动触发此Custom Function进行检查
- 检查当AESEVCH选择"是"时，是否存在足够的不良事件变化子记录
- 若AESEVCH选择"是"但仅有一条AESTDAT记录（表示没有变化子记录），在AESEVCH数据点中显示红色质疑
- 若AESEVCH选择"否"或存在多条AESTDAT记录，关闭对应的AESEVCH数据点的质疑

## 数据点说明
- **AESEVCH**：位于AE表单上，masterRecord（主记录）中的数据点，存储是否有严重程度变化（1表示是，0表示否）
- **AESTDAT**：位于AE表单上，可添加行上的数据点，存储不良事件开始日期（用于判断是否存在变化子记录）

**数据点关系**：AESEVCH和AESTDAT位于同一访视同一表单上，且均属于同一受试者。

## 触发条件
当AE表单中的AESEVCH数据点发生变化时，自动触发此Custom Function进行检查

## 检查逻辑
1. 获取当前受试者ID和触发数据点
2. 查询当前页面的AESEVCH数据点
3. 查询当前页面所有激活状态的AESTDAT数据点
4. 检查AESEVCH的值和AESTDAT的数量
- 若AESEVCH选择"是"（DicEntryOid为"1"）且仅有一条AESTDAT记录，则在AESEVCH数据点中显示红色质疑：[是否有严重程度变化]选择“是”，不良事件变化子记录仅有一条记录，请核实此处是否录入错误，如确认有严重程度变化，请在下方添加子记录录入变化情况。
- 若AESEVCH选择"否"或存在多条AESTDAT记录，关闭对应的AESEVCH数据点的质疑

## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.util.List;

public class AE031 extends CFunction {
    private static final String CHECK_OID = "AE031";
    private static final String QUERY_MSG = "<font color=\"red\">[是否有严重程度变化]选择“是”，不良事件变化子记录仅有一条记录，请核实此处是否录入错误，如确认有严重程度变化，请在下方添加子记录录入变化情况。</font>";

    @Override
    public int run() {
        CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
        Long subjectId = context().getSubjectId();

        List<CDataPoint> dpAESEVCHs = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", checkDp.getDataPageId())
                .and().eq("fieldOid", "AESEVCH"), null);

        List<CDataPoint> dpAESTDATs = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", checkDp.getDataPageId())
                .and().eq("fieldOid", "AESTDAT")
                .and().eq("dataPointActive", 1), null);

        CDataPoint dp = dpAESEVCHs.get(0);

        //AESEVCH = 1, 即选择"是"且仅有一条AESTDAT记录（表示没有变化子记录）
        if( dp.getDicEntryOid().equals("1") && dpAESTDATs.size() == 1)
        {
            system().openQuery(QUERY_MSG, dp.getDataPointId(), CHECK_OID);
        }
        else{
            system().closeQuery(dp.getDataPointId(), CHECK_OID);
        }

        return 0;
    }
}
```