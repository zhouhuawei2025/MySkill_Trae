# 需求说明

## 需求名称
- **NRS009** - 基线峰值瘙痒NRS评分检查

## 功能描述
- 当NRS表单中的数据点发生变化时，自动触发此Custom Function进行检查
- 检查首次给药前7天中基线峰值瘙痒NRS评分平均值是否≥4分
- 若平均值<4分但受试者仍被判定为符合所有入选标准，则在QSYN数据点显示红色质疑
- 若平均值≥4分或受试者未被判定为符合所有入选标准，则关闭对应的QSYN数据点的质疑

## 数据点说明
- **ECSTDAT**：位于V02访视的EC表单上，存储给药开始日期
- **IEYN**：位于RAND1访视的IE表单上，存储受试者是否符合所有入选标准的判定
- **QSDAT**：位于NRS访视的NRS表单上，可添加行上的数据点，存储评估日期
- **QSYN**：位于NRS访视的NRS表单上，存储受试者是否进行了NRS评分
- **QSORRES**：位于NRS访视的NRS表单上，可添加行上的数据点，存储NRS评分值

**数据点关系**：所有数据点均属于同一受试者，其中QSDAT、QSYN、QSORRES位于同一访视同一表单上。

## 触发条件
当IEYN、ECSTDAT、QSDAT、QSYN、QSORRES任意一个数据点发生变化时，自动触发此Custom Function进行检查

## 检查逻辑
1. 获取当前触发数据点
2. 查询V02访视EC表单上的ECSTDAT数据点（给药开始日期）
3. 查询RAND1访视IE表单上的IEYN数据点（受试者是否符合所有入选标准）
4. 计算给药开始日期前8天的日期
5. 查询NRS访视NRS表单上的QSDAT、QSYN、QSORRES数据点
6. 统计首次给药前7天内的NRS评分总和和次数
7. 计算平均值
8. 检查逻辑：
   - 若没有评分记录且受试者被判定为符合所有入选标准，则显示质疑
   - 若平均值<4分且受试者被判定为符合所有入选标准，则显示质疑
   - 否则，关闭质疑

## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.baomidou.mybatisplus.toolkit.StringUtils;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CBlock;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;
import com.jxedc.clinflash.customfunction.entity.CInstance;

import java.time.LocalDateTime;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Arrays;
import java.util.stream.Collectors;

public class NRS009 extends CFunction {
    private static final String CHECK_OID = "NRS009";
    private static final String QUERY_MSG = "<font color=\"red\">首次给药前7天中，基线峰值瘙痒 NRS 评分平均值不满足≥4分，但[受试者是否符合所有入选标准且不符合所有排除标准？]却未勾选\"否\"，请核实。</font>";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    public int run()
    {
        // 获取当前触发数据点
        CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
        String folderOid = checkDp.getFolderOid();
        
        // 查询V02访视EC表单上的ECSTDAT数据点（给药开始日期）
        List<CDataPoint> ecstdatDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                    .eq("subjectId", context().getSubjectId())
                    .and().eq("folderOid", "V02")
                    .and().eq("formOid","EC")
                    .and().eq("isVisible", 1)
                    .and().eq("datapointActive", 1)
                    .and().eq("fieldOid", "ECSTDAT"), null);
        if(ecstdatDps.isEmpty()) return 0; // 若未找到给药开始日期，直接返回
        
        // 查询RAND1访视IE表单上的IEYN数据点（受试者是否符合所有入选标准）
        List<CDataPoint> ieynDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                    .eq("subjectId", context().getSubjectId())
                    .and().eq("folderOid", "RAND1")
                    .and().eq("formOid","IE")
                    .and().eq("isVisible", 1)
                    .and().eq("datapointActive", 1)
                    .and().eq("fieldOid", "IEYN"), null);
        if(ieynDps.isEmpty()) return 0; // 若未找到入选标准判定，直接返回

        // 计算给药开始日期前8天的日期，用于确定基线评分的时间范围
        LocalDate date = LocalDate.parse(ecstdatDps.get(0).getDataValue(), DATE_FORMATTER);
        LocalDate date8 = date.minusDays(8);

        // 查询NRS访视NRS表单上的QSDAT、QSYN、QSORRES数据点
        List<CDataPoint> nrslist = system().listDataPoints(new EntityWrapper<CDataPoint>()
                    .eq("subjectId", context().getSubjectId())
                    .and().eq("folderOid", "NRS")
                    .and().eq("formOid","NRS")
                    .and().eq("recordActive", 1)
                    .and().in("fieldOid", Arrays.asList("QSDAT","QSYN","QSORRES")), null);
        
        // 统计首次给药前7天内的NRS评分总和和次数
        int count = 0;
        double sum = 0;
        for(CDataPoint qsdatDp : nrslist.stream().filter(dataPoint -> "QSDAT".equals(dataPoint.getFieldOid())).collect(Collectors.toList()))
        {
            if(StringUtils.isNotEmpty(qsdatDp.getDataValue()))
            {
                LocalDate qsdat = LocalDate.parse(qsdatDp.getDataValue(), DATE_FORMATTER);
                // 检查评估日期是否在首次给药前7天内
                if(qsdat.isBefore(date) && date8.isBefore(qsdat))
                {
                    int row = qsdatDp.getGridRow();
                    // 获取对应行的QSORRES数据点（NRS评分值）
                    CDataPoint qssorresDp = nrslist.stream().filter(dataPoint -> "QSORRES".equals(dataPoint.getFieldOid()) && dataPoint.getGridRow() ==  row).findAny().get();
                    double qs = StringUtils.isEmpty(qssorresDp.getDataValue()) ? 0 : Double.parseDouble(qssorresDp.getDataValue());
                    sum+= qs;
                    count++;
                }
            }
        }

        // 获取QSYN数据点，用于显示或关闭质疑
        CDataPoint qsynDp = nrslist.stream().filter(dataPoint -> "QSYN".equals(dataPoint.getFieldOid()) && dataPoint.getGridRow() ==  1).findAny().get();
        
        // 检查逻辑：若没有评分记录且受试者被判定为符合所有入选标准，则显示质疑
        if(count == 0 && ieynDps.get(0).getDicEntryOid().equals("1"))
        {
            system().openQuery(QUERY_MSG, qsynDp.getDataPointId(), CHECK_OID);
            return 0;
        }
		
        // 检查逻辑：若平均值<4分且受试者被判定为符合所有入选标准，则显示质疑
        if(sum/count < 4 && ieynDps.get(0).getDicEntryOid().equals("1"))
        {
            system().openQuery(QUERY_MSG, qsynDp.getDataPointId(), CHECK_OID);
        }
        else{
            // 否则，关闭质疑
            system().closeQuery(qsynDp.getDataPointId(), CHECK_OID);
        }
        return 0;
    }
}
```