function GPVTG=gLogGpVtgRead(fName,keyS,LDelim)
%Read $GPVTG data from files created by gComLog program.
%function GPVTG=gLogGpVtgRead(fName,keyS,LDelim), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%keyS - key string ('$GPVTG' or same);
%LDelim - left delimiter for log-file;
%GPVTG - reading data structure with fields: CompDay,CompTime,GpsCourseT,GpsCourseM,GpsSpeed,VtgPosInd.
%Log-file (created by gComLog program) example:
%~00007880,$GPVTG,167.5,T,,M,6.16,N,11.40,K,A*23
%~00008879,$GPVTG,167.3,T,,M,6.24,N,11.55,K,A*20
%~ - left delimiter (symbol 1);
%00007880 - second per day./1000 (symbols 2-9);
%, - right delimiter (symbol 10);
%$GPVTG... - $GPVTG data.
%Example: GPVTG=gLogGpVtgRead('c:\temp\','$GPVTG','~');
%--------------------------------------------------------------------------------------
%$GPVTG,167.5,T,160,M,6.16,N,11.40,K,A*23<CR><LF>
%167.5 – Course over ground.
%T - Degrees, True.
%160 - Course over ground.
%M - Degrees, Magnetic.
%6.16 - Speed over ground.
%N - knots.
%11.40 - Speed over ground.
%K - Km/hr .
%A - Positioning system Mode Indicator: A=Autonomous mode; D=Differential mode; E=Estimated (dead reckoning) mode; M=Manual input mode; S=Simulator mode; N=Data not valid.
%*63 – Checksum data, always begins with *.
%--------------------------------------------------------------------------------------

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
GPVTG=struct('CompDay',[],'CompTime',[],'GpsCourseT',[],'GpsCourseM',[],'GpsSpeed',[],'VtgPosInd',[]);
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);
    F=fread(fId,inf,'*char');fclose(fId);clear fId;
    L=find(F==LDelim);L=[L [L(2:end)-1;size(F,1)]]; %L=[first_symbol_for_line last_symbol_for_line]
    L1=find(F(L(:,1)+9)~=F(L(1,1)+9));if ~isempty(L1), error(['RightDelimiter not true, Lines ' num2str(L1)]);end;
    %========find $GPVTG===============
    Mask=(F(L(:,1)+10)==keyS(1))&(F(L(:,1)+11)==keyS(2))&(F(L(:,1)+12)==keyS(3))&(F(L(:,1)+13)==keyS(4))&(F(L(:,1)+14)==keyS(5))&(F(L(:,1)+15)==keyS(6))&(F(L(:,2)-4)=='*'); %if line is $GPVTG...*
    if any(Mask),
        %delete all ~GPVTG lines
        L_Mask=find(~Mask);F1=F;
        for n=length(L_Mask):-1:1, F1(L(L_Mask(n),1):L(L_Mask(n),2))=char(0);end;
        LL=F1==char(0);F1(LL)=[];
        %processed $GPVTG: 1LeftDelim 2CompTime 3'$GPVTG' 4CourseT 5'T' 6CourseM 7'M' 8SpeedN 9'N' 10SpeedK 11'K' 12VtgPosInd 13Cheksum
        C=textscan(F1,'%c %f %6c %f %c %f %c %f %c %f %c %c %2c','Delimiter',',*','MultipleDelimsAsOne',0,'EndOfLine','\r\n');
        if any(C{5}~='T'), error('Course ID is not T');end;
        if any(C{7}~='M'), error('Course ID is not M');end;
        if any(C{9}~='N'), error('Speed ID is not N');end;
        if any(C{11}~='K'), error('Speed ID is not K');end;
        %Calc fields: CompTime,CompDay
        CompTime=C{2}'./1000;
        tmp=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));CompDay=repmat(tmp,size(CompTime));
        %add structs
        GPVTG1=struct('CompDay',CompDay,'CompTime',CompTime,'GpsCourseT',C{4}','GpsCourseM',C{6}','GpsSpeed',C{10}','VtgPosInd',C{12}');
        GPVTG=gZRowAppend(GPVTG,GPVTG1,size(GPVTG.CompDay,2));
    end;
end;
GPVTG.GpsCourseT=unwrap(GPVTG.GpsCourseT./180.*pi)./pi.*180; GPVTG.GpsCourseM=unwrap(GPVTG.GpsCourseM./180.*pi)./pi.*180;

%remove empty
names=fieldnames(GPVTG);
for n=1:size(names,1),
    a=GPVTG.(names{n});
    if isempty(a)||all(isnan(a)), GPVTG=rmfield(GPVTG,names{n});end;
end;

%mail@ge0mlib.com 15/09/2017