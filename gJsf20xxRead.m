function Head=gJsf20xxRead(JsfHead,MType,ChN,SubS)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 20xx (Unknown Data with the first fields 'TimeInSeconds','MillisecondsCurrentSecond')
%function Head=gJsf20xxRead(JsfHead,Type,ChN), where
%JsfHead - Jsf Header structure;
%MType - Type of message will read;
%ChN - channel number;
%SubS - subsystem number;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HChannelMulti, HSubsystem, HMessageNum.
%Each message contains the uint8 data, first bytes are 'TimeInSeconds','MillisecondsCurrentSecond' as probably usuall for messages with type 2000 to 2099
%Example: Head=gJsf20xxRead(JsfHead,2043,0,102);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead20xx: ' mes]);end;
LHead=(JsfHead.HMessageType==MType)&(JsfHead.HChannelMulti==ChN)&(JsfHead.HSubsystem==SubS);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 20xx
Head=struct('HMessageType',MType,'HChannelMulti',ChN,'HSubsystem',SubS,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'MillisecondsCurrentSecond',zeros(1,LenHead),'String',nan(max(JsfHead.HSizeFollowingMessage(nHead))-8,LenHead));
%===End Head Allocate for Message Type 20xx
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 20xx
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.MillisecondsCurrentSecond(m)=fread(fId,1,'int32'); %4-7// Milliseconds in the current second
    Head.String(1:JsfHead.HSizeFollowingMessage(nHead(m))-8,m)=fread(fId,JsfHead.HSizeFollowingMessage(nHead(m))-8,'uint8'); %8-end// Uint8 Data
    %===End Head Read for Message Type 20xx
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 01/08/2023