function Head=gJsf0428Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 0428 (File Padding Message; 000482_REV_1.20 used). Warning: NOT TESTED.
%function Head=gJsf0428Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%A file padding message is sometimes found at the end of the file. In some implementations files are padded to optimize the write process. These messages should be ignored.
%Example: Head=gJsf0428Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead0428: ' mes]);end;
LHead=(JsfHead.HMessageType==0428);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 0428
Head=struct('HMessageType',0428,'HMessageNum',zeros(1,LenHead),'Bytes',zeros(max(JsfHead.HSizeFollowingMessage(nHead)),LenHead));
%===End Head Allocate for Message Type 0428
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 0428
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.Bytes(1:JsfHead.HSizeFollowingMessage(nHead(m)),m)=fread(fId,JsfHead.HSizeFollowingMessage(nHead(m)),'uint8'); %0-end// Padding Message Data
    %===End Head Read for Message Type 0428
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018