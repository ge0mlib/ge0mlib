function fixs=gLogFixRead(fName)
%Read fixes structure from files created by gComLog program.
%function fixs=gLogFixRead(fName), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%fixs - fix structure:
%fixs.CompDay - computer day from LOG-file name;
%fixs.CompTime - computer time.
%File Example: ~36019588,.~36023856,.~36028544,.
%Example: Fix=gLogFixRead('d:\zzz\');plot(diff(FIX.CompTime),'.-');

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
fixs=struct('CompDay',[],'CompTime',[]);
for n=1:size(fName,1),
    fNameN=deblank(fName(n,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);
    C=textscan(fId,'%c %8f %c %c','Delimiter','','EndOfLine','\r');
    if ~all(C{1}(:)==C{1}(1)), error('Delemiter 1 (gComLog) is not uniform');end;
    if ~all(C{3}(:)==C{3}(1)), error('Delemiter 2 (gComLog) is not uniform');end;
    if ~all(C{4}==C{4}(1)), error('Fix-litter is not uniform');end;
    %Calc fields: CompTime,GpsDay
    CompTime=C{2}'./1000;
    CompDay1=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));CompDay=repmat(CompDay1,size(CompTime));
    fixs.CompDay=[fixs.CompDay CompDay];fixs.CompTime=[fixs.CompTime CompTime];
    fclose(fId);
end;
%delete time repeat
a=round(mean(fixs.CompDay));TimeZ=(fixs.CompDay-a).*86400+fixs.CompTime;
L=find(diff(TimeZ)==0);fixs.CompDay(L)=[];fixs.CompTime(L)=[];

%mail@ge0mlib.com 15/09/2017