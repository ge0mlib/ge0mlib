function GPGGU=gLogGpGguRead(fName,keyS,LDelim,CompTimeLocShift)
%Read $GPGGU data from files created by gComLog program.
%function GPGGU=gLogGpGguRead(fName,keyS,LDelim,CompTimeLocShift), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%keyS - key string ('$GPGGU' or same);
%LDelim - left delimiter for log-file;
%CompTimeLocShift - Computer time minus Utc_Gps time (in seconds);
%GPGGU - reading data structure with fields: CompDay,CompTime,GpsDay,GpsTime,GpsE,GpsLon,GpsN.
%Log-file (created by gComLog program) example:
%<00011878,$GPGGU, 284619.5,X, 1726702.6,Y,160307.00,*76
%or
%<00012876,$GPGGU, 284616.3,X, 1726701.7,Y,160308.00*72
%where
%< - left delimiter (symbol 1);
%00012876 - second per day./1000 (symbols 2-9);
%, - right delimiter (symbol 10);
%$GPGGU - GPGGU data.
%Using functions: gNavGpsDayCalc, gNavGpsCompTimeDelta.
%Example: GPGGU=gLogGpGguRead(('c:\temp\','$GPGGU','<',10*3600);
%--------------------------------------------------------------------------------------
%00012876,$GPGGU, 284616.3,X, 1726701.7,Y,160308.00,*72
%284616.3,X – Easting (m).
%1726701.7,Y – Northing (m).
%160308.00 – Fix taken at 16:03:08.00 UTC.
%*72 – Checksum data, always begins with *.
%--------------------------------------------------------------------------------------

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
GPGGU=struct('CompDay',[],'CompTime',[],'GpsDay',[],'GpsTime',[],'GpsE',[],'GpsN',[]);
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);
    F=fread(fId,inf,'*char');fclose(fId);clear fId;
    L=find(F==LDelim);L=[L [L(2:end)-1;size(F,1)]]; %L=[first_symbol_for_line last_symbol_for_line]
    L1=find(F(L(:,1)+9)~=F(L(1,1)+9));if ~isempty(L1), error(['RightDelimiter not true, Lines ' num2str(L1)]);end;
    %========find $GPGGU===============
    Mask=(F(L(:,1)+10)==keyS(1))&(F(L(:,1)+11)==keyS(2))&(F(L(:,1)+12)==keyS(3))&(F(L(:,1)+13)==keyS(4))&(F(L(:,1)+14)==keyS(5))&(F(L(:,1)+15)==keyS(6))&(F(L(:,2)-4)=='*'); %if line is $GPGGU...*
    if any(Mask),
        %delete all ~GPGGU lines
        L_Mask=find(~Mask);F1=F;
        for n=length(L_Mask):-1:1, F1(L(L_Mask(n),1):L(L_Mask(n),2))=char(0);end;
        LL=F1==char(0);F1(LL)=[];
        %processed $GPGGU: 1LeftDelim 2CompTime 3'$GPGGU' 4East 5EastC 6North 7NorthC 8Utc 9Cheksum
        LL=strfind(F1',',*');F1(LL)=[];
        C=textscan(F1,'%c %f %6c %f %c %f %c %f %2c','Delimiter',',*','MultipleDelimsAsOne',0,'EndOfLine','\r\n');
        %Calc fields: CompTime,GpsDay,GpsTime,GpsDay.
        CompTime=C{2}'./1000;
        tmp=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));CompDay=repmat(tmp,size(CompTime));
        GpsTime=(fix(C{8}./10000).*3600+fix(mod(C{8},10000)./100).*60+mod(C{8},100))';
        GpsDay=gLogGpsDayCalc(CompDay,CompTime,GpsTime,CompTimeLocShift);
        %add structs
        GPGGU1=struct('CompDay',CompDay,'CompTime',CompTime,'GpsDay',GpsDay,'GpsTime',GpsTime,'GpsE',C{4}','GpsN',C{6}');
        GPGGU=gZRowAppend(GPGGU,GPGGU1,size(GPGGU.CompDay,2));
    end;
end;
GPGGU.CompTimeLocShift=CompTimeLocShift;
[GPGGU.CompTimeDelta,GPGGU.CompTimeShift]=gLogGpsCompTimeDelta(GPGGU.CompDay,GPGGU.CompTime,GPGGU.GpsDay,GPGGU.GpsTime);

%remove empty
names=fieldnames(GPGGU);
for n=1:size(names,1),
    a=GPGGU.(names{n});
    if isempty(a)||all(isnan(a)), GPGGU=rmfield(GPGGU,names{n});end;
end;

%mail@ge0mlib.com 15/09/2017