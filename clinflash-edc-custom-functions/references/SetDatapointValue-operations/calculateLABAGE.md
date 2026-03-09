
# 需求说明

## 需求名称
- **DER_BRTHDAT_AGE** - 基于出生日期变化的年龄计算
- **DER_VISDAT_AGE** - 基于访视日期变化的年龄计算

## 功能描述
根据受试者的出生日期和访视日期，计算受试者在该访视时的年龄（单位：年），并将计算结果存储到对应访视的LABAGE数据点中。

## 数据点说明
- **BRTHDAT**：位于V01访视的DM表单上，存储受试者的出生日期
- **VISDAT**：位于任意访视的SV表单上，存储该访视的日期
- **LABAGE**：位于任意访视的SV表单上，用于存储计算得到的年龄（单位：年）

**数据点关系**：BRTHDAT位于V01访视，VISDAT和LABAGE位于同一访视，且三者均属于同一受试者。

## 触发条件
- 当V01访视DM表单中的BRTHDAT数据点值发生变化时，自动触发**DER_BRTHDAT_AGE**计算所有访视的年龄
- 当任意访视SV表单中的VISDAT数据点值发生变化时，自动触发**DER_VISDAT_AGE**计算该访视的年龄

## 计算方法
年龄计算采用以下公式：
1. 计算出生日期与访视日期之间的天数差
2. 将天数差除以365.25（考虑闰年）
3. 取整数部分作为年龄

## 实现方式
- **DER_BRTHDAT_AGE**：当出生日期变化时，遍历所有访视的SV表单，更新每个访视的LABAGE值
- **DER_VISDAT_AGE**：当访视日期变化时，仅更新当前访视的LABAGE值



当BRTHDAT变化时：
```
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;
import org.apache.commons.lang.time.DateUtils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * 年龄计算（天数差/365.25取整数部分）
 */
public class DER_BRTHDAT_AGE extends CFunction {
    @Override
    public int run() {
        Long subjectId = context().getSubjectId();
            CDataPoint checkDP = system().getDataPoint(context().getCheckDataPoints().get(0));                                                   

        List<CDataPoint> birthdayDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("folderOid", "V01")
                .and().eq("formOid", "DM")
                .and().eq("fieldOid", "BRTHDAT"), null);
        if (birthdayDps.size() == 0) return 0;

        List<CDataPoint> calDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
            .eq("subjectId", subjectId)
            .and().eq("formOid", "SV")
            .and().eq("fieldOid", "VISDAT"), null);
        if (calDps.size() == 0) return 0;
        for(int i = 0; i < calDps.size(); i ++)
        {
            CDataPoint visdat = calDps.get(i);
            Long dataPageId = visdat.getDataPageId();
            List<CDataPoint> targetDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)                
                .and().eq("dataPageId", dataPageId)
                .and().eq("fieldOid", "LABAGE"), null);           
            system().setDataPointValue(targetDps.get(0).getDataPointId(), getAgeStr(birthdayDps.get(0), visdat));

        }
        return 0;
    }

    private String getAgeStr(CDataPoint birthdayDp, CDataPoint calDayDp) {
        String age = "";
        try {
            LocalDate calDay = parseWithLocale(calDayDp.getDataValue(), calDayDp.getDataFormat());
            LocalDate birthday = parseWithLocale(birthdayDp.getDataValue(), birthdayDp.getDataFormat());

            long diffDays = birthday.until(calDay, ChronoUnit.DAYS);

            age = new Double((diffDays) / 365.25).intValue() + "";
        } catch (Exception ignored) {
        }
        return age;
    }

    private LocalDate parseWithLocale(String value, String format) throws ParseException {
        Date date = null;
        SimpleDateFormat sdf = new SimpleDateFormat(format, Locale.ENGLISH);
        try {
            date = sdf.parse(value);
        } catch (ParseException ex) {
            date = DateUtils.parseDate(value, new String[] {format});
        }

        // Date 转 LocalDate
        Instant instant = date.toInstant();
        ZoneId zoneId = ZoneId.systemDefault();
        return instant.atZone(zoneId).toLocalDate();
    }
}
```
当VISDAT变化时：
```
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.jxedc.clinflash.customfunction.CFunction;
import com.jxedc.clinflash.customfunction.entity.CDataPoint;
import org.apache.commons.lang.time.DateUtils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * 年龄计算（天数差/365.25取整数部分）
 */
public class DER_VISDAT_AGE extends CFunction {
    @Override
    public int run() {
        Long subjectId = context().getSubjectId();
                                CDataPoint checkDP = system().getDataPoint(context().getCheckDataPoints().get(0));
                    Long dataPageId = checkDP.getDataPageId();
                                

        List<CDataPoint> birthdayDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("folderOid", "V01")
                .and().eq("formOid", "DM")
                .and().eq("fieldOid", "BRTHDAT"), null);
        if (birthdayDps.size() == 0) return 0;

        List<CDataPoint> targetDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", dataPageId)
                .and().eq("fieldOid", "LABAGE"), null);
        List<CDataPoint> calDps = system().listDataPoints(new EntityWrapper<CDataPoint>()
                .eq("subjectId", subjectId)
                .and().eq("dataPageId", dataPageId)
                .and().eq("fieldOid", "VISDAT"), null);
        if (targetDps.size() == 0 || calDps.size() == 0) return 0;
        system().setDataPointValue(targetDps.get(0).getDataPointId(), getAgeStr(birthdayDps.get(0), calDps.get(0)));
        return 0;
    }

    private String getAgeStr(CDataPoint birthdayDp, CDataPoint calDayDp) {
        String age = "";
        try {
            LocalDate calDay = parseWithLocale(calDayDp.getDataValue(), calDayDp.getDataFormat());
            LocalDate birthday = parseWithLocale(birthdayDp.getDataValue(), birthdayDp.getDataFormat());

            long diffDays = birthday.until(calDay, ChronoUnit.DAYS);

            age = new Double((diffDays) / 365.25).intValue() + "";
        } catch (Exception ignored) {
        }
        return age;
    }

    private LocalDate parseWithLocale(String value, String format) throws ParseException {
        Date date = null;
        SimpleDateFormat sdf = new SimpleDateFormat(format, Locale.ENGLISH);
        try {
            date = sdf.parse(value);
        } catch (ParseException ex) {
            date = DateUtils.parseDate(value, new String[] {format});
        }

        // Date 转 LocalDate
        Instant instant = date.toInstant();
        ZoneId zoneId = ZoneId.systemDefault();
        return instant.atZone(zoneId).toLocalDate();
    }
}
```