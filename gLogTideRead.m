function Out=gLogTideRead(fName,LDelim)
%
%<33602048,%06:16:57,05-24-2022,+00.46,13.03V,00017&

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
Out=struct('CompDay',[],'CompTime',[],'GpsDay',[],'GpsTime',[],'Tide',[],'Volt',[],'ID',[]);
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);
    F=fread(fId,inf,'*char');fclose(fId);clear fId;
    L=find(F==LDelim);L=[L [L(2:end)-1;size(F,1)]]; %L=[first_symbol_for_line last_symbol_for_line]
    L1=find(F(L(:,1)+9)~=F(L(1,1)+9));if ~isempty(L1), error(['RightDelimiter not true, Lines ' num2str(L1)]);end;
    %========find %===============
    Mask=(F(L(:,1)+10)=='%'); %if line is Good
    if any(Mask),
        %delete all ~Good lines
        L_Mask=find(~Mask);F1=F; for n=length(L_Mask):-1:1, F1(L(L_Mask(n),1):L(L_Mask(n),2))=char(0);end; LL=F1==char(0);F1(LL)=[];
        %processed string: 1LeftDelim 2CompTime 3'%' 4HH 5MM 6SS 7MMonth 8DD 9YYYY 10Tide 11Voltage 12ZZZ
        [C,pos]=textscan(F1,'%c%f,%c%f:%f:%f,%f-%f-%f,%f,%fV,%f&','Delimiter',' ','MultipleDelimsAsOne',0,'EndOfLine','\r\n');
        if pos~=numel(F1),error(['Not all file data read, chars ' num2str(numel(F1)) ' from ' num2str(pos)]);end;
        %Calc fields: CompTime,GpsDay,GpsTime,GpsDay.
        CompTime=C{2}'./1000;
        CompDay1=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));CompDay=repmat(CompDay1,size(CompTime));
        GpsTime=(C{4}.*3600+C{5}.*60+C{6})';GpsDay=gNavTime2Time('YMD32Dx',C{9},C{7},C{8})';
        %add structs
        Out1=struct('CompDay',CompDay,'CompTime',CompTime,'GpsDay',GpsDay,'GpsTime',GpsTime,'Tide',C{10}','Volt',C{11}','ID',C{12}');
        Out=gFieldsRowAppend(Out,Out1,size(Out.CompDay,2));
    end;
end;

[YYYY,MM,DD]=gNavTime2Time('Dx2YMD3',Out.GpsDay);[H,M,S]=gNavTime2Time('Sd2HMS3',Out.GpsTime);dlmwrite('d:\text.txt',[YYYY;MM;DD;H;M;S;Out.Tide]');