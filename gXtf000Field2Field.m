function Head2=gXtf000Field2Field(Head1,fi1,Head2,fi2)
%Interpolate fi1-field from Head1 to fi2-field for Head2 using time-fields (HYear,HMonth,HDay,HHour,HMinute,HSecond,HHSeconds).
%function Head2=gXtf000Field2Field(Head1,fi1,Head2,fi2), where
%Head1- head-structure used as data source;
%fi1- field name (chars vectors or cells with chars vectors) of Head1, used as data source;
%Head2- head-structure used as data receiver;
%fi1- field name (chars vectors or cells with chars vectors) of Head2, used as data receiver;
%The data linear interpolated/extrapolated from Head1.(fi1) to Head2.(fi2) using time-fields (HYear,HMonth,HDay,HHour,HMinute,HSecond,HHSeconds).
%Example:
%XtfHead1=gXtfHeaderRead('g:\zzzzz\0300_20_21(00)H_sn.xtf',1);[Head1,Data1]=gXtf000Read(XtfHead1,0);XtfHead2=gXtfHeaderRead('g:\zzzzz\0300_20_21(00)L.xtf',1);[Head2,Data2]=gXtf000Read(XtfHead2,0);
%Head2=gXtf000Field2Field(Head1,{'HSensorYcoordinate','HSensorXcoordinate'},Head2,{'HSensorYcoordinate','HSensorXcoordinate'});gXtf000Write(XtfHead2,Head2,Data2,'g:\zzzzz\0300_20_21(00)L_sn.xtf',0);

d1=gNavTime2Time('YMD32Dx',Head1.HYear,Head1.HMonth,Head1.HDay);t1=Head1.HHour.*3600+Head1.HMinute.*60+Head1.HSecond+Head1.HHSeconds./100;[d1,t1]=gNavDayCheck(d1,t1);
dt1=(d1-d1(1)).*86400+t1;
d2=gNavTime2Time('YMD32Dx',Head2.HYear,Head2.HMonth,Head2.HDay);t2=Head2.HHour.*3600+Head2.HMinute.*60+Head2.HSecond+Head2.HHSeconds./100;[d2,t2]=gNavDayCheck(d2,t2);
dt2=(d2-d1(1)).*86400+t2;
if iscell(fi1), for n=1:numel(fi1),Head2.(fi2{n})=interp1(dt1,Head1.(fi1{n}),dt2,'linear','extrap');end;
elseif all(ischar(fi1)), Head2.(fi2)=interp1(dt1,Head1.(fi1),dt2,'linear','extrap');
else error('fi1 and fi2 input variables must be chars vectors or cells with chars vectors.');
end;

%mail@ge0mlib.com 25/12/2019