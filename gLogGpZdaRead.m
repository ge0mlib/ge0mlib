function GPZDA=gLogGpZdaRead(fName,keyS,LDelim)
%Read $GPZDA data from files created by gComLog program.
%function GPZDA=gLogGpZdaRead(fName,keyS,LDelim), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%keyS - key string ('$GPZDA' or same);
%LDelim - left delimiter for log-file;
%GPZDA - reading data structure with fields: CompDay,CompTime,GpsDay,GpsTime,LocDay,LocTime.
%Log-file (created by gComLog program) example:
%~39600144,$INZDA,235959.0034,22,05,2016,,*70
%~39601132,$INZDA,000000.0034,23,05,2016,,*70
%~ - left delimiter (symbol 1);
%39600144 - second per day./1000 (symbols 2-9);
%, - right delimiter (symbol 10);
%$INZDA... - $GPZDA data.
%Example: GPZDA=gLogGpZdaRead('c:\temp\','$GPZDA','~');
%--------------------------------------------------------------------------------------
%$GPZDA,235959.0034,22,05,2016,13,59*70
%235959.0034 – Fix taken at 23:59:59.0034 UTC.
%22 - UTC day.
%05 - UTC month.
%2016 - UTC year.
%13 - Local zone hours, 00 to ±13 hrs
%59 -  Local zone minutes, 00 to +59
%*63 – Checksum data, always begins with *.
%--------------------------------------------------------------------------------------

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
GPZDA=struct('CompDay',[],'CompTime',[],'GpsDay',[],'GpsTime',[]);
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);
    F=fread(fId,inf,'*char');fclose(fId);clear fId;
    L=find(F==LDelim);L=[L [L(2:end)-1;size(F,1)]]; %L=[first_symbol_for_line last_symbol_for_line]
    L1=find(F(L(:,1)+9)~=F(L(1,1)+9));if ~isempty(L1), error(['RightDelimiter not true, Lines ' num2str(L1)]);end;
    %========find $GPZDA===============
    Mask=(F(L(:,1)+10)==keyS(1))&(F(L(:,1)+11)==keyS(2))&(F(L(:,1)+12)==keyS(3))&(F(L(:,1)+13)==keyS(4))&(F(L(:,1)+14)==keyS(5))&(F(L(:,1)+15)==keyS(6))&(F(L(:,2)-4)=='*'); %if line is $GPZDA...*
    if any(Mask),
        %delete all ~GPZDA lines
        L_Mask=find(~Mask);F1=F;
        for n=length(L_Mask):-1:1, F1(L(L_Mask(n),1):L(L_Mask(n),2))=char(0);end;
        LL=F1==char(0);F1(LL)=[];
        %processed $GPZDA: 1LeftDelim 2CompTime 3'$GPZDA' 4UtcTime 5UtcDay 6UtcMonth 7UtcYear 8LocHour 9LocMin 10Cheksum
        C=textscan(F1,'%c %f %6c %f %f %f %f %f %f %2c','Delimiter',',*','MultipleDelimsAsOne',0,'EndOfLine','\r\n');
        if any(C{8}~=C{8}(1)), error('Local hour is changed');end;
        if any(C{9}~=C{9}(1)), error('Local minutes is changed');end;
        %Calc fields: CompTime,GpsDay,GpsTime,GpsDay.
        CompTime=C{2}'./1000;
        tmp=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));CompDay=repmat(tmp,size(CompTime));
        GpsTime=(fix(C{4}./10000).*3600+fix(mod(C{4},10000)./100).*60+mod(C{4},100))';
        GpsDay=datenum(C{7},C{6},C{5})';
        %add structs
        GPZDA1=struct('CompDay',CompDay,'CompTime',CompTime,'GpsDay',GpsDay,'GpsTime',GpsTime);
        GPZDA=gZRowAppend(GPZDA,GPZDA1,size(GPZDA.CompDay,2));
    end;
end;
GPZDA.CompTimeLocShift=C{8}(1).*3600+C{9}(1).*60;
[GPZDA.CompTimeDelta,GPZDA.CompTimeShift]=gLogGpsCompTimeDelta(GPZDA.CompDay,GPZDA.CompTime,GPZDA.GpsDay,GPZDA.GpsTime);

%remove empty
names=fieldnames(GPZDA);
for n=1:size(names,1),
    a=GPZDA.(names{n});
    if isempty(a)||all(isnan(a)), GPZDA=rmfield(GPZDA,names{n});end;
end;

%mail@ge0mlib.com 15/09/2017