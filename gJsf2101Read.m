function Head=gJsf2101Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 2101 (Kilometer of Pipe Data; 0004824_REV_1.20 used). Warning: NOT TESTED.
%function Head=gJsf2101Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%Example: Head=gJsf2101Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead2101: ' mes]);end;
LHead=(JsfHead.HMessageType==2101);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 2101
Head=struct('HMessageType',2101,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'MillisecondsCurrentSecond',zeros(1,LenHead),'Source',zeros(1,LenHead),'Reserved1',zeros(3,LenHead),...
    'KP',zeros(1,LenHead),'FlagValidKpValue',zeros(1,LenHead),'FlagKpReportError',zeros(1,LenHead));
%===End Head Allocate for Message Type 2101
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 2101
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.MillisecondsCurrentSecond(m)=fread(fId,1,'int32'); %4-7// Milliseconds in the current second
    Head.Source(m)=fread(fId,1,'uint8'); %8// Source, 1 = Sonar, 2 = DISCOVER, 3 = ETSI
    Head.Reserved1(:,m)=fread(fId,3,'uint8'); %9-11// Reserved – Do not use
    Head.KP(m)=fread(fId,1,'float32'); %12-15// Kilometer of Pipe (KP)
    Head.FlagValidKpValue(m)=fread(fId,1,'int16'); %16-17// Flag (valid KP value)
    Head.FlagKpReportError(m)=fread(fId,1,'int16'); %18-19// Flag (KP report error)
    %===End Head Read for Message Type 2101
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018