# 需求说明

## 需求名称
DER_CHEM_EGFR - 血生化肌酐清除率的计算

## 功能描述
计算表单中的EGFR的值。
1、肌酐单位=μmol/L or umol/L
sex=女性：
if 肌酐≤62μmol/L and 胱抑素C≤0.8mg/L，135×(肌酐/62)^-0.219×(胱抑素C/0.8)^-0.323×0.9961^年龄×0.963
if 肌酐≤62μmol/L and 胱抑素C＞0.8mg/L，135×(肌酐/62)^-0.219×(胱抑素C/0.8)^-0.778×0.9961^年龄×0.963
if 肌酐＞62μmol/L and 胱抑素C≤0.8mg/L，135×(肌酐/62)^-0.544×(胱抑素C/0.8)^-0.323×0.9961^年龄×0.963
if 肌酐＞62μmol/L and 胱抑素C＞0.8mg/L，135×(肌酐/62)^-0.544×(胱抑素C/0.8)^-0.778×0.9961^年龄×0.963
sex=男性：
if 肌酐≤80μmol/L and 胱抑素C≤0.8mg/L，135×(肌酐/80)^-0.144×(胱抑素C/0.8)^-0.323×0.9961^年龄
if 肌酐≤80μmol/L and 胱抑素C＞0.8mg/L，135×(肌酐/80)^-0.144×(胱抑素C/0.8)^-0.778×0.9961^年龄
if 肌酐＞80μmol/L and 胱抑素C≤0.8mg/L，135×(肌酐/80)^-0.544×(胱抑素C/0.8)^-0.323×0.9961^年龄
if 肌酐＞80μmol/L and 胱抑素C＞0.8mg/L，135×(肌酐/80)^-0.544×(胱抑素C/0.8)^-0.778×0.9961^年龄

2、肌酐单位=mg/dl
sex=女性：
if 肌酐≤0.7mg/dl and 胱抑素C≤0.8mg/L，135×(肌酐/0.7)^-0.219×(胱抑素C/0.8)^-0.323×0.9961^年龄×0.963
if 肌酐≤0.7mg/dl and 胱抑素C＞0.8mg/L，135×(肌酐/0.7)^-0.219×(胱抑素C/0.8)^-0.778×0.9961^年龄×0.963
if 肌酐＞0.7mg/dl and 胱抑素C≤0.8mg/L，135×(肌酐/0.7)^-0.544×(胱抑素C/0.8)^-0.323×0.9961^年龄×0.963
if 肌酐＞0.7mg/dl and 胱抑素C＞0.8mg/L，135×(肌酐/0.7)^-0.544×(胱抑素C/0.8)^-0.778×0.9961^年龄×0.963
sex=男性：
if 肌酐≤0.9mg/dl and 胱抑素C≤0.8mg/L，135×(肌酐/0.9)^-0.144×(胱抑素C/0.8)^-0.323×0.9961^年龄
if 肌酐≤0.9mg/dl and 胱抑素C＞0.8mg/L，135×(肌酐/0.9)^-0.144×(胱抑素C/0.8)^-0.778×0.9961^年龄
if 肌酐＞0.9mg/dl and 胱抑素C≤0.8mg/L，135×(肌酐/0.9)^-0.544×(胱抑素C/0.8)^-0.323×0.9961^年龄
if 肌酐＞0.9mg/dl and 胱抑素C＞0.8mg/L，135×(肌酐/0.9)^-0.544×(胱抑素C/0.8)^-0.778×0.9961^年龄

## 数据点说明
- **EGFR**：位于任意访视的CHEM表单上，存储肌酐清除率的值
- **SEX**：位于V01访视的DM表单上，用于存储受试者的性别
- **LABAGE**：位于任意访视的SV表单上，用于存储的年龄（单位：年）
- **CR**：位于任意访视的CHEM表单上，存储肌酐的值
- **CYSC**：位于任意访视的CHEM表单上，存储胱抑素C的值

**数据点关系**：SEX位于V01访视，EGFR、CR、CYSC和LABAGE位于同一访视，且所有数据点均属于同一受试者。


## 触发条件
当数据点CR、CYSC和LABAGE发生变化时，自动触发此Custom Function进行计算

## 计算逻辑
1. 获取当前受试者ID和触发数据点
2. 获取参与计算的所有数据点
3. 检查是否存在空值，如果存在，则不进行计算
4. 如果不存在空值，根据性别、肌酐、胱抑素C和年龄计算EGFR值
5. 将计算结果设置到EGFR数据点中



## 代码实现：
```java 
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.baomidou.mybatisplus.toolkit.StringUtils;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.Arrays;

import org.apache.commons.lang.time.DateUtils;


public class DER_CHEM_EGFR extends CFunction {
    @Override
    public int run() {
        Long subjectId = context().getSubjectId();
        CDataPoint checkDP = system().getDataPoint(context().getCheckDataPoints().get(0));
           
        List<CDataPoint> sexDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("folderOid", "V01")
                .and().eq("formOid", "DM")
                .and().eq("fieldOid", "SEX"), null);
        if (sexDps.size() == 0) return 0;

        List<CDataPoint> labageDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("instanceId", checkDP.getInstanceId())
                .and().eq("formOid", "SV")
                .and().eq("fieldOid", "LBAGE"), null);
        if (labageDps.size() == 0) return 0;

        List<CDataPoint> list = system().listDataPoints(new EntityWrapper<CDataPoint>()
                                        .eq("subjectId", subjectId)
                                        .and().eq("instanceId", checkDP.getInstanceId())
                                        .and().eq("formOid","LB_CHEM")
                                        .and().in("fieldOid", Arrays.asList("CR","CYSC","EGFR")), null);

        CDataPoint crDp = list.stream().filter(dataPoint -> "CR".equals(dataPoint.getFieldOid())).findAny().get();          
        CDataPoint cyscDp = list.stream().filter(dataPoint -> "CYSC".equals(dataPoint.getFieldOid())).findAny().get();
        CDataPoint egfrDp = list.stream().filter(dataPoint -> "EGFR".equals(dataPoint.getFieldOid())).findAny().get();
        if (crDp == null || cyscDp == null || egfrDp == null) return 0;
    
        CDataPoint sexDp = sexDps.get(0);
        CDataPoint labageDp = labageDps.get(0);
        Double paraA = 0.0;
        Double paraB = 0.0;
        Double paraC;
        Double paraD;
        Double paraE;

        String crUnit = crDp.getUnit();
        paraC = 0.8;
        paraD = new BigDecimal(cyscDp.getDataValue()).compareTo(new BigDecimal("0.8")) <= 0 ? -0.323 : -0.778;
        paraE = ("男性".equals(sexDp.getDataValue())) ? 1.0 : 0.963;

        if("umol/L".equalsIgnoreCase(crUnit) || "μmol/L".equalsIgnoreCase(crUnit))
        {
            if("男性".equals(sexDp.getDataValue())) 
            {
                paraA = 80.0;
                paraB = new BigDecimal(crDp.getDataValue()).compareTo(new BigDecimal("80")) <= 0 ? -0.144 : -0.544;
            }
            else
            {
                paraA = 62.0;
                paraB = new BigDecimal(crDp.getDataValue()).compareTo(new BigDecimal("62")) <= 0 ? -0.219 : -0.544;
            }
        }
        else if("mg/dl".equalsIgnoreCase(crUnit))
        {
            if("男性".equals(sexDp.getDataValue())) 
            {
                paraA = 0.9;
                paraB = new BigDecimal(crDp.getDataValue()).compareTo(new BigDecimal("0.9")) <= 0 ? -0.144 : -0.544;
            }
            else
            {
                paraA = 0.7;
                paraB = new BigDecimal(crDp.getDataValue()).compareTo(new BigDecimal("0.7")) <= 0 ? -0.219 : -0.544;
            }
        }
                
        String debug = "135* (" + crDp.getDataValue() + "/" + paraA.toString() + ")^" + paraB.toString() +" * (" + cyscDp.getDataValue() + "/" + paraC.toString() +")^" + paraD.toString() +"* 0.9961^"+ labageDp.getDataValue() + "*  " + paraE.toString();
        system().openQuery(debug, egfrDp.getDataPointId(), "DER_CHEM_CCR");
        String ccrStr = CalculationUtil(crDp.getDataValue(), cyscDp.getDataValue(), labageDp.getDataValue(), paraA, paraB, paraC, paraD, paraE);
         system().setDataPointValue(egfrDp.getDataPointId(), ccrStr);
       
		return 0;
    }
	

    public String CalculationUtil(String dpA, String dpB, String ageStr, Double paraA, Double paraB, Double paraC, Double paraD, Double paraE) 
    {    
        if(StringUtils.isEmpty(dpA) || StringUtils.isEmpty(dpB) || StringUtils.isEmpty(ageStr))  return "";

        // 1. 将输入的String类型转换为BigDecimal
        BigDecimal bdDpA = new BigDecimal(dpA);
        BigDecimal bdDpB = new BigDecimal(dpB);
        
        // 2. 将输入的double类型转换为BigDecimal
        BigDecimal bdParaA = BigDecimal.valueOf(paraA);
        BigDecimal bdParaB = BigDecimal.valueOf(paraB);
        BigDecimal bdParaC = BigDecimal.valueOf(paraC);
        BigDecimal bdParaD = BigDecimal.valueOf(paraD);
        BigDecimal bdParaE = BigDecimal.valueOf(paraE);
        BigDecimal bd135 = BigDecimal.valueOf(135);
        BigDecimal bd09961 = BigDecimal.valueOf(0.9961);
        
        // 3. 按公式分步计算（支持小数次幂）
        BigDecimal term1 = BigDecimal.valueOf(
                Math.pow(bdDpA.divide(bdParaA, 5, BigDecimal.ROUND_HALF_UP).doubleValue(), paraB)
        );
        BigDecimal term2 = BigDecimal.valueOf(
                Math.pow(bdDpB.divide(bdParaC, 5, BigDecimal.ROUND_HALF_UP).doubleValue(), paraD)
        );
        BigDecimal term3 = bd09961.pow(Integer.valueOf(ageStr));

        // 4. 合并所有项：135 * term1 * term2 * term3 * paraE
        BigDecimal result = bd135.multiply(term1)
                                .multiply(term2)
                                .multiply(term3)
                                .multiply(bdParaE);
        
        // 5. 返回结果的字符串形式（可根据需求调整小数位数）
        return result.setScale(2, BigDecimal.ROUND_HALF_UP).stripTrailingZeros().toPlainString();
    }
}
```