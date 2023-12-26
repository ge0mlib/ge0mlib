function [Head,Data]=gJsf0000Read(JsfHead,MessageType,ChN,SubSys)
%Read Head and Data from JsfHead.fName (*.jsf) file for Private Messages Types.
%function [Head,Data]=gJsf0000Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%The bytes vector will be read to Data.
%Example: [Head,Data]=gJsf0000Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead2040: ' mes]);end;
LHead=(JsfHead.HMessageType==MessageType)&(JsfHead.HChannelMulti==ChN)&(JsfHead.HSubsystem==SubSys);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type XXXX
Head=struct('HMessageType',MessageType,'HChannelMulti',ChN,'HSubsystem',SubSys,'HMessageNum',zeros(1,LenHead));
%===End Head Allocate for Message Type XXXX
Data=nan(max(JsfHead.HSizeFollowingMessage(nHead)),LenHead);
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type XXXX
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Data(1:JsfHead.HSizeFollowingMessage(nHead(m)),m)=fread(fId,JsfHead.HSizeFollowingMessage(nHead(m)),'uint8');
    %===End Head Read for Message Type XXXX
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 18/04/2018