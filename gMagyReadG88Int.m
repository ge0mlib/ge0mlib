function HInt=gMagyReadG88Int(fName,key)
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

switch key,
    case 1,
        [fId, mes]=fopen(fName,'r');
        if ~isempty(mes), error(['Error gFMagyReadG880Int: ' mes]);end;
        Title=fgetl(fId);
        if ~strcmp(Title,'MAG1 SIGNAL1 DEPTH1(m) ALTITUDE1(m) DATE TIME GPS_LON GPS_LAT SHIFT_LON SHIFT_LAT ATARGETS NMAGS LON_MAG1 LAT_MAG1 GPS_QC GPS_HEIGHT LINE LAYBACK(m) '),fclose(fId);error('Error gFMagyReadG880Int: Not valid first Line');end;
        %Mag Signal Depth Altitude DateM DateD DateY TimeH TimeM TimeS GpsLon GpsLat ShiftLon ShiftLat Atargets Nmags LonMag LatMag GpsFixQuality GpsHgtGeoid Line Layback
        C=textscan(fId,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%c','Delimiter',' :/','MultipleDelimsAsOne',0,'EndOfLine','\r\n');fclose(fId);
        if any(C{23}~=' '), error('Error gFMagyReadG880Int: double space symbol not found');end;
        HInt=struct('CompDay',datenum(C{7}+2000,C{5},C{6})','CompTime',(C{8}.*3600+C{9}.*60+C{10})','GpsLon',C{11}','GpsLat',C{12}','GpsFixQuality',C{19}','GpsHgtGeoid',C{20}','MagAbsT',C{1}','MagPrecSignal',C{2}','Depth',C{3}','Altitude',C{4}',...
            'INT_ShiftLon',C{13}','INT_ShiftLat',C{14}','INT_Atargets',C{15}','INT_Nmags',C{16}','INT_LonMag',C{17}','INT_LatMag',C{18}','INT_Line',C{21}','INT_Layback',C{22}');
    case 2,
        [fId, mes]=fopen(fName,'r');
        if ~isempty(mes), error(['Error gFMagyReadG882Int: ' mes]);end;
        Title=fgetl(fId);
        if ~strcmp(Title,'MAG1 SIGNAL1 DEPTH1(m) ALTITUDE1(m) DATE TIME GPS_LON GPS_LAT SHIFT_LON SHIFT_LAT ATARGETS NMAGS LON_MAG1 LAT_MAG1 GPS_QC GPS_HEIGHT LINE ROUTE LAYBACK(m) '),fclose(fId);error('Error gFMagyReadG882Int: Not valid first Line');end;
        %Mag Signal Depth Altitude DateM DateD DateY TimeH TimeM TimeS GpsLon GpsLat ShiftLon ShiftLat Atargets Nmags LonMag LatMag GpsFixQuality GpsHgtGeoid Line Route Layback
        C=textscan(fId,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%f%c','Delimiter',' :/','MultipleDelimsAsOne',0,'EndOfLine','\r\n');fclose(fId);
        if any(C{24}~=' '), error('Error gFMagyReadG882Int: double space symbol not found');end;
        HInt=struct('CompDay',datenum(C{7}+2000,C{5},C{6})','CompTime',(C{8}.*3600+C{9}.*60+C{10})','GpsLon',C{11}','GpsLat',C{12}','GpsFixQuality',C{19}','GpsHgtGeoid',C{20}','MagAbsT',C{1}','MagPrecSignal',C{2}','Depth',C{3}','Altitude',C{4}',...
            'INT_ShiftLon',C{13}','INT_ShiftLat',C{14}','INT_Atargets',C{15}','INT_Nmags',C{16}','INT_LonMag',C{17}','INT_LatMag',C{18}','INT_Line',C{21}','INT_Layback',C{23}');
    otherwise, error('Unexpected format key');
end;

%mail@ge0mlib.com 24/11/2019