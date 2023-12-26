function GPAVL=gLogGpAvlRead(fName,keyS,LDelim,CompTimeLocShift)
%Read $GPAVL data from files created by gComLog program.
%function GPAVL=gLogGpAvlRead(fName,keyS,LDelim,CompTimeLocShift), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%keyS - key string ('$GPAVL' or same);
%LDelim - left delimiter for log-file;
%CompTimeLocShift - Computer time minus Utc_Gps time (in seconds);
%GPAVL - reading data structure with fields: CompDay,CompTime,GpsDay,GpsTime,Rn,GpsLat,GpsLon,GpsHgtGeoid, Veast, Vnorth, Vup, Xecef, Yecef, Zecef, Vxecef, Vyecef, Vzecef.
%Log-file (created by gComLog program) example:
%~45157697,$GPAVL,R1,5561000.000,46.21880000,142.79169707,27.256,-1.657,0.539,0.809,351174.000,-3520921.763,2673329.360,4582128.127,0.866,1.423,0.957*3A
%~45157748,$GPAVL,R2,5561000.000,46.22315193,142.79206287,25.175,0.230,0.005,-0.014,351174.000,-3520659.509,2673094.804,4582461.317,-0.128,-0.191,-0.007*1F
%~ - left delimiter (symbol 1);
%45157697 - second per day./1000 (symbols 2-9);
%, - right delimiter (symbol 10);
%$GPAVL... - GPAVL data.
%Using functions: gNavGpsDayCalc, gNavGpsCompTimeDelta.
%Example: GPAVL=gLogGpAvlRead('c:\temp\','$GPAVL','~',10*3600);
%--------------------------------------------------------------------------------------
%$GPAVL,R1,5561000.000,46.21880000,142.79169707,27.256,-1.657,0.539,0.809,351174.000,-3520921.763,2673329.360,4582128.127,0.866,1.423,0.957*3A
%$GPAVL,R2,5561000.000,46.22315193,142.79206287,25.175,0.230,0.005,-0.014,351174.000,-3520659.509,2673094.804,4582461.317,-0.128,-0.191,-0.007*1F
%R1 – Remote number (R1, R2…).
%5561000.000 - Utc UTC milliseconds of the day.
%46.21880000 - Latitude (degrees).
%142.79169707 - Longitude (degrees).
%27.256 - Height (meters).
%-1.657 - Velocity East.
%0.539 - Velocity North.
%0.809 - Velocity Up.
%351174.000 - Gpstime seconds of the week.
%-3520921.763 - X ECEF coordinate.
%2673329.360 - Y ECEF coordinate.
%4582128.127 - Z ECEF coordinate.
%0.866 - X ECEF velocity.
%1.423 - Y ECEF velocity.
%0.957 - Z ECEF velocity.
%*3A – Checksum data, always begins with *.
%--------------------------------------------------------------------------------------

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
GPAVL=struct('CompDay',[],'CompTime',[],'GpsDay',[],'GpsTime',[],'RNum',[],'GpsLat',[],'GpsLon',[],'GpsHgtGeoid',[],'Veast',[],'Vnorth',[],'Vup',[],'Xecef',[],'Yecef',[],'Zecef',[],'Vxecef',[],'Vyecef',[],'Vzecef',[]);
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);
    F=fread(fId,inf,'*char');fclose(fId);clear fId;
    L=find(F==LDelim);L=[L [L(2:end)-1;size(F,1)]]; %L=[first_symbol_for_line last_symbol_for_line]
    L1=find(F(L(:,1)+9)~=F(L(1,1)+9));if ~isempty(L1), error(['RightDelimiter not true, Lines ' num2str(L1)]);end;
    %========find $GPAVL===============
    Mask=(F(L(:,1)+10)==keyS(1))&(F(L(:,1)+11)==keyS(2))&(F(L(:,1)+12)==keyS(3))&(F(L(:,1)+13)==keyS(4))&(F(L(:,1)+14)==keyS(5))&(F(L(:,1)+15)==keyS(6))&(F(L(:,2)-4)=='*'); %if line is $GPGGA...*
    Mask2=(L(:,2)-L(:,1))<100;
    if any(Mask),
        %delete all ~GPAVL lines
        L_Mask=find(~Mask|Mask2);F1=F;
        for n=length(L_Mask):-1:1, F1(L(L_Mask(n),1):L(L_Mask(n),2))=char(0);end;
        LL=F1==char(0);F1(LL)=[];
        %processed $GPAVL: 1LeftDelim 2CompTime 3'$GPAVL' 4'R' 5Num 6Utc_ms_day 7Lat 8Lon 9HgtGeoid 10Veast 11Vnorth 12Vup 13Gps_second_week 14Xecef 15Yecef 16Zecef 17Vxecef 18Vyecef 19Vzecef 20'*' 21Cheksum
        %$GPAVL,R1,5561000.000,46.21880000,142.79169707,27.256,-1.657,0.539,0.809,351174.000,-3520921.763,2673329.360,4582128.127,0.866,1.423,0.957*3A
        [C,pos]=textscan(F1,'%c %f %6c %c%d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %c%2c','Delimiter',',','MultipleDelimsAsOne',0,'EndOfLine','\r\n');
        if pos~=numel(F1), error([fNameN ' file format error symbol -- ' num2str(pos)]);end; 
        if any(C{4}~='R'), error('Remote number~=R#');end;
        if any(C{20}~='*'), error('Not found symbol * before checksum');end;
        %Calc fields: CompTime,GpsDay,GpsTime,GpsDay.
        CompTime=C{2}'./1000;
        CompDay1=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));CompDay=repmat(CompDay1,size(CompTime));
        GpsTime=C{6}'./1000;
        GpsDay=gLogGpsDayCalc(CompDay,CompTime,GpsTime,CompTimeLocShift);
        %add structs
        GPAVL1=struct('CompDay',CompDay,'CompTime',CompTime,'GpsDay',GpsDay,'GpsTime',GpsTime,'RNum',C{5}','GpsLat',C{7}','GpsLon',C{8}','GpsHgtGeoid',C{9}',...
            'Veast',C{10}','Vnorth',C{11}','Vup',C{12}','Xecef',C{14}','Yecef',C{15}','Zecef',C{16}','Vxecef',C{17}','Vyecef',C{18}','Vzecef',C{19}');
        GPAVL=gFieldsRowAppend(GPAVL,GPAVL1,size(GPAVL.CompDay,2));
    end;
end;
GPAVL.CompTimeLocShift=CompTimeLocShift;
[GPAVL.CompTimeDelta,GPAVL.CompTimeShift]=gLogGpsCompTimeDelta(GPAVL.CompDay,GPAVL.CompTime,GPAVL.GpsDay,GPAVL.GpsTime);

%remove empty
names=fieldnames(GPAVL);
for n=1:size(names,1),
    a=GPAVL.(names{n});
    if isempty(a)||all(isnan(a)), GPAVL=rmfield(GPAVL,names{n});end;
end;

%mail@ge0mlib.com 15/09/2017