function CSTM=gLogGeoSenseNavFixRead(fName,keyS,LDelim,CompTimeLocShift)
%Read $CUSTOM data from files created by gComLog program (for Geo-Resourse48).
%function CSTM=gLogGeoSenseNavFixRead(fName,keyS,LDelim,CompTimeLocShift), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%keyS - key string ('$CUSTOM' or same);
%LDelim - left delimiter for log-file;
%CompTimeLocShift - Computer time minus Utc_Gps time (in seconds);
%CSTM - reading data structure with fields: CompTime,CompDay,GpsDay,GpsTime,GpsE,GpsN,Fix,Heading,DepthSea
%Log-file (created by gComLog program) example:
%<07093294,$CUSTOM,20170825,155821.15,7102,661756.05,8147722.95,133.52,123.2
%where
%< - left delimiter (symbol 1);
%07093294 - second per day./1000 (symbols 2-9);
%, - right delimiter (symbol 10);
%$CUSTOM - data.
%$CUSTOM,YYYYMMDD,HHMMSS.SS,Fix,EEEEEE.EE,NNNNNNN.NN,Heading,Depth<CR><LF>
%Example: CSTM=gLogGeoSenseNavFixRead('c:\temp\','$CUSTOM','<',10*3600);

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
CSTM=struct('CompDay',[],'CompTime',[],'GpsDay',[],'GpsTime',[],'GpsE',[],'GpsN',[],'Fix',[],'Heading',[],'DepthSea',[]);
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);
    F=fread(fId,inf,'*char');fclose(fId);clear fId;
    L=find(F==LDelim);L=[L [L(2:end)-1;size(F,1)]]; %L=[first_symbol_for_line last_symbol_for_line]
    L1=find(F(L(:,1)+9)~=F(L(1,1)+9));if ~isempty(L1), error(['RightDelimiter not true, Lines ' num2str(L1)]);end;
    %========find $CUSTOM===============
    Mask=(F(L(:,1)+10)==keyS(1))&(F(L(:,1)+11)==keyS(2))&(F(L(:,1)+12)==keyS(3))&(F(L(:,1)+13)==keyS(4))&(F(L(:,1)+14)==keyS(5))&(F(L(:,1)+15)==keyS(6))&(F(L(:,1)+16)==keyS(7)); %if line is $CUSTOM...*
    if any(Mask),
        %delete all ~CUSTOM lines
        L_Mask=find(~Mask);F1=F;
        for n=length(L_Mask):-1:1, F1(L(L_Mask(n),1):L(L_Mask(n),2))=char(0);end;
        LL=F1==char(0);F1(LL)=[];
        %processed $CUSTOM: 1LeftDelim 2CompTime 3'$CUSTOM' 4GpsYYMMDD 5GpsHHMMSS.SS 6Fix 7East 8North 9Heading 10DepthSea
        C=textscan(F1,'%c %f %7c %f %f %f %f %f %f %f','Delimiter',',','MultipleDelimsAsOne',0,'EndOfLine','\r\n');
        %Calc fields: CompTime,GpsDay,GpsTime,GpsDay.
        CompTime=C{2}'./1000;
        tmp=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));CompDay=repmat(tmp,size(CompTime));
        GpsTime=gNavTime2Time('HMS2Sd',C{5}');GpsDay=gNavTime2Time('YMD2Dx',C{4}');
        %add structs
        CSTM1=struct('CompDay',CompDay,'CompTime',CompTime,'GpsDay',GpsDay,'GpsTime',GpsTime,'GpsE',C{7}','GpsN',C{8}','Fix',C{6}','Heading',C{9}','DepthSea',C{10}');
        CSTM=gZRowAppend(CSTM,CSTM1,size(CSTM.CompDay,2));
    end;
end;
CSTM.CompTimeLocShift=CompTimeLocShift;
[CSTM.CompTimeDelta,CSTM.CompTimeShift]=gLogGpsCompTimeDelta(CSTM.CompDay,CSTM.CompTime,CSTM.GpsDay,CSTM.GpsTime);

%remove empty
names=fieldnames(CSTM);
for n=1:size(names,1),
    a=CSTM.(names{n});
    if isempty(a)||all(isnan(a)), CSTM=rmfield(CSTM,names{n});end;
end;

%mail@ge0mlib.com 22/09/2017