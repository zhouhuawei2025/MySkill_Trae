```java
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.baomidou.mybatisplus.toolkit.StringUtils;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.util.List;
import java.util.Map;
import java.util.Arrays;
import java.util.stream.Collectors;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * EDC Custom Function 示例使用
 * 展示了如何使用EDC系统的各种操作
 */
public class EdcExampleUsage extends CFunction {
    
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter COMBINED_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    private static final String CHECK_OID = "EdcExampleUsage";
    
    @Override
    public int run() {
        try {
            // 示例1：获取触发Custom Function的数据点
            CDataPoint checkDp = getTriggeringDataPoint();
            if (checkDp == null) {
                return 0;
            }
            
            // 示例2：获取当前表单的数据点
            List<CDataPoint> formDataPoints = getCurrentFormDataPoints("EASI", Arrays.asList("QSSCORE6", "QSORRES"));
            
            // 示例3：从集合中获取单个数据点
            CDataPoint qsorresDp = getSingleDataPoint(formDataPoints, "QSORRES");
            if (qsorresDp == null) return 0;
            
            //注：如果需要从集合中获取某一行的数据点，需要根据gridRow和fieldOid进行筛选。
            String fieldOid = "QSORRES";
            CDataPoint qsorresDpRow3 = formDataPoints.stream()
                .filter(dataPoint -> fieldOid.equals(dataPoint.getFieldOid()) && dataPoint.getGridRow() == 3)
                .findAny()
                .get();
            if (qsorresDpRow3 == null) return 0;
            
            
            // 示例4：按层级获取数据点（适用于可添加页和可添加行的表单）
            processHierarchicalDataPoints();
            
            // 示例5：设置数据点值
            system().setDataPointValue(checkDp.getDataPointId(), "Updated value");
            
            // 示例6：激活/隐藏数据点
            system().setDataPointActive(Arrays.asList(checkDp.getDataPointId()), true);
            
            // 示例7：处理日期数据点
            if (checkDp.getFieldOid().endsWith("DAT")) {
                LocalDate processedDate = processDate(checkDp);
            }
            
            // 示例8：打开和关闭质疑
            system().openQuery("数据异常，请核实", checkDp.getDataPointId(), CHECK_OID);
            // 模拟处理后关闭质疑
            // system().closeQuery(checkDp.getDataPointId(), CHECK_OID);
            
            // 示例9：计算年龄
            calculateAgeExample();
            
        } catch (Exception e) {
        }
        
        return 0;
    }
    
    /**
     * 获取触发Custom Function的数据点
     */
    private CDataPoint getTriggeringDataPoint() {
        List<Long> dataPointIdList = context().getCheckDataPoints();
        if (dataPointIdList.isEmpty()) {
            return null;
        }
        Long checkDataPointId = dataPointIdList.get(0);
        return system().getDataPoint(checkDataPointId);
    }
    
    /**
     * 获取当前表单的数据点
     */
    private List<CDataPoint> getCurrentFormDataPoints(String formOid, List<String> fieldOids) {
        Long dataPageId = context().getDataPageId();
        Long subjectId = context().getSubjectId();
        
        return system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", dataPageId)
                .and().eq("formOid", formOid)
                .and().in("fieldOid", fieldOids)
                .and().eq("dataPointActive", 1), null);
    }
    
    /**
     * 从数据点集合中获取单个数据点
     */
    private CDataPoint getSingleDataPoint(List<CDataPoint> dataPoints, String fieldOid) {
        return dataPoints.stream()
                .filter(dataPoint -> fieldOid.equals(dataPoint.getFieldOid()))
                .findAny()
                .get();
    }
    
    /**
     * 处理层级数据点（适用于可添加页和可添加行的表单）
     */
    private void processHierarchicalDataPoints() {
        Long subjectId = context().getSubjectId();
        
        // 构建层级Map：BlockRepeatNumber -> GridRow -> FieldOid -> CDataPoint
        Map<Integer, Map<Integer, Map<String, CDataPoint>>> dataPointMap = system().listDataPoints(
                new EntityWrapper<CDataPoint>()
                        .eq("subjectId", subjectId)
                        .and().eq("folderOid", "AE")
                        .and().eq("formOid", "AE")
                        .and().in("fieldOid", Arrays.asList("AESTDAT", "AEENDAT", "AEACN"))
                        .and().eq("isVisible", 1)
                        .and().eq("dataPointActive", 1), null)
                .stream().collect(Collectors.groupingBy(CDataPoint::getBlockRepeatNumber,
                        Collectors.groupingBy(CDataPoint::getGridRow,
                                Collectors.toMap(CDataPoint::getFieldOid, o -> o, (o1, o2) -> o1))));
        
        // 使用层级Map获取数据
        for (int blockRepeatNumber : dataPointMap.keySet()) {
            Map<Integer, Map<String, CDataPoint>> rowMap = dataPointMap.get(blockRepeatNumber);
            for (Map.Entry<Integer, Map<String, CDataPoint>> rowEntry : rowMap.entrySet()) {
                int gridRow = rowEntry.getKey();
                Map<String, CDataPoint> fieldMap = rowEntry.getValue();
                
                CDataPoint aestdatDp = fieldMap.get("AESTDAT");
                CDataPoint aeendatDp = fieldMap.get("AEENDAT");
                CDataPoint aeacnDp = fieldMap.get("AEACN");
                
                // 处理数据...
            }
        }
    }
    
    /**
     * 处理日期数据点
     */
    private LocalDate processDate(CDataPoint datePoint) {
        String dateStr = datePoint.getDataValue();
        
        // 若日期为空或包含UK，返回默认日期
        if (StringUtils.isEmpty(dateStr) || dateStr.toUpperCase().contains("UK")) {
            return LocalDate.parse("2050-01-01", DATE_FORMATTER);
        }
        
        try {
            // 解析日期
            return LocalDate.parse(dateStr, DATE_FORMATTER);
        } catch (Exception e) {
            return LocalDate.parse("2050-01-01", DATE_FORMATTER);
        }
    }
    
    /**
     * 计算年龄示例
     */
    private void calculateAgeExample() {
        try {
            LocalDate birthDate = LocalDate.parse("1990-01-01", DATE_FORMATTER);
            LocalDate today = LocalDate.now();
            long diffDays = birthDate.until(today, ChronoUnit.DAYS);
            int age = (int) (diffDays / 365.25);
        } catch (Exception e) {
        }
    }
    
    /**
     * 合并日期和时间数据点
     */
    private LocalDateTime combineDateAndTime(CDataPoint datePoint, CDataPoint timePoint) {
        String dateStr = datePoint.getDataValue();
        String timeStr = timePoint.getDataValue();
        
        if (StringUtils.isEmpty(dateStr) || StringUtils.isEmpty(timeStr)) {
            return LocalDateTime.parse("1970-01-01 00:00", COMBINED_FORMATTER);
        }
        
        String combinedStr = dateStr + " " + timeStr;
        try {
            return LocalDateTime.parse(combinedStr, COMBINED_FORMATTER);
        } catch (Exception e) {
            return LocalDateTime.parse("1970-01-01 00:00", COMBINED_FORMATTER);
        }
    }
    
    /**
     * 主方法，用于测试
     */
    public static void main(String[] args) {
        // 注意：实际运行时，CFunction会由EDC系统实例化并调用run()方法
        // 这里仅作为示例结构展示
    }
}
```