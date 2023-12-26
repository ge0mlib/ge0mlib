function out=gLogTP2cRead(fName,LDelim)
%Read TP2 compatible output data (USBL) from gLog
%function out=gLogTP2cRead(fName,LDelim), where
%fName- name of file with USBL data;
%LDelim - left delimiter for log-file;
%out- output structure, which includes fields: CompDay, CompTime, UsblTime, TargNum, SHead, TBearing, TDist, XOffset, YOffset, ZOffset, Reserv1, Reserv2.
%Example: out=gLogTP2c('c:\temp\whghghhe\20190901_140000.mur','~');
%--------------------------------------------------------------------------------------
%Log-file (created by gComLog program) example:
%~50400477,12 13:59:55   0 201.1   184.0    -65.3   -169.4    30.2      0.0  
%~50401997,12 13:59:57   0 201.4   187.1    -66.5   -169.4    43.1      0.0  
%~50405030,12 14:00:00   0 200.2   187.0    -63.1   -171.2    41.0      0.0  
%where
%~ - left delimiter (symbol 1);
%50400477 - second per day./1000 (symbols 2-9);
%, - right delimiter (symbol 10);
%12 13:59:... - USBL data.
%--------------------------------------------------------------------------------------
%TP2 compatible output format:
%12 13:59:55   0 201.1   184.0    -65.3   -169.4    30.2      0.0  
%12 13:59:57   0 201.4   187.1    -66.5   -169.4    43.1      0.0  
%12 14:00:00   0 200.2   187.0    -63.1   -171.2    41.0      0.0  
%1    2   3 4  5  6  7   8     9      10       11       12      13       14
%Target number- Character 1
%Time- Character 3-10;
%Ship heading- Character 12-14;
%Target Bearing- Character 16-20;
%Slant Range- Character 22-28;
%X Offset- Character 30-37;
%Y Offset- Character 39-46;
%Z Offset- Character 48-54;
%Reserved- 56-63;
%Reserved- Character 65-66 (blank);
%CR- 67;
%LF– 68;
%--------------------------------------------------------------------------------------

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
out=struct('CompDay',[],'CompTime',[],'UsblTime',[],'TargNum',[],'SHead',[],'TBearing',[],'TDist',[],'XOffset',[],'YOffset',[],'ZOffset',[],'Reserv1',[]);
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;
    F=fread(fId,inf,'*char');fclose(fId);clear fId;
    L=find(F==LDelim);L=[L [L(2:end)-1;size(F,1)]]; %L=[first_symbol_for_line last_symbol_for_line]
    L1=find(F(L(:,1)+9)~=F(L(1,1)+9));if ~isempty(L1), error(['RightDelimiter not true, Lines: ' num2str(L1) ', ' fNameN]);end; %check right delimiter
    L1=find((L(:,2)-L(:,1))~=77);if ~isempty(L1), error(['Error for message length, Lines: ' num2str(L1) ', ' fNameN]);end; %check message length
    L1=find(F(L(:,2)-1)~=char(13));if ~isempty(L1), error(['Error for message end CR, Lines: ' num2str(L1) ', ' fNameN]);end; %check CR
    L1=find(F(L(:,2))~=char(10));if ~isempty(L1), error(['Error for message end LF, Lines: ' num2str(L1) ', ' fNameN]);end; %check LF
    %create and add struct
    C=textscan(F,'%c%f%c%d %f:%f:%f %f %f %f %f %f %f %f','Delimiter',' ','MultipleDelimsAsOne',1,'EndOfLine','\r\n');
    CompTime=C{2}'./1000;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);tmp=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));CompDay=repmat(tmp,size(CompTime));
    UsblTime=(C{5}*3600+C{6}*60+C{7})';
    out1=struct('CompDay',CompDay,'CompTime',CompTime,'UsblTime',UsblTime,'TargNum',C{4}','SHead',C{8}','TBearing',C{9}','TDist',C{10}',...
        'XOffset',C{11}','YOffset',C{12}','ZOffset',C{13}','Reserv1',C{14}');
    out=gFieldsRowAppend(out,out1,size(out.CompDay,2));
end;

%mail@ge0mlib.com 06/09/2019