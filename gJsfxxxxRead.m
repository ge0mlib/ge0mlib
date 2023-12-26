function Head=gJsfxxxxRead(JsfHead,Type,ChN,SubS)
%Read Head from JsfHead.fName (*.jsf) file for Message Type xxxx (Unknown Data)
%function Head=gJsfxxxxRead(JsfHead,Type,ChN), where
%JsfHead - Jsf Header structure;
%Type - Type of message will read;
%ChN - channel number if presented or NaN;
%SubS - subsystem number;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HChannelMulti, HSubsystem, HMessageNum.
%Each message contains unknown uint8 data
%Example: Head=gJsfxxxxRead(JsfHead,0040,0,0);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfxxxxRead: ' mes]);end;
if isnan(ChN),LHead=(JsfHead.HMessageType==Type);else,LHead=(JsfHead.HMessageType==Type)&(JsfHead.HChannelMulti==ChN)&(JsfHead.HSubsystem==SubS);end;LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type xxxx
Head=struct('HMessageType',Type,'HChannelMulti',ChN,'HSubsystem',SubS,'HMessageNum',zeros(1,LenHead),'String',nan(max(JsfHead.HSizeFollowingMessage(nHead)),LenHead));
%===End Head Allocate for Message Type xxxx
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type xxxx
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.String(1:JsfHead.HSizeFollowingMessage(nHead(m)),m)=fread(fId,JsfHead.HSizeFollowingMessage(nHead(m)),'uint8'); %1-end// Uint8 Data
    %===End Head Read for Message Type xxxx
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 01/08/2023