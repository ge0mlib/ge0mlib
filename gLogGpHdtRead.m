function GPHDT=gLogGpHdtRead(fName,keyS,LDelim)
%Read $GPHDT data from files created by gComLog program.
%function GPHDT=gLogGpHdtRead(fName,keyS,LDelim), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%keyS - key string ('$GPHDT' or same);
%LDelim - left delimiter for log-file;
%GPHDT - reading data structure with fields: CompDay,CompTime,GpsHeading.
%Log-file (created by gComLog program) example:
%~39600366,$GPHDT,154.0,T*25
%~39601360,$GPHDT,153.9,T*2B
%~ - left delimiter (symbol 1);
%39600366 - second per day./1000 (symbols 2-9);
%, - right delimiter (symbol 10);
%$GPHDT... - $GPHDT data.
%Example: GPHDT=gLogGpHdtRead('c:\temp\','$GPHDT','~');
%--------------------------------------------------------------------------------------
%$GPHDT,154.0,T*25
%154.0 - Heading degree.
%T -  True.
%*25 – Checksum data, always begins with *.
%--------------------------------------------------------------------------------------

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
GPHDT=struct('CompDay',[],'CompTime',[],'GpsHeading',[]);
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);
    F=fread(fId,inf,'*char');fclose(fId);clear fId;
    L=find(F==LDelim);L=[L [L(2:end)-1;size(F,1)]]; %L=[first_symbol_for_line last_symbol_for_line]
    L1=find(F(L(:,1)+9)~=F(L(1,1)+9));if ~isempty(L1), error(['RightDelimiter not true, Lines ' num2str(L1)]);end;
    %========find $GPHDT===============
    Mask=(F(L(:,1)+10)==keyS(1))&(F(L(:,1)+11)==keyS(2))&(F(L(:,1)+12)==keyS(3))&(F(L(:,1)+13)==keyS(4))&(F(L(:,1)+14)==keyS(5))&(F(L(:,1)+15)==keyS(6)); %if line is $GPHDT...*  &(F(L(:,2)-4)=='*')
    if any(Mask),
        %delete all ~GPHDT lines
        L_Mask=find(~Mask);F1=F;
        for n=length(L_Mask):-1:1, F1(L(L_Mask(n),1):L(L_Mask(n),2))=char(0);end;
        LL=F1==char(0);F1(LL)=[];
        %processed $GPHDT: 1LeftDelim 2CompTime 3'$GPHDT' 4HDT 5T 6Cheksum
        C=textscan(F1,'%c %f %6c %f %c %2c','Delimiter',',*','MultipleDelimsAsOne',0,'EndOfLine','\r\n');
        if any(C{5}~='T'), error('symbol is not T.');end;
        %Calc fields: CompTime,GpsDay,GpsTime,GpsDay.
        CompTime=C{2}'./1000;
        tmp=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));CompDay=repmat(tmp,size(CompTime));
        GpsHeading=C{4}';
        %add structs
        GPHDT1=struct('CompDay',CompDay,'CompTime',CompTime,'GpsHeading',GpsHeading);
        GPHDT=gZRowAppend(GPHDT,GPHDT1,size(GPHDT.CompDay,2));
    end;
end;
GPHDT.GpsHeading=unwrap(GPHDT.GpsHeading./180.*pi)./pi.*180;

%remove empty
names=fieldnames(GPHDT);
for n=1:size(names,1),
    a=GPHDT.(names{n});
    if isempty(a)||all(isnan(a)), GPHDT=rmfield(GPHDT,names{n});end;
end;

%mail@ge0mlib.com 15/09/2017