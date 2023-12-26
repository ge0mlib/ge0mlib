function Out=gJsf2000StringExtract(Head,StrType,varargin)
%Extract string with time-marks from Message Type 2000 (Sonar Virtual Ports Data; not annotated) or 2002 (NMEA String).
%function Out=gJsf2000StringExtract(Head,ByteTime,StrType,varargin), where
%Head - Message Header structure. Head includes also fields: TimeInSeconds, MillisecondsCurrentSecond, String (see fields description in gJsf2000Read function).
%StrType - extracted string type/format (G882,G882TVG,etc.);
%varargin - additional parameters for each string's type (see description in program's text);
%Out - output structure for each string's type (see description in program's text); includes CompDay,CompTime fields.
%Example:
%JsfHead=gJsfHeaderRead('d:\202205_Denar2\002_TestJsf\kkk.jsf',1);Head=gJsf2000Read(JsfHead,5);OutM=gJsf2000StringExtract(Head,'G882TVG',[1 0 1 0;1 0 1 0],gSmpRS232toSec(9600,8,0,0));
%JsfHead=gJsfHeaderRead('d:\202205_Denar2\002_TestJsf\kkk.jsf',1);Head=gJsf2002Read(JsfHead,1);OutG=gJsf2000StringExtract(Head,'GPGGA');
%======================================
%$GPGGA,004852.00,4549.3983338,N,14140.1657521,E,1,16,0.7,6.0013,M,27.7073,M,08,1004*63
%004852.00 – Fix taken at 00:48:52.00 UTC
%4549.3983338,N – Latitude 45 deg 49.3983338' N.
%14140.1657521,E – Longitude 141 deg 40.1657521' E.
%Fix quality: 0 = invalid; 1 = GPS fix (SPS); 2 = DGPS fix; 3 = PPS fix; 4 = Real Time Kinematic; 5=Float RTK; 6 = estimated (dead reckoning) (2.3 feature); 7 = Manual input mode; 8=Simulation mode.
%16 – Number of satellites being tracked.
%0.7 – Horizontal dilution of position.
%6.0013,M – Altitude, Meters, above mean sea level.
%27.7073,M – Height of geoid (mean sea level) above WGS84 ellipsoid.
%08 – Time in seconds since last DGPS update.
%1004 – DGPS station ID number.
%*63 – Checksum data, always begins with *.

Time=nan(size(Head.String)); %time mark for each symbol
[Day0,Time0]=gNavTime2Time('Ut2DxSd',Head.TimeInSeconds);Time0=Time0+Head.MillisecondsCurrentSecond./1000;%Day0,Time0 from UnixTime+Millisecond
[DayR,Time(1,:)]=gNavTime2Time('DxSdDm2DmS',Day0,Time0,Day0(1));%create [FirstDay, Seconds] from [Day0,Time0]
L=~isnan(Head.String);StringZ=char(Head.String(L)');TimeZ=Time(L)';

switch StrType,
    %==========G882TVG gradiometer with two altimeters and two depth sensors // Out fields: G88Koeff,CompDay,CompTime,MagAbsT,Signal,Depth,Altitude
    case 'G882TVG',
        K=varargin{1}; %K=[Alt1Scale Alt1Bias Depth1Scale Depth1Bias; Alt2Scale Alt2Bias Depth2Scale Depth2Bias] - the altimeter (1 and 2) and depth sensor (1 and 2) calibrations results.
        ByteTime=varargin{2}; %Time for one byte transmit; can calculate (1) with COM-port paramerers BaudRate,ByteSize,Parity,StopBits, using gSmpRS232toSec function, (2) by the gJsf2000StringExtract first passage
        L=[find(StringZ=='$') numel(StringZ)+1]; %last KeySym is dummy
        nn=0;tmp1=zeros(1,numel(L)-1);tmp2=zeros(2,numel(L)-1);Out=struct('G88Koeff',K,'CompDay',tmp1,'CompTime',tmp1,'MagAbsT',tmp2,'Signal',tmp2,'Depth',tmp2,'Altitude',tmp2,'TimeZ',tmp1+nan,'dTimeZ',tmp1+nan);
        for n=1:numel(L)-1,
            st=StringZ(L(n):L(n+1)-1); %one string with G882TVG >> $ 57961.472,0005,-00.69,00.00, 41964.112,0095,000.00,00.00 '\r\n'
            tm=TimeZ(L(n):L(n+1)-1); %time marks for "one string with G882TVG"
            if (st(end)~=char(10))&&(st(end-1)~=char(13))&&(st(2)~=' ')&&(numel(st)~=60), warning(['Line ' num2str(n) ', bad string by [\r\n] or [numel(st)~=60]']);
            else a=str2num(st(3:end-2));
                if numel(a)~=8, warning(['Line ' num2str(n) ', bad string by numel(num)~=8']);
                else nn=nn+1;
                    Out.MagAbsT(:,nn)=[a(1);a(5)];Out.Signal(:,nn)=[a(2);a(6)];Out.Depth(:,nn)=[a(3).*K(1,3)+K(1,4);a(7).*K(2,3)+K(2,4)];Out.Altitude(:,nn)=[a(4).*K(1,1)+K(1,2);a(8).*K(2,1)+K(2,2)];
                    LL=find(~isnan(tm));if any(~isempty(LL)),Out.TimeZ(nn)=tm(LL(1))-LL(1)*ByteTime;end;
                    [Out.CompDay(nn),Out.CompTime(nn)]=gNavTime2Time('DmS2DxSd',DayR,Out.TimeZ(nn)); %create [Day0,Time0] from [FirstDay, Seconds]                    
                    if numel(LL)>1,Out.dTimeZ(nn)=(tm(LL(1))-tm(LL(2)))./(LL(1)-LL(2));end;
                end;
            end;
        end;
        LL=find(~isnan(Out.dTimeZ));disp(['Mean ByteTime calculated: ' num2str(mean(Out.dTimeZ(LL))) ' ; numbers of calculations is ' num2str(numel(LL))]);
        Out=rmfield(Out,{'TimeZ','dTimeZ'});
    %==========NMEA GPGGA //Out fields: GpsDay,GpsTime,GpsLat,GpsLon,GpsFixQuality,GpsSatNum,GpsHorizDilution,GpsAltSea,GpsHgtGeoid,GpsDgpsUpdate,GpsDgpsId.
    %$GPGGA,100854.89,4023.963766,N,02639.309105,E,1,00,1.0,00002.114,M,00000.000,M,0.0,*72
    case 'GPGGA',
        L=[find(StringZ=='$') numel(StringZ)+1]; %last KeySym is dummy
        nn=0;tmp=zeros(1,numel(L)-1);Out=struct('CompDay',tmp,'CompTime',tmp,'GpsDay',tmp,'GpsTime',tmp,'GpsLat',tmp,'GpsLon',tmp,'GpsFixQuality',tmp,'GpsSatNum',tmp,'GpsHorizDilution',tmp,'GpsAltSea',tmp,'GpsHgtGeoid',tmp,'GpsDgpsUpdate',tmp,'GpsDgpsId',tmp);
        for n=1:numel(L)-1,
            st=StringZ(L(n):L(n+1)-1); %one string with G882TVG >> $ 57961.472,0005,-00.69,00.00, 41964.112,0095,000.00,00.00 '\r\n'
            tm=TimeZ(L(n):L(n+1)-1); %time marks for "one string with G882TVG"
            if (st(end)~=char(10))&&(st(end-1)~=char(13))&&any((st(4:7)~='GGA,')), warning(['Line ' num2str(n) ', bad string by [\r\n] or "GPGGA," or "*"']);
            else a=textscan(st,'%6c %f %f %c %f %c %f %f %f %f %c %f %c %f %f %2c','Delimiter',',*','MultipleDelimsAsOne',0,'EndOfLine','\r\n');
                if numel(a)~=16, warning(['Line ' num2str(n) ', bad string by numel(num)~=16']);
                else nn=nn+1;
                    if a{11}~='M',error('AltSeaC~=M');end; if a{13}~='M', error('HgtGeoidC~=M');end;
                    %Calc fields: CompTime,GpsDay,GpsTime,GpsDay.
                    if ~isempty(tm(1)),Out.TimeZ(nn)=tm(1);else,error('No timestamp for $GPGGA');end;
                    [Out.CompDay(nn),Out.CompTime(nn)]=gNavTime2Time('DmS2DxSd',DayR,Out.TimeZ(nn)); %create [Day0,Time0] from [FirstDay, Seconds]
                    Out.GpsTime(nn)=(fix(a{2}./10000).*3600+fix(mod(a{2},10000)./100).*60+mod(a{2},100));
                    Out.GpsDay(nn)=gLogGpsDayCalc(Out.CompDay(nn),Out.CompTime(nn),Out.GpsTime(nn),0);%0==CompTimeLocShift
                    %transform Lat Lon
                    Out.GpsLat(nn)=(fix(a{3}./100)+mod(a{3},100)./60);if a{4}=='S',Out.GpsLat(nn)=-Out.GpsLat(nn);end;
                    Out.GpsLon(nn)=(fix(a{5}./100)+mod(a{5},100)./60);if a{6}=='W',Out.GpsLon(nn)=-Out.GpsLon(nn);end;
                    Out.GpsFixQuality(nn)=a{7};Out.GpsSatNum(nn)=a{8};Out.GpsHorizDilution(nn)=a{9};Out.GpsAltSea(nn)=a{10};Out.GpsHgtGeoid(nn)=a{12};Out.GpsDgpsUpdate(nn)=a{14};Out.GpsDgpsId(nn)=a{15};
                end;
            end;
        end;
        Out=rmfield(Out,{'TimeZ'});
    otherwise, error('StrType not found.');
end;
if nn~=n,Out=gFieldsRowSet(Out,numel(L)-1,nn+1:n,[]);end;

%mail@ge0mlib.com 17/05/2022