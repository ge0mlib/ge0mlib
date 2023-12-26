function HGps=gMagyReadG88Gps(fName,CompTimeLocShift)
%Read GPGGA-messages from text file (*.GPS) with was created MagLog Geometrics program
%function HGps=gMagyReadG88Gps(fName,CompTimeLocShift), where
%fName - reading file name;
%CompTimeLocShift - Computer time minus Utc_Gps time (in seconds).
%HGps - output data structure with fields: CompDay, CompTime, GpsDay, GpsTime, CompTimeLocShift, CompTimeDelta, CompTimeShift,...
%GpsLat, GpsLon, GpsFixQuality, GpsSatNum, GpsHorizDilution, GpsAltSea, GpsHgtGeoid, GpsDgpsUpdate, GpsDgpsId
%*.GPS file format example:
%$GPGGA,234303.85,5600.000366,N,14200.008168,E,11,12,1.0,00000.709,M,00000.000,M,0.00,*71  06/07/14 08:43:13.562
%$GPGGA,234304.87,5600.000551,N,14200.006776,E,11,12,1.0,00000.675,M,00000.000,M,0.00,*7B  06/07/14 08:43:14.578
%*.GPS fields: S Utc Lat LatC Lon LonC FixQuality SatNum HorizDilution AltSeaGps AltSeaC HgtGeoid HgtGeoidC DgpsUpdate DgpsId Cheksum DateM DateD DateY TimeH TimeM TimeS.
%Where $GPGGA include:
%$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,08,1004*47
%123519 – Fix taken at 12:35:19 UTC.
%4807.038,N – Latitude 48 deg 07.038' N.
%01131.000,E – Longitude 11 deg 31.000' E.
%Fix quality: 0=invalid; 1=GPS fix (SPS); 2=DGPS fix; 3=PPS fix; 4=Real Time Kinematic; 5=Float RTK; 6=estimated (dead reckoning) (2.3 feature); 7=Manual input mode; 8=Simulation mode.
%08 – Number of satellites being tracked.
%0.9 – Horizontal dilution of position.
%545.4,M – Altitude, Meters, above mean sea level.
%46.9,M – Height of geoid (mean sea level) above WGS84 ellipsoid.
%08 – Time in seconds since last DGPS update.
%1004 – DGPS station ID number.
%*47 – Checksum data, always begins with *.
%Example: HMag=gMagyReadG88Gps('c:\temp\123.GPS',10*3600);

[fId, mes]=fopen(fName,'r');
if ~isempty(mes), error(['Error gMagyReadG88Gps: ' mes]);end;
F=fread(fId,inf,'*char');fclose(fId);clear fId;
L=find(F==char(10));L=[[1;L(1:end-1)+1] L(1:end)]; %L=[first_symbol_for_line last_symbol_for_line]
%cut $GPGGA to F1
L_GPGGA=find(~((F(L(:,1))=='$')&(F(L(:,1)+1)=='G')&(F(L(:,1)+2)=='P')&(F(L(:,1)+3)=='G')&(F(L(:,1)+4)=='G')&(F(L(:,1)+5)=='A')));
F1=F;for n=length(L_GPGGA):-1:1, F1(L(L_GPGGA(n),1):L(L_GPGGA(n),2))=char(0);end;LL=F1==char(0);F1(LL)=[];

%processed $GPGGA: 1'$GPGGA' 2Utc 3Lat 4LatC 5Lon 6LonC 7FixQuality 8SatNum 9HorizDilution 10AltSea 11AltSeaC 12HgtGeoid 13HgtGeoidC 14DgpsUpdate 15DgpsId 16Cheksum 17DateM 18DateD 19DateY 20TimeH 21TimeM 22TimeS
C=textscan(F1,'%6c%f%f%c%f%c%f%f%f%f%c%f%c%f%f%2c%c%f%f%f%f%f%f','Delimiter',' :/,*', 'MultipleDelimsAsOne',0,'EndOfLine','\r\n');
HGps=struct('CompDay',[],'CompTime',[],'GpsDay',[],'GpsTime',[],'CompTimeLocShift',[],'CompTimeDelta',[],'CompTimeShift',[],...
    'GpsLat',C{3}','GpsLon',C{5}','GpsFixQuality',C{7}','GpsSatNum',C{8}','GpsHorizDilution',C{9}','GpsAltSea',C{10}','GpsHgtGeoid',C{12}','GpsDgpsUpdate',C{14}','GpsDgpsId',C{15}');
if any(C{1}~=repmat('$GPGGA',size(C{1},1),1)), disp('Warning gFMagyReadG88Gps: first symbols~=$GPGGA');end;
if any(C{17}~=' '), error('Error gMagyReadG88Gps: double space symbol not found');end;
if any(C{11}~='M'), error('Error gMagyReadG88Gps: AltSeaC~=M');end;
if any(C{13}~='M'), error('Error gMagyReadG88Gps: HgtGeoidC~=M');end;

%transform 3Lat 5Lon
HGps.GpsLon=fix(HGps.GpsLon./100)+mod(HGps.GpsLon,100)./60;HGps.GpsLat=fix(HGps.GpsLat./100)+mod(HGps.GpsLat,100)./60;
%fields: CompTime,GpsDay,GpsTime.
HGps.CompDay=datenum(C{20}+2000,C{18},C{19})';
HGps.CompTime=(C{21}.*3600+C{22}.*60+C{23})';
HGps.GpsTime=(fix(C{2}./10000).*3600+fix(mod(C{2},10000)./100).*60+mod(C{2},100))';
%fields: GpsDay
HGps.CompTimeLocShift=CompTimeLocShift;
HGps.GpsDay=gLogGpsDayCalc(HGps.CompDay,HGps.CompTime,HGps.GpsTime,CompTimeLocShift);
[HGps.CompTimeDelta,HGps.CompTimeShift]=gLogGpsCompTimeDelta(HGps.CompDay,HGps.CompTime,HGps.GpsDay,HGps.GpsTime);
 
%mail@ge0mlib.ru 17/01/2017