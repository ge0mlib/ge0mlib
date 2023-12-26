function HMag=gMagyObsRead(fName)
%Read data from text file with was created MagLog Geometrics program for G88x single magnetometer (*.INT)
%function HInt=gMagyReadG88Int(fName,key), where
%fName - reading file name;
%key- the key for Int-file format;
%HInt - reading data structure with fields: CompDay,CompTime,GpsLon,GpsLat,GpsFixQuality,GpsHgtGeoid,'MagAbsT,MagPrecSignal,Depth,Altitude,INT_ShiftLon,INT_ShiftLat,INT_Atargets,INT_Nmags,INT_LonMag,INT_LatMag,INT_Line,INT_Layback
%if key==1, then *.INT file format example:
%MAG1 SIGNAL1 DEPTH1(m) ALTITUDE1(m) DATE TIME GPS_LON GPS_LAT SHIFT_LON SHIFT_LAT ATARGETS NMAGS LON_MAG1 LAT_MAG1 GPS_QC GPS_HEIGHT LINE LAYBACK(m) 
%56636.708 1211.000 1.318 4.958 06/07/14 08:43:12.562 142.0003269 56.0009905 142.0003269 56.0009905 0 1 142.0003269 56.0009905 11 0.693 0 0.00  
%56636.784 1182.000 1.250 4.958 06/07/14 08:43:12.671 142.0003243 56.0009903 142.0003243 56.0009903 0 1 142.0003243 56.0009903 11 0.695 0 0.00  
%INT file fields: Mag Signal Depth Altitude DateM DateD DateY TimeH TimeM TimeS GpsLon GpsLat ShiftLon ShiftLat Atargets Nmags LonMag LatMag GpsFixQuality GpsHgtGeoid Line Layback.
%if key==2, then *.INT file format example (Route added):
%MAG1 SIGNAL1 DEPTH1(m) ALTITUDE1(m) DATE TIME GPS_LON GPS_LAT SHIFT_LON SHIFT_LAT ATARGETS NMAGS LON_MAG1 LAT_MAG1 GPS_QC GPS_HEIGHT LINE ROUTE LAYBACK(m) 
%56636.708 1211.000 1.318 4.958 06/07/14 08:43:12.562 142.0003269 56.0009905 142.0003269 56.0009905 0 1 142.0003269 56.0009905 11 0.693 0 NO_PLANNED_ROUTE 0.00  
%56636.784 1182.000 1.250 4.958 06/07/14 08:43:12.671 142.0003243 56.0009903 142.0003243 56.0009903 0 1 142.0003243 56.0009903 11 0.695 0 NO_PLANNED_ROUTE 0.00  
%INT file fields: Mag Signal Depth Altitude DateM DateD DateY TimeH TimeM TimeS GpsLon GpsLat ShiftLon ShiftLat Atargets Nmags LonMag LatMag GpsFixQuality GpsHgtGeoid Line Route Layback.
%Example: HInt=gMagyReadG88Int('c:\temp\123.INT',1);


C=dlmread(fName);
HMag=struct('GpsDay',datenum(C(:,1),C(:,2),C(:,3))','GpsTime',(C(:,4).*3600+C(:,5).*60+C(:,6))','MagX',C(:,7)','MagY',C(:,8)','MagZ',C(:,9)','MagAbsT',C(:,10)');


%mail@ge0mlib.com 24/11/2019