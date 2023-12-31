function gJsf0182Write(JsfHead,Head,fNameNew,flTraceLenChanged)
%Write [JsfHead,Head] to *.jsf file for Message Type 0182 (System Information Message; 0004824_REV_1.20 used).
%All another messages (not 0182) are copied to new file from �parent�s� file without any changes, in accordance with JsfHead.ROnFlag�s value.
%function gJsf0182Write(JsfHead,Head,fNameNew), where
%JsfHead - structure with parent jsf-file description;
%Head - Message Header structure.
%fNameNew - string, the target file for writing;
%flTraceLenChanged - set to one, if Reserved3 field length was changed and JsfHead.HSizeFollowingMessage field need to correct.
%If you change Reserved3 field length, the JsfHead.HSizeFollowingMessage field must be correct. Use flTraceLenChanged==1 for auto-correction.
%Example: gJsf0182Write(JsfHead,Head,'c:\temp\1new.jsf',0);

[fId, mes]=fopen(JsfHead.fName,'r+');if ~isempty(mes), error(['gJsfWrite0182: ' mes]);end;
if strcmp(fNameNew,JsfHead.fName), error('gJsfWrite0182: XtfHead.fName and fNameNew must be different.');end;
[fId2, mes]=fopen(fNameNew,'w');if ~isempty(mes), error(['gJsfWrite0182: ' mes]);end;
df=0;mm=0;nHead=find(JsfHead.HMessageType==0182);
for m=1:size(JsfHead.HMessageType,2),
    if ~(JsfHead.HMessageType(m)==0182),
        %===Begin JsfHeader Record Write;
        fwrite(fId2,JsfHead.HMarkerForStart(m),'uint16'); %0-1// Marker for the Start of Header = 0x1601
        fwrite(fId2,JsfHead.HVersionOfProtocol(m),'uint8'); %2// Version of Protocol used
        fwrite(fId2,JsfHead.HSessionIdentifier(m),'uint8'); %3// Session Identifier
        fwrite(fId2,JsfHead.HMessageType(m),'uint16'); %4-5// Message Type
        fwrite(fId2,JsfHead.HCommandType(m),'uint8'); %6// Command Type
        fwrite(fId2,JsfHead.HSubsystem(m),'uint8'); %7// Subsystem for a Multi-System Device. Common  subsystem assignments are as follows: Sub-bottom data - 0; Single frequency side scan data - 20; Lower frequency data of a dual frequency side scan - 20; Higher frequency data of a dual frequency side scan - 21; Higher frequency data of a tri-frequency side scan - 22; Raw serial/UDP/TCP data - 100 (v.1.20); Parsed serial/UDP/TCP data - 101 (v1.20); Raw UDP data - 103 (v.1.18);Parsed UPD data  - 104 (v1.18).
        fwrite(fId2,JsfHead.HChannelMulti(m),'uint8'); %8// Channel for a Multi-Channel Subsystem For Side Scan Subsystems; 0 = Port; 1 = Starboard; For Serial Ports: Port #
        fwrite(fId2,JsfHead.HSequenceNumber(m),'uint8'); %9// Sequence Number
        fwrite(fId2,JsfHead.HReserved(m),'uint16'); %10-11// Reserved
        fwrite(fId2,JsfHead.HSizeFollowingMessage(m),'uint32'); %12-15// Size of following Message in Bytes
        %===End JsfHeader Record Write
        %===Begin DataBlock Write (DataBlock length from JsfHead.HSizeFollowingMessage, DataBlock begin from JsfHead.RSeek)
        fseek(fId,JsfHead.RSeek(m)-df,'cof');zz=fread(fId,JsfHead.HSizeFollowingMessage(m),'uint8')';df=ftell(fId);
        fwrite(fId2,zz,'uint8'); %Byte field
        %===End DataBlock Write
    elseif (JsfHead.HMessageType(m)==0182),
        %===Begin JsfHeader Record Write
        fwrite(fId2,JsfHead.HMarkerForStart(m),'uint16'); %0-1// Marker for the Start of Header = 0x1601
        fwrite(fId2,JsfHead.HVersionOfProtocol(m),'uint8'); %2// Version of Protocol used
        fwrite(fId2,JsfHead.HSessionIdentifier(m),'uint8'); %3// Session Identifier
        fwrite(fId2,JsfHead.HMessageType(m),'uint16'); %4-5// Message Type (e.g. 128 = System Information Message)
        fwrite(fId2,JsfHead.HCommandType(m),'uint8'); %6// Command Type
        fwrite(fId2,JsfHead.HSubsystem(m),'uint8'); %7// Subsystem for a Multi-System Device. Common  subsystem assignments are as follows: Sub-bottom data - 0; Single frequency side scan data - 20; Lower frequency data of a dual frequency side scan - 20; Higher frequency data of a dual frequency side scan - 21; Higher frequency data of a tri-frequency side scan - 22; Raw serial/UDP/TCP data - 100 (v.1.20); Parsed serial/UDP/TCP data - 101 (v1.20); Raw UDP data - 103 (v.1.18);Parsed UPD data  - 104 (v1.18).
        fwrite(fId2,JsfHead.HChannelMulti(m),'uint8'); %8// Channel for a Multi-Channel Subsystem For Side Scan Subsystems; 0 = Port; 1 = Starboard; For Serial Ports: Port #
        fwrite(fId2,JsfHead.HSequenceNumber(m),'uint8'); %9// Sequence Number
        fwrite(fId2,JsfHead.HReserved(m),'uint16'); %10-11// Reserved
        fwrite(fId2,JsfHead.HSizeFollowingMessage(m),'uint32'); %12-15// Size of following Message in Bytes
        %===End JsfHeader Record Write
        mm=mm+1;
        if nHead(mm)~=Head.HMessageNum(mm), error(['Error: gFJsfWrite0182, not correct Messages order for message num=' num2str(mm)]);end;        
        %===Begin Head Write for Message Type 182 (Header length from JsfHead.HSizeFollowingMessage; Header data from Head)
        fwrite(fId2,Head.SystemType(mm),'int32'); %0-3// System Type
        fwrite(fId2,Head.LowRateIO(mm),'int32'); %4-7// Low rate IO enabled option (0 =  disabled)
        fwrite(fId2,Head.VersionNumberSonarSoftware(mm),'int32'); %8-11// Version Number of Sonar Software used to generate data
        fwrite(fId2,Head.NumberSubsystems(mm),'int32'); %12-15// Number of Subsystems present in this message
        fwrite(fId2,Head.NumberSerialPortDevices(mm),'int32'); %16-19// Number of Serial port devices present in this message
        fwrite(fId2,Head.SerialNumberTowVehicle(mm),'int32'); %20-23// Serial Number of Tow Vehicle used to collect data
        fwrite(fId2,Head.Reserved3(1:JsfHead.HSizeFollowingMessage(m)-24,mm),'uint8'); %24-end// Reserved3 data
        %===End Head Write for Message Type 182
        %===Begin checking for Number Bytes This Record
        HSizeFollowingMessageNew=ftell(fId2)-JsfHead.RSeek(m); %estimate
        if (HSizeFollowingMessageNew~=JsfHead.HSizeFollowingMessage(m))&&(~flTraceLenChanged),error(['Error: gFJsfWrite0182, not correct JsfHead.HSizeFollowingMessage for message num=' num2str(m)]);end;
        if (HSizeFollowingMessageNew~=JsfHead.HSizeFollowingMessage(m))&&(flTraceLenChanged),
            fseek(fId2,-HSizeFollowingMessageNew-4,'cof');fwrite(fId2,HSizeFollowingMessageNew,'uint32');fseek(fId2,HSizeFollowingMessageNew,'cof');
        end;
        %===End checking for Number Bytes This Record
    end;
end;
fclose(fId2);
fclose(fId);

%mail@ge0mlib.com 19/03/2018