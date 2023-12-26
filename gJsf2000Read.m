function Head=gJsf2000Read(JsfHead,ChN)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 2000 (Sonar Virtual Ports Data; not annotated)
%function Head=gJsf2000Read(JsfHead,ChN), where
%JsfHead - Jsf Header structure;
%ChN - channel number;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HChannelMulti, HMessageNum.
%Each message contains the data flow piece from one virtual serial port.
%Example: Head=gJsf2000Read(JsfHead,0);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead2000: ' mes]);end;
LHead=(JsfHead.HMessageType==2000)&(JsfHead.HChannelMulti==ChN);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 2000
Head=struct('HMessageType',2000,'HChannelMulti',ChN,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'MillisecondsCurrentSecond',zeros(1,LenHead),'Source',zeros(1,LenHead),'Reserved1',zeros(3,LenHead),...
    'String',nan(max(JsfHead.HSizeFollowingMessage(nHead))-12,LenHead));
%===End Head Allocate for Message Type 2000
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 2000
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.MillisecondsCurrentSecond(m)=fread(fId,1,'int32'); %4-7// Milliseconds in the current second
    Head.Source(m)=fread(fId,1,'uint8'); %8// Source, 1 = Sonar, 2 = Discover, 3 = ETSI
    Head.Reserved1(:,m)=fread(fId,3,'uint8'); %9-11// Reserved – Do not use
    Head.String(1:JsfHead.HSizeFollowingMessage(nHead(m))-12,m)=fread(fId,JsfHead.HSizeFollowingMessage(nHead(m))-12,'uint8'); %12-end// Virtual Ports Data
    %===End Head Read for Message Type 2000
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 01/08/2016