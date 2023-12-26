function [SgyHead,Head,Data]=gSgyUnificate(SgyHead,Head,Data)
%Unification for Sgy: Head.SampleNumber=const (SgyHead.FixedLengthTraceFlag=1); Head.DelayRecordingTime=const; check day changes at 00:00.
%function [SgyHead,Head,Data]=gSgyUnificate(SgyHead,Head,Data), where:
%[SgyHead,Head,Data] – Sgy input variables;
%[SgyHead,Head,Data1] – Sgy output variables;
%Example: [SgyHead1,Head1,Data1]=gSgyUnificate(SgyHead,Head,Data);

if ischar(Data),Data=gDataLoad(Data);end;
%create equal DelayRecordingTime
if any(Head.DelayRecordingTime~=Head.DelayRecordingTime(1)), L=min(Head.DelayRecordingTime);[SgyHead,Head,Data]=gSgySetDelayRecTime(SgyHead,Head,Data,L);end;
%create equal SampleNumber
if any(Head.ns~=Head.ns(1)), L=size(Data,1);Head.ns(:)=L;SgyHead.ns=L;SgyHead.FixedLengthTraceFlag=1;end;
%cut raw, if all raw is nan (bottom part)
n=size(Data,1);while all(isnan(Data(n,:))),n=n-1;end;
if n~=size(Data,1), Data(n+1:end,:)=[];SgyHead.ns(:)=size(Data,1);SgyHead.FixedLengthTraceFlag=1;end;
%check day
Sd=gNavTime2Time('HMS32Sd',Head.HourOfDay,Head.MinuteOfHour,Head.SecondOfMinute);
[Head.DayOfYear,Sd]=gNavDayCheck(Head.DayOfYear,Sd);
[Head.HourOfDay,Head.MinuteOfHour,Head.SecondOfMinute]=gNavTime2Time('Sd2HMS3',Sd);

%mail@ge0mlib.com 20/10/2017