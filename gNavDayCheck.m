function [Dx,Sd]=gNavDayCheck(Dx,Sd)
%Check than date was changed in 00:00:00; correct bad date.
%function [Dx,Sd]=gNavDayCheck(Dx,Sd), where
%Dx - raw or scalar, serial date number of 1 corresponds to Jan-1-0000 or another day number (Julian, "point of origin", etc).
%Sd - raw, input second per day;
%[Dx,Sd] - raws, output serial date number and second per day.
%Example:
%Sd=gNavTime2Time('HMS32Sd',Head.HourOfDay,Head.MinuteOfHour,Head.SecondOfMinute); [Head.DayOfYear,Sd]=gNavDayCheck(Head.DayOfYear,Sd); [Head.HourOfDay,Head.MinuteOfHour,Head.SecondOfMinute]=gNavTime2Time('Sd2HMS3',Sd);

[tDay,t]=gNavTime2Time('DxSd2DmS',Dx,Sd);
dt=diff(t);L=find((dt>23.*3600)|(dt<-23.*3600));
for n=length(L):-1:1, 
    if (dt(L(n))<-23*3600), t((L(n)+1):end)=t((L(n)+1):end)+24.*3600;end;
    if (dt(L(n))>23*3600), t((L(n)+1):end)=t((L(n)+1):end)-24.*3600;end;
end;
[Dx,Sd]=gNavTime2Time('DmS2DxSd',tDay,t);

%mail@ge0mlib.com 15/10/2017