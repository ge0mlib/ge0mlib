function GPGGA=gLogGpGgaRead(fName,keyS,LDelim,CompTimeLocShift)
%Read $GPGGA data from files created by gComLog program.
%function GPGGA=gLogGpGgaRead(fName,keyS,LDelim,CompTimeLocShift), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%keyS - key string ('$GPGGA' or same);
%LDelim - left delimiter for log-file;
%CompTimeLocShift - Computer time minus Utc_Gps time (in seconds);
%GPGGA - reading data structure with fields: CompDay,CompTime,GpsDay,GpsTime,GpsLat,GpsLon,GpsFixQuality,GpsSatNum,GpsHorizDilution,GpsAltSea,GpsHgtGeoid,GpsDgpsUpdate,GpsDgpsId.
%Log-file (created by gComLog program) example:
%~38995230,$GPGGA,004852.00,4549.3983338,N,14140.1657521,E,1,16,0.7,6.0013,M,27.7073,M,,*63
%~38996240,$GPGGA,004853.00,4549.3987483,N,14140.1706720,E,1,16,0.7,5.8322,M,27.7073,M,,*6D
%~ - left delimiter (symbol 1);
%38995230 - second per day./1000 (symbols 2-9);
%, - right delimiter (symbol 10);
%$GPGGA... - GPGGA data.
%Using functions: gNavGpsDayCalc, gNavGpsCompTimeDelta.
%Example: GPGGA=gLogGpGgaRead('c:\temp\','$GPGGA','~',10*3600);
%--------------------------------------------------------------------------------------
%$GPGGA,004852.00,4549.3983338,N,14140.1657521,E,1,16,0.7,6.0013,M,27.7073,M,08,1004*63
%004852.00 – Fix taken at 00:48:52.00 UTC.
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
%--------------------------------------------------------------------------------------

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
GPGGA=struct('CompDay',[],'CompTime',[],'GpsDay',[],'GpsTime',[],'GpsLat',[],'GpsLon',[],'GpsFixQuality',[],'GpsSatNum',[],'GpsHorizDilution',[],'GpsAltSea',[],'GpsHgtGeoid',[],'GpsDgpsUpdate',[],'GpsDgpsId',[]);
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(['gLogGpGgaRead: ' mes]);end;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);
    F=fread(fId,inf,'*char');fclose(fId);clear fId;
    L=find(F==LDelim);L=[L [L(2:end)-1;size(F,1)]]; %L=[first_symbol_for_line last_symbol_for_line]
    L1=find(F(L(:,1)+9)~=F(L(1,1)+9));if ~isempty(L1), error(['gLogGpGgaRead: RightDelimiter not true, Lines ' num2str(L1)]);end;
    %========find $GPGGA===============
    Mask=(F(L(:,1)+10)==keyS(1))&(F(L(:,1)+11)==keyS(2))&(F(L(:,1)+12)==keyS(3))&(F(L(:,1)+13)==keyS(4))&(F(L(:,1)+14)==keyS(5))&(F(L(:,1)+15)==keyS(6))&(F(L(:,2)-4)=='*'); %if line is $GPGGA...*
    if any(Mask),
        %delete all ~GPGGA lines
        L_Mask=find(~Mask);F1=F;
        for n=length(L_Mask):-1:1, F1(L(L_Mask(n),1):L(L_Mask(n),2))=char(0);end;
        LL=F1==char(0);F1(LL)=[];
        %processed $GPGGA: 1LeftDelim 2CompTime 3'$GPGGA' 4Utc 5Lat 6LatC 7Lon 8LonC 9FixQuality 10SatNum 11HorizDilution 12AltSea 13AltSeaC 14HgtGeoid 15HgtGeoidC 16DgpsUpdate 17DgpsId 18Cheksum
        C=textscan(F1,'%c %f %6c %f %f %c %f %c %f %f %f %f %s %f %s %f %f %2c','Delimiter',',*','MultipleDelimsAsOne',0,'EndOfLine','\r\n');
        if any(cell2mat(C{13})~='M'), error('gLogGpGgaRead: AltSeaC~=M');end;
        if any(cell2mat(C{15})~='M'), error('gLogGpGgaRead: HgtGeoidC~=M');end;
        %Calc fields: CompTime,GpsDay,GpsTime,GpsDay.
        CompTime=C{2}'./1000;
        CompDay1=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));CompDay=repmat(CompDay1,size(CompTime));
        GpsTime=(fix(C{4}./10000).*3600+fix(mod(C{4},10000)./100).*60+mod(C{4},100))';
        GpsDay=gLogGpsDayCalc(CompDay,CompTime,GpsTime,CompTimeLocShift);
        %transform Lat Lon
        GpsLat=(fix(C{5}'./100)+mod(C{5}',100)./60);GpsLat(C{6}'=='S')=-GpsLat(C{6}'=='S');
        GpsLon=(fix(C{7}'./100)+mod(C{7}',100)./60);GpsLon(C{8}'=='W')=-GpsLon(C{8}'=='W');
        %add structs
        GPGGA1=struct('CompDay',CompDay,'CompTime',CompTime,'GpsDay',GpsDay,'GpsTime',GpsTime,'GpsLat',GpsLat,'GpsLon',GpsLon,'GpsFixQuality',C{9}',...
            'GpsSatNum',C{10}','GpsHorizDilution',C{11}','GpsAltSea',C{12}','GpsHgtGeoid',C{14}','GpsDgpsUpdate',C{16}','GpsDgpsId',C{17}');
        GPGGA=gFieldsRowAppend(GPGGA,GPGGA1,size(GPGGA.CompDay,2));
    end;
end;
GPGGA.CompTimeLocShift=CompTimeLocShift;
[GPGGA.CompTimeDelta,GPGGA.CompTimeShift]=gLogGpsCompTimeDelta(GPGGA.CompDay,GPGGA.CompTime,GPGGA.GpsDay,GPGGA.GpsTime);

%remove empty
names=fieldnames(GPGGA);
for n=1:size(names,1),
    a=GPGGA.(names{n});
    if isempty(a)||all(isnan(a)), GPGGA=rmfield(GPGGA,names{n});end;
end;

%mail@ge0mlib.com 15/09/2017