function [CompTimeDelta,CompTimeShift]=gLogGpsCompTimeDelta(CompDay,CompTime,GpsDay,GpsTime)
%Calculate difference between [GpsDay,GpsTime] and [ComputerDay,ComputerTime] in seconds.
%function [CompTimeDelta,CompTimeShift]=gLogGpsCompTimeDelta(CompDay,CompTime,GpsDay,GpsTime), where
%GpsDay - a serial Gps date number of 1 corresponds to Jan-1-0000 or used GpsS=gNGpsDayCalc(GpsS);
%GpsTime - GpsTime (second in day);
%CompDay - a serial Computer date number of 1 corresponds to Jan-1-0000;
%CompTime - Computer time (second in day);
%CompTimeShift - mean difference -- computer time minus Gps time (in seconds);
%CompTimeDelta - vector, difference between Computer time and Gps time for each point decrement to CompTimeShift.
%Example: [CompTimeDelta,CompTimeShift]=gLogGpsCompTimeDelta(Z.CompDay,Z.CompTime,Z.GpsDay,Z.GpsTime)

L=~isnan(CompDay);d=round(mean(CompDay(L)));
CompTimeDelta=((CompDay-d).*86400+CompTime)-((GpsDay-d).*86400+GpsTime);
L=~isnan(CompTimeDelta);CompTimeShift=mean(CompTimeDelta(L));
CompTimeDelta=CompTimeDelta-CompTimeShift;

%mail@ge0mlib.com 23/07/2016