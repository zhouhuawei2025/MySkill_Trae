# 需求说明

## 需求名称
- **IE002** - 校验入排标准填写重复

## 功能描述
- 当IECAT或IETESTCD数据点发生变化时，自动触发此Custom Function进行校验
- 从当前页面的入排标准数据点中获取值
- 校验是否有重复的入排标准填写（即是否有相同的IECAT+IETESTCD组合），并进行质疑的打开或关闭

## 数据点说明
- **IECAT**：位于IE访视的IE表单上，可添加行上的数据点，存储入排标准分类
- **IETESTCD**：位于IE访视的IE表单上，可添加行上的数据点，存储入排标准序号

**数据点关系**：IECAT和IETESTCD位于同一访视同一表单上，且均属于同一受试者，同一行的IECAT和IETESTCD视为一组。

## 触发条件
当表单中的IECAT或IETESTCD数据点发生变化时，自动触发此Custom Function进行校验

## 计算逻辑
1. 获取当前受试者ID和触发数据点
2. 查询并获取当前页面所有IECAT和IETESTCD数据点的值
3. 校验是否有重复的入排标准填写（即是否有相同的IECAT+IETESTCD组合）
- 若有重复填写，在对应的IETESTCD数据点上显示红色字体质疑：不满足的入排标准填写重复，请核实。
- 若无重复填写，关闭对应的IETESTCD数据点的质疑

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


public class IE002 extends CFunction {
    private static final String CHECK_OID = "IE002";
    private static final String QUERY_MSG = "<font color=\"red\">不满足的入排标准填写重复，请核实。</font>";


    @Override
    public int run() 
    {
        CDataPoint checkDp = system().getDataPoint(context().getCheckDataPoints().get(0));

        Map<Integer, Map<String, CDataPoint>> IEMap = system().listDataPoints(new EntityWrapper<CDataPoint>()
        .eq("subjectId", context().getSubjectId())
        .eq("folderOid", "RAND1")
        .and().eq("formOid", "IE")
        .and().in("fieldOid", Arrays.asList("IECAT", "IETESTCD"))
        .and().eq("recordActive", 1), null)
        .stream().collect(Collectors.groupingBy(CDataPoint::getGridRow,
            Collectors.toMap(CDataPoint::getFieldOid, o -> o, (o1, o2) -> o1)));

         // 提取每行的“IECAT+IETESTCD”组合，记录对应的IETESTCD数据点
        // key: 组合标识（IECAT值|IETESTCD值）, value: 该组合对应的所有IETESTCD数据点
        Map<String, List<CDataPoint>> comboToIetestcdDpsMap = new HashMap<>();

        for (Map.Entry<Integer, Map<String, CDataPoint>> rowEntry : IEMap.entrySet()) {
            Map<String, CDataPoint> fieldMap = rowEntry.getValue();

            if (StringUtils.isEmpty(fieldMap.get("IECAT").getDicEntryOid()) || StringUtils.isEmpty(fieldMap.get("IETESTCD").getDataValue())) continue; 
            
            String iecatValue = fieldMap.get("IECAT").getDicEntryOid();
            String ietestcdValue = fieldMap.get("IETESTCD").getDataValue();
            String comboKey = iecatValue + "|" + ietestcdValue;

            //将当前行的IETESTCD数据点加入组合列表
            comboToIetestcdDpsMap.computeIfAbsent(comboKey, k -> new ArrayList<>()).add(fieldMap.get("IETESTCD"));
        }

        // 筛选重复组合，收集需要发Query的IETESTCD数据
        Set<CDataPoint> duplicateIetestcdDps = new HashSet<>();
        for (Map.Entry<String, List<CDataPoint>> comboEntry : comboToIetestcdDpsMap.entrySet()) {
            List<CDataPoint> ietestcdDps = comboEntry.getValue();
            if (ietestcdDps.size() >= 2) { 
                duplicateIetestcdDps.addAll(ietestcdDps);
            }
        }

        // 5. 遍历所有IETESTCD数据点，触发/关闭Query
        // 提取所有IETESTCD数据点
        List<CDataPoint> allIetestcdDps = new ArrayList<>();
        for (Map<String, CDataPoint> fieldMap : IEMap.values()) {
            CDataPoint ietestcdDp = fieldMap.get("IETESTCD");            
            allIetestcdDps.add(ietestcdDp); 
        }

        // 逐个处理IETESTCD数据点
        for (CDataPoint ietestcdDp : allIetestcdDps) {
            if (duplicateIetestcdDps.contains(ietestcdDp))
             {                
                system().openQuery(QUERY_MSG, ietestcdDp.getDataPointId(), CHECK_OID);
            } else {                
                system().closeQuery(ietestcdDp.getDataPointId(), CHECK_OID);
            }
        }

        return 0;
    }
}
```