function GPGLL=gLogGpGllRead(fName,keyS,LDelim,CompTimeLocShift)
%Read $GPGLL data from files created by gComLog program.
%function GPGLL=gLogGpGllRead(fName,keyS,LDelim,CompTimeLocShift), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%keyS - key string ('$GPGLL' or same);
%LDelim - left delimiter for log-file;
%CompTimeLocShift - Computer time minus Utc_Gps time (in seconds);
%GPGLL - reading data structure with fields: CompDay,CompTime,GpsDay,GpsTime,GpsLat,GpsLon,GpsFixQuality.
%Log-file (created by gComLog program) example:
%<68183656,$GPGLL,4303.70906,N,13152.96378,E,080636.00,A*04
%or
%<68184656,$GPGLL,4303.70906,N,13152.96378,E,080636.99,A,*04
%where
%< - left delimiter (symbol 1);
%68184656 - second per day./1000 (symbols 2-9);
%, - right delimiter (symbol 10);
%$GPGLL... - GPGLL data.
%Using functions: gNavGpsDayCalc, gNavGpsCompTimeDelta.
%Example: GPGLL=gLogGpGllRead('c:\temp\','$GPGLL','<',10*3600);
%--------------------------------------------------------------------------------------
%$GPGLL,4303.70906,N,13152.96378,E,080636.00,A*04
%4303.70906,N – Latitude 45 deg 03.70906' N.
%13152.96378,E – Longitude 131 deg 52.96378' E.
%080636.00 – Fix taken at 08:06:36.00 UTC.
%Status field: A = Data valid; V = Data not valid.
%*04 – Checksum data, always begins with *.
%--------------------------------------------------------------------------------------

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
GPGLL=struct('CompDay',[],'CompTime',[],'GpsDay',[],'GpsTime',[],'GpsLat',[],'GpsLon',[],'GpsFixQuality',[]);
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(['gLogGpGllRead: ' mes]);end;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);
    F=fread(fId,inf,'*char');fclose(fId);clear fId;
    L=find(F==LDelim);L=[L [L(2:end)-1;size(F,1)]]; %L=[first_symbol_for_line last_symbol_for_line]
    L1=find(F(L(:,1)+9)~=F(L(1,1)+9));if ~isempty(L1), error(['gLogGpGllRead: RightDelimiter not true, Lines ' num2str(L1)]);end;
    %========find $GPGLL===============
    Mask=(F(L(:,1)+10)==keyS(1))&(F(L(:,1)+11)==keyS(2))&(F(L(:,1)+12)==keyS(3))&(F(L(:,1)+13)==keyS(4))&(F(L(:,1)+14)==keyS(5))&(F(L(:,1)+15)==keyS(6))&(F(L(:,2)-4)=='*'); %if line is $GPGLL...* 
    if any(Mask),
        %delete all ~GPGLL lines
        L_Mask=find(~Mask);F1=F;
        for n=length(L_Mask):-1:1, F1(L(L_Mask(n),1):L(L_Mask(n),2))=char(0);end;
        LL=F1==char(0);F1(LL)=[];
        %processed $GPGLL: 1LeftDelim 2CompTime 3'$GPGLL' 4Lat 5LatC 6Lon 7LonC 8Utc 9FixQuality 10Cheksum
        LL=strfind(F1',',*');F1(LL)=[];
        C=textscan(F1,'%c %f %6c %f %c %f %c %f %c %2c','Delimiter',',*','MultipleDelimsAsOne',0,'EndOfLine','\r\n');
        %Calc fields: CompTime,GpsDay,GpsTime,GpsDay.
        CompTime=C{2}'./1000;
        tmp=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));CompDay=repmat(tmp,size(CompTime));
        GpsTime=(fix(C{8}./10000).*3600+fix(mod(C{8},10000)./100).*60+mod(C{8},100))';
        GpsDay=gLogGpsDayCalc(CompDay,CompTime,GpsTime,CompTimeLocShift);
        %transform Lat Lon
        GpsLat=(fix(C{4}'./100)+mod(C{4}',100)./60);GpsLat(C{5}'=='S')=-GpsLat(C{5}'=='S');
        GpsLon=(fix(C{6}'./100)+mod(C{6}',100)./60);GpsLat(C{7}'=='W')=-GpsLat(C{7}'=='W');
        %add structs
        GPGLL1=struct('CompDay',CompDay,'CompTime',CompTime,'GpsDay',GpsDay,'GpsTime',GpsTime,'GpsLat',GpsLat,'GpsLon',GpsLon,'GpsFixQuality',double(C{9}'));
        GPGLL=gZRowAppend(GPGLL,GPGLL1,size(GPGLL.CompDay,2));
    end;
end;
GPGLL.CompTimeLocShift=CompTimeLocShift;
[GPGLL.CompTimeDelta,GPGLL.CompTimeShift]=gLogGpsCompTimeDelta(GPGLL.CompDay,GPGLL.CompTime,GPGLL.GpsDay,GPGLL.GpsTime);

%remove empty
names=fieldnames(GPGLL);
for n=1:size(names,1),
    a=GPGLL.(names{n});
    if isempty(a)||all(isnan(a)), GPGLL=rmfield(GPGLL,names{n});end;
end;

%mail@ge0mlib.com 15/09/2017