function GpsDay=gLogGpsDayCalc(CompDay,CompTime,GpsTime,CompTimeLocShift)
%Calculate GpsDay using CompDay, CompTime, GpsTime.
%function GpsDay=gLogGpsDayCalc(CompDay,CompTime,GpsTime,CompTimeLocShift), where
%GpsTime - GpsTime (second in day);
%CompDay - a serial Computer date number of 1 corresponds to Jan-1-0000;
%CompTime - Computer time (second in day);
%CompTimeLocShift - Computer time minus Gps time (in seconds);
%GpsDay - Estimated serial Gps date number of 1 corresponds to Jan-1-0000.
%Mathematics:
%GpsDay*86400+GpsSec=CompDay*86400+CompSec-LocHour*3600+Error, where LocHour~GpsCompTimeShift
%GpsDay-d=round(((CompDay-d)*86400+CompSec-LocHour*3600-GpsSec)/86400+Error/86400), where d=round(mean(CompDay)), Error<0.5
%Example: GpsDay=gLogGpsDayCalc(Z.CompDay,Z.CompTime,Z.GpsTime,10*3600);

if (CompTimeLocShift<25)&&(CompTimeLocShift~=0), warning('The CompTimeLocShift is SECONDS, please check!');end;
L=~isnan(CompDay);d=fix(mean(CompDay(L)));
GpsDay=round(((CompDay-d).*86400+CompTime-CompTimeLocShift-GpsTime)./86400)+d;

%mail@ge0mlib.com 23/07/2016