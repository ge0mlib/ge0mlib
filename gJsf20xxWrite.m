function gJsf20xxWrite(JsfHead,Head,fNameNew,flTraceLenChanged)
%Write [JsfHead,Head] to *.jsf file for Message Type 20xx (Unknown Data with the first fields 'TimeInSeconds','MillisecondsCurrentSecond').
%All another messages (not 20xx) are copied to new file from “parent’s” file without any changes, in accordance with JsfHead.ROnFlag’s value.
%function gJsf20xxWrite(JsfHead,Head,MType,ChN,fNameNew,flTraceLenChanged), where
%JsfHead - structure with parent jsf-file description;
%Head - Message Header structure;
%fNameNew - string, the target file for writing;
%flTraceLenChanged - set to one, if String field length was changed and JsfHead.HSizeFollowingMessage field need to correct.
%If you change String field length, the JsfHead.HSizeFollowingMessage field must be correct. Use flTraceLenChanged==1 for auto-correction.
%Example: gJsf20xxWrite(JsfHead,Head,'c:\temp\1new.jsf',0);

[fId, mes]=fopen(JsfHead.fName,'r+');if ~isempty(mes), error(['gJsf20xxWrite: ' mes]);end;
if strcmp(fNameNew,JsfHead.fName), error('gJsf20xxWrite: JsfHead.fName and fNameNew must be different.');end;
[fId2, mes]=fopen(fNameNew,'w');if ~isempty(mes), error(['gJsf20xxWrite: ' mes]);end;
df=0;mm=0;
nHead=find((JsfHead.HMessageType==Head.HMessageType)&(JsfHead.HChannelMulti==Head.HChannelMulti)&(JsfHead.HSubsystem==Head.HSubsystem));
for m=1:size(JsfHead.HMessageType,2),
    if ~((JsfHead.HMessageType(m)==Head.HMessageType)&&(JsfHead.HChannelMulti(m)==Head.HChannelMulti)&&(JsfHead.HSubsystem(m)==Head.HSubsystem)),
        %===Begin JsfHeader Record Write;
        fwrite(fId2,JsfHead.HMarkerForStart(m),'uint16'); %0-1// Marker for the Start of Header = 0x1601
        fwrite(fId2,JsfHead.HVersionOfProtocol(m),'uint8'); %2// Version of Protocol used
        fwrite(fId2,JsfHead.HSessionIdentifier(m),'uint8'); %3// Session Identifier
        fwrite(fId2,JsfHead.HMessageType(m),'uint16'); %4-5// Message Type
        fwrite(fId2,JsfHead.HCommandType(m),'uint8'); %6// Command Type
        fwrite(fId2,JsfHead.HSubsystem(m),'uint8'); %7// Subsystem for a Multi-System Device. Common  subsystem assignments are as follows: Sub-bottom data - 0; Single frequency side scan data - 20; Lower frequency data of a dual frequency side scan - 20; Higher frequency data of a dual frequency side scan - 21; Higher frequency data of a tri-frequency side scan - 22; Raw serial/UDP/TCP data - 100 (v.1.20); Parsed serial/UDP/TCP data - 101 (v1.20); Raw UDP data - 103 (v.1.18);Parsed UPD data  - 104 (v1.18).
        fwrite(fId2,JsfHead.HChannelMulti(m),'uint8'); %8// Channel for a Multi-Channel Subsystem For Side Scan Subsystems; 0 = Port; 1 = Starboard
        fwrite(fId2,JsfHead.HSequenceNumber(m),'uint8'); %9// Sequence Number
        fwrite(fId2,JsfHead.HReserved(m),'uint16'); %10-11// Reserved
        fwrite(fId2,JsfHead.HSizeFollowingMessage(m),'uint32'); %12-15// Size of following Message in Bytes
        %===End JsfHeader Record Write
        %===Begin DataBlock Write (DataBlock length from JsfHead.HSizeFollowingMessage, DataBlock begin from JsfHead.RSeek)
        fseek(fId,JsfHead.RSeek(m)-df,'cof');zz=fread(fId,JsfHead.HSizeFollowingMessage(m),'uint8')';df=ftell(fId);
        fwrite(fId2,zz,'uint8'); %Byte field
        %===End DataBlock Write
    elseif (JsfHead.HMessageType(m)==Head.HMessageType)&&(JsfHead.HChannelMulti(m)==Head.HChannelMulti)&&(JsfHead.HSubsystem(m)==Head.HSubsystem),
        %===Begin JsfHeader Record Write
        fwrite(fId2,JsfHead.HMarkerForStart(m),'uint16'); %0-1// Marker for the Start of Header = 0x1601
        fwrite(fId2,JsfHead.HVersionOfProtocol(m),'uint8'); %2// Version of Protocol used
        fwrite(fId2,JsfHead.HSessionIdentifier(m),'uint8'); %3// Session Identifier
        fwrite(fId2,JsfHead.HMessageType(m),'uint16'); %4-5// Message Type
        fwrite(fId2,JsfHead.HCommandType(m),'uint8'); %6// Command Type
        fwrite(fId2,JsfHead.HSubsystem(m),'uint8'); %7// Subsystem for a Multi-System Device. Common  subsystem assignments are as follows: Sub-bottom data - 0; Single frequency side scan data - 20; Lower frequency data of a dual frequency side scan - 20; Higher frequency data of a dual frequency side scan - 21; Higher frequency data of a tri-frequency side scan - 22; Raw serial/UDP/TCP data - 100 (v.1.20); Parsed serial/UDP/TCP data - 101 (v1.20); Raw UDP data - 103 (v.1.18);Parsed UPD data  - 104 (v1.18).
        fwrite(fId2,JsfHead.HChannelMulti(m),'uint8'); %8// Channel for a Multi-Channel Subsystem For Side Scan Subsystems; 0 = Port; 1 = Starboard
        fwrite(fId2,JsfHead.HSequenceNumber(m),'uint8'); %9// Sequence Number
        fwrite(fId2,JsfHead.HReserved(m),'uint16'); %10-11// Reserved
        fwrite(fId2,JsfHead.HSizeFollowingMessage(m),'uint32'); %12-15// Size of following Message in Bytes
        %===End JsfHeader Record Write
        mm=mm+1;
        if nHead(mm)~=Head.HMessageNum(mm), error(['Error: gJsf20xxWrite, not correct Messages order for message num=' num2str(mm)]);end;        
        %===Begin Head Write for Message Type 20xx (Header length from JsfHead.HSizeFollowingMessage; Header data from Head)
        fwrite(fId2,Head.TimeInSeconds(mm),'int32'); %%0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
        fwrite(fId2,Head.MillisecondsCurrentSecond(mm),'int32'); %4-7// Milliseconds in the current second
        fwrite(fId2,Head.String(1:JsfHead.HSizeFollowingMessage(m)-8,mm),'uint8'); %8-end// Uint8 Data
        %===End Head Write for Message Type 20xx
        %===Begin checking for Number Bytes This Record
        HSizeFollowingMessageNew=ftell(fId2)-JsfHead.RSeek(m); %estimate
        if (HSizeFollowingMessageNew~=JsfHead.HSizeFollowingMessage(m))&&(~flTraceLenChanged),error(['Error: gJsf20xxWrite, not correct JsfHead.HSizeFollowingMessage for message num=' num2str(m)]);end;
        if (HSizeFollowingMessageNew~=JsfHead.HSizeFollowingMessage(m))&&(flTraceLenChanged),
            fseek(fId2,-HSizeFollowingMessageNew-4,'cof');fwrite(fId2,HSizeFollowingMessageNew,'uint32');fseek(fId2,HSizeFollowingMessageNew,'cof');
        end;
        %===End checking for Number Bytes This Record
    end;
end;
fclose(fId2);
fclose(fId);

%mail@ge0mlib.com 01/08/2023