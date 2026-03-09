# 需求说明

## 需求名称
- **SV038b** - 提前退出ET访视日期检查

## 功能描述
- 当VISDAT、DBEOTDAT、DBEXDAT任意一个数据点发生变化时，自动触发此Custom Function进行检查
- 检查ET访视的VISDAT是否晚于DBEOTDAT或早于DBEXDAT，并进行质疑的打开或关闭

## 数据点说明
- **VISDAT**：位于ET访视的SV表单上，存储访视日期
- **DBEOTDAT**：位于COM访视的EOT表单上，存储受试者提前退出试验/完成日期
- **DBEXDAT**：位于COM访视的EOT表单上，存储决定提前退出给药的日期

**数据点关系**：所有数据点均属于同一受试者。

## 触发条件
当VISDAT、DBEOTDAT、DBEXDAT任意一个数据点发生变化时，自动触发此Custom Function进行检查

## 检查逻辑
1. 获取当前触发数据点
2. 查询ET访视SV表单上的VISDAT数据点（访视日期）
3. 查询COM访视EOT表单上的DBEOTDAT和DBEXDAT数据点
4. 处理日期数据，将空日期或UK日期转换为默认日期（2050-01-01）
5. 确定决定提前退出给药的最早日期（DBEOTDAT和DBEXDAT中的较小值）
6. 检查逻辑：
   - 若VISDAT晚于DBEOTDAT或早于DBEXDAT，则显示质疑
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

public class SV038b extends CFunction {
    private static final String CHECK_OID = "SV038b";
    private static final String QUERY_MSG = "<font color=\"red\">提前退出ET访视的访视日期晚于[受试者提前退出试验/完成日期] 或早于决定提前退出给药的日期，请核实。</font>";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    public int run()
    {
        CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
        String folderOid = checkDp.getFolderOid();
        List<CDataPoint> visdatDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                    .eq("subjectId", context().getSubjectId())
                    .and().eq("folderOid", "ET")
                    .and().eq("formOid","SV")
                    .and().eq("isVisible", 1)
                    .and().eq("datapointActive", 1)
                    .and().eq("fieldOid", "VISDAT"), null);
        if(visdatDps.isEmpty()) return 0;
        
        List<CDataPoint> dbeotDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                    .eq("subjectId", context().getSubjectId())
                    .and().eq("folderOid", "COM")
                    .and().eq("formOid","EOT")
                    .and().eq("isVisible", 1)
                    .and().eq("datapointActive", 1)
                    .and().eq("fieldOid", "DBEOTDAT"), null);

        List<CDataPoint> dbexDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                    .eq("subjectId", context().getSubjectId())
                    .and().eq("folderOid", "COM")
                    .and().eq("formOid","EOT")
                    .and().eq("isVisible", 1)
                    .and().eq("datapointActive", 1)
                    .and().eq("fieldOid", "DBEXDAT"), null);

        if(dbeotDps.isEmpty() && dbexDps.isEmpty()) return 0;
		
        LocalDate visdat = transferEmpty(visdatDps.get(0));
        LocalDate dbeotdat = dbeotDps.isEmpty() ? LocalDate.parse("2050-01-01", DATE_FORMATTER) : transferEmpty(dbeotDps.get(0));
        LocalDate dbexdat = dbexDps.isEmpty() ? LocalDate.parse("2050-01-01", DATE_FORMATTER) : transferEmpty(dbexDps.get(0));
		
        LocalDate mindate = dbeotdat;
        if(dbexdat.isBefore(dbeotdat))
        {
            mindate = dbexdat;
        }
		
        if(visdat.isBefore(mindate))
        {
            system().openQuery(QUERY_MSG, visdatDps.get(0).getDataPointId(), CHECK_OID);
        }
        else{
            system().closeQuery(visdatDps.get(0).getDataPointId(), CHECK_OID);
        }

        return 0;

    }

    public static LocalDate transferEmpty(CDataPoint datePoint) {
        // 获取日期字符串
        String dateStr = datePoint.getDataValue();

        // 若日期为空或包含UK，直接返回最大默认日期
        if (StringUtils.isEmpty(dateStr) || dateStr.toUpperCase().contains("UK")) {
            return LocalDate.parse("2050-01-01", DATE_FORMATTER);
        }
        
        try {
            return LocalDate.parse(dateStr, DATE_FORMATTER);
        } catch (Exception e) {
            return LocalDate.parse("2050-01-01", DATE_FORMATTER);
        }
    }

}
```