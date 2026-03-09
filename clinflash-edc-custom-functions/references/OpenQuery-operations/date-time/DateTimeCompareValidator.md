# 需求说明

## 需求名称
- **LTEA001** - 润肤剂使用时间检查

## 功能描述
- 当LTEA、IGA、EASI、BSA表单中的相关数据点发生变化时，自动触发此Custom Function进行检查
- 检查[本次来院评估前最后一次润肤剂涂抹时间]距AD评估是否不足4小时
- 若不足4小时，则在LTEATIM数据点显示红色质疑
- 若不小于4小时，则关闭对应的LTEATIM数据点的质疑

## 数据点说明
- **LTEADAT**：位于任意访视的LTEA表单上，存储润肤剂涂抹日期
- **LTEATIM**：位于任意访视的LTEA表单上，存储润肤剂涂抹时间
- **QSDAT**：位于任意访视的IGA、EASI、BSA表单上（每张表单都有一个数据点），存储评估日期
- **QSSTTIM**：位于任意访视的IGA、EASI、BSA表单上（每张表单都有一个数据点），存储评估时间

**数据点关系**：所有数据点均属于同一受试者，且位于同一访视下。

## 触发条件
当LTEA、IGA、EASI、BSA表单中的任一相关数据点（LTEADAT、LTEATIM、QSDAT、QSSTTIM）发生变化时，自动触发此Custom Function进行检查

## 检查逻辑
1. 获取当前触发数据点
2. 查询同一访视下IGA、EASI、BSA表单上的QSDAT和QSSTTIM数据点
3. 查询同一访视下LTEA表单上的LTEADAT和LTEATIM数据点
4. 组合日期和时间数据，形成完整的日期时间对象
5. 计算润肤剂涂抹时间后4小时的时间点
6. 检查每个AD评估时间是否在润肤剂涂抹后4小时内
7. 检查逻辑：
   - 若任一AD评估时间在润肤剂涂抹后4小时内，则显示质疑
   - 否则，关闭质疑

## 代码实现：
```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.baomidou.mybatisplus.toolkit.StringUtils;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CBlock;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;
import com.jxedc.clinflash.customfunction.entity.CInstance;

import java.util.*;
import java.util.stream.Collectors;
import java.util.List;
import java.util.Map;
import java.time.format.DateTimeFormatter;
import java.time.LocalDateTime;

public class LTEA001 extends CFunction {
private static final String CHECK_OID = "LTEA001";
private static final String QUERY_MSG = "<font color=\"red\">方案建议\"在每次访视的 AD 评估前 4 小时内应避免使用润肤剂\"，但[本次来院评估前最后一次润肤剂涂抹时间]距AD评估不足4h, 请核实是否录入错误。</font>";
private static final DateTimeFormatter COMBINED_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

@Override
public int run()
{
    CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));
    String folderOid = checkDp.getFolderOid();
    List<CDataPoint> list = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", context().getSubjectId())
                .and().eq("folderOid", folderOid)
                .and().in("formOid",Arrays.asList("IGA","EASI","BSA"))
                .and().eq("isVisible", 1)
                .and().eq("datapointActive", 1)
                .and().in("fieldOid", Arrays.asList("QSDAT","QSSTTIM")), null);

    List<CDataPoint> list2 = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", context().getSubjectId())
                .and().eq("folderOid", folderOid)
                .and().eq("formOid","LTEA")
                .and().eq("isVisible", 1)
                .and().eq("datapointActive", 1)
                .and().in("fieldOid", Arrays.asList("LTEADAT","LTEATIM")), null);

    if (list2.isEmpty() || list.isEmpty()) {
        return 0;
    }

    CDataPoint lteadatDp = list2.stream().filter(dataPoint -> "LTEADAT".equals(dataPoint.getFieldOid())).findAny().get();
    CDataPoint lteatimDp = list2.stream().filter(dataPoint -> "LTEATIM".equals(dataPoint.getFieldOid())).findAny().get();
    if(StringUtils.isEmpty(lteadatDp.getDataValue()) || StringUtils.isEmpty(lteatimDp.getDataValue())) return 0;
	LocalDateTime ltea = combine(lteadatDp, lteatimDp);
    LocalDateTime lteaPlus4h = ltea.plusHours(4);
	boolean openQuery = false;
	int count = 0;


	CDataPoint igadatDp = null;
	CDataPoint igasttimDp = null;
	try{
		igadatDp = list.stream().filter(dataPoint -> "QSDAT".equals(dataPoint.getFieldOid()) && "IGA".equals(dataPoint.getFormOid())).findAny().get();
		igasttimDp = list.stream().filter(dataPoint -> "QSSTTIM".equals(dataPoint.getFieldOid()) && "IGA".equals(dataPoint.getFormOid())).findAny().get();
		LocalDateTime iga = combine(igadatDp, igasttimDp);
		if(iga.isBefore(lteaPlus4h))
		{count++;}
	}
	catch(NoSuchElementException e){}

    // 处理EASI相关数据点
	CDataPoint easidatDp = null;
	CDataPoint easisttimDp = null;
	try {
		easidatDp = list.stream().filter(dataPoint -> "QSDAT".equals(dataPoint.getFieldOid()) && "EASI".equals(dataPoint.getFormOid())).findAny().get();
		easisttimDp = list.stream().filter(dataPoint -> "QSSTTIM".equals(dataPoint.getFieldOid()) && "EASI".equals(dataPoint.getFormOid())).findAny().get();
		LocalDateTime easi = combine(easidatDp, easisttimDp);
		if(easi.isBefore(lteaPlus4h))
		{count++;}
	}
	catch (NoSuchElementException e) {}

	// 处理BSA相关数据点
	CDataPoint bsadatDp = null;
	CDataPoint bsasttimDp = null;
	try {
		bsadatDp = list.stream().filter(dataPoint -> "QSDAT".equals(dataPoint.getFieldOid()) && "BSA".equals(dataPoint.getFormOid())).findAny().get();
		bsasttimDp = list.stream().filter(dataPoint -> "QSSTTIM".equals(dataPoint.getFieldOid()) && "BSA".equals(dataPoint.getFormOid())).findAny().get();
		LocalDateTime bsa = combine(bsadatDp, bsasttimDp);
		if(bsa.isBefore(lteaPlus4h))
		{count++;}
	} catch (NoSuchElementException e) {}

    if(count > 0)
    {
        system().openQuery(QUERY_MSG, lteatimDp.getDataPointId(), CHECK_OID);
    }
    else{
        system().closeQuery(lteatimDp.getDataPointId(), CHECK_OID);
    }

    return 0;
}

	public LocalDateTime combine(CDataPoint datePoint, CDataPoint timePoint) {
        // 获取日期和时间字符串
        String dateStr = datePoint.getDataValue();
        String timeStr = timePoint.getDataValue();

        // 若日期或时间为空，直接返回最小默认日期
        if (StringUtils.isEmpty(dateStr) || StringUtils.isEmpty(timeStr)) {
            return LocalDateTime.parse("1970-01-01 00:00", COMBINED_FORMATTER);
        }
                
        // 拼接为完整的日期时间字符串（格式：yyyy-MM-dd HH:mm）
        String combinedStr = dateStr + " " + timeStr;
        
        try {
            // 转换为LocalDateTime对象（可直接比较大小）
            return LocalDateTime.parse(combinedStr, COMBINED_FORMATTER);
        } catch (Exception e) {
             return LocalDateTime.parse("1970-01-01 00:00", COMBINED_FORMATTER);
        }
    }

}
```