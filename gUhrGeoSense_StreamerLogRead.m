function Log=gUhrGeoSense_StreamerLogRead(fName,varargin)
%Read data from Station Log-file was created Multi-Trace Data Acquisition software (GEO Marine Survey Systems) for MultiTrace station.
%WARNING!!! There is hint >>  VESSEL_HDG contained GpsTime.
%function Log=gUhrGeoSense_StreamerLogRead(fName,varargin), where
%fName - reading file name;
%varargin - divider for GpsTime;
%Log - output structure, includes: FFID, SHOTID, LINE, SN, TS, CompDay, CompTime1, GpsE, GpsN, FIX, GpsDay, GpsTime, CompDay2, CompTime2
%Example: out=gUhrGeoSense_StreamerLogRead('c:\temp\Day1\18661018.log');
%=======================
%Log file format example:
%FFID,455, SHOTID,6621, LINE,130, SN,18661018, TS,800.0, 25/08/2017 12:55:24.203 UTC,VESSEL_X,648047.970000000, VESSEL_Y,8163329.690000000, VESSEL_FIX,455.000000000, VESSEL_HDG,125510.220000000, VESSEL_AZI,0.000000000, VESSEL_FEA,0.000000000, VESSEL_SPEED,393308.209639116, VESSEL_GPSTIME,25/08/2017 12:55:24.166 UTC,
%=======================

[fId, mes]=fopen(fName,'r');if ~isempty(mes), error(['Error gFGeoSenseLWStreamerLogRead: ' mes]);end;
C=textscan(fId,'FFID%f SHOTID%f LINE%f SN%f TS%f%f%f%f%f%f%f UTC,VESSEL_X%f  VESSEL_Y%f VESSEL_FIX%f VESSEL_HDG%f VESSEL_AZI%f VESSEL_FEA%f VESSEL_SPEED%f VESSEL_GPSTIME%f%f%f%f%f%f%*[^\n]','Delimiter',' :/,', 'MultipleDelimsAsOne',1);
CompDay1=datenum(C{8},C{7},C{6});CompTime1=C{9}.*3600+C{10}.*60+C{11};
CompDay2=datenum(C{21},C{20},C{19});CompTime2=C{22}.*3600+C{23}.*60+C{24};
if ~isempty(varargin), C{15}=C{15}./varargin{1};end;
GpsTime=fix(C{15}./10000).*3600+fix(mod(C{15},10000)./100).*60+mod(C{15},100);
GpsDay=gLogGpsDayCalc(CompDay1,CompTime1,GpsTime,0);
Log=struct('FFID',C{1}','SHOTID',C{2}','LINE',C{3}','SN',C{4}','TS',C{5}','CompDay',CompDay1','CompTime',CompTime1','GpsE',C{12}','GpsN',C{13}','FIX',C{14}','GpsDay',GpsDay','GpsTime',GpsTime','CompDay2',CompDay2','CompTime2',CompTime2');

%mail@ge0mlib.com 22/09/2016