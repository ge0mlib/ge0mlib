function gJsf2060Write(JsfHead,Head,fNameNew)
%Write [JsfHead,Head] to *.jsf file for Message Type 2060 (Pressure Sensor; 0004824_REV_1.20 used).
%All another messages (not 2060) are copied to new file from “parent’s” file without any changes, in accordance with JsfHead.ROnFlag’s value.
%function gJsf2060Write(JsfHead,Head,fNameNew), where
%JsfHead - structure with parent jsf-file description;
%Head - Message Header structure.
%fNameNew - string, the target file for writing.
%Example: gJsf2060Write(JsfHead,Head,'c:\temp\1new.jsf');

[fId, mes]=fopen(JsfHead.fName,'r+');if ~isempty(mes), error(['gJsfWrite2060: ' mes]);end;
if strcmp(fNameNew,JsfHead.fName), error('gJsfWrite2060: XtfHead.fName and fNameNew must be different.');end;
[fId2, mes]=fopen(fNameNew,'w');if ~isempty(mes), error(['gJsfWrite2060: ' mes]);end;
df=0;mm=0;nHead=find(JsfHead.HMessageType==2060);
for m=1:size(JsfHead.HMessageType,2),
    if ~(JsfHead.HMessageType(m)==2060),
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
    elseif (JsfHead.HMessageType(m)==2060),
        %===Begin JsfHeader Record Write
        fwrite(fId2,JsfHead.HMarkerForStart(m),'uint16'); %0-1// Marker for the Start of Header = 0x1601
        fwrite(fId2,JsfHead.HVersionOfProtocol(m),'uint8'); %2// Version of Protocol used
        fwrite(fId2,JsfHead.HSessionIdentifier(m),'uint8'); %3// Session Identifier
        fwrite(fId2,JsfHead.HMessageType(m),'uint16'); %4-5// Message Type (e.g. 2060 = Pressure Sensor)
        fwrite(fId2,JsfHead.HCommandType(m),'uint8'); %6// Command Type
        fwrite(fId2,JsfHead.HSubsystem(m),'uint8'); %7// Subsystem for a Multi-System Device. Common  subsystem assignments are as follows: Sub-bottom data - 0; Single frequency side scan data - 20; Lower frequency data of a dual frequency side scan - 20; Higher frequency data of a dual frequency side scan - 21; Higher frequency data of a tri-frequency side scan - 22; Raw serial/UDP/TCP data - 100 (v.1.20); Parsed serial/UDP/TCP data - 101 (v1.20); Raw UDP data - 103 (v.1.18);Parsed UPD data  - 104 (v1.18).
        fwrite(fId2,JsfHead.HChannelMulti(m),'uint8'); %8// Channel for a Multi-Channel Subsystem For Side Scan Subsystems; 0 = Port; 1 = Starboard; For Serial Ports: Port #
        fwrite(fId2,JsfHead.HSequenceNumber(m),'uint8'); %9// Sequence Number
        fwrite(fId2,JsfHead.HReserved(m),'uint16'); %10-11// Reserved
        fwrite(fId2,JsfHead.HSizeFollowingMessage(m),'uint32'); %12-15// Size of following Message in Bytes
        %===End JsfHeader Record Write
        mm=mm+1;
        if nHead(mm)~=Head.HMessageNum(mm), error(['Error: gFJsfWrite2060, not correct Messages order for message num=' num2str(mm)]);end;        
        %===Begin Head Write for Message Type 2060 (Header data from Head)
        fwrite(fId2,Head.TimeInSeconds(mm),'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
        fwrite(fId2,Head.MillisecondsCurrentSecond(mm),'int32'); %4-7// Milliseconds in the current second
        fwrite(fId2,Head.Reserved1(:,mm),'uint8'); %8-11// Reserved – Do not use
        fwrite(fId2,Head.Pressure(mm),'int32'); %12-15// Pressure in units of 1/1000th of a PSI
        fwrite(fId2,Head.TemperatureInUnits(mm),'int32'); %16-19// Temperature in units of 1/1000th of a degree Celsius
        fwrite(fId2,Head.Salinity(mm),'int32'); %20-23// Salinity in Parts Per Million
        fwrite(fId2,Head.DataValidFlags(mm),'int32'); %24-27// Data valid flags. Bit0:pressure; Bit1:temp; Bit 2:salt PPM; Bit3:conductivity; Bit 4:sound velocity; Bit 5: Depth.
        fwrite(fId2,Head.Conductivity(mm),'int32'); %28-31// Conductivity in micro-Siemens per cm
        fwrite(fId2,Head.VelocityOfSound(mm),'int32'); %32-35// Velocity of Sound in mm per second
        fwrite(fId2,Head.Reserved2(mm),'int32'); %36-39// Depth in Meters
        fwrite(fId2,Head.Reserved2(:,mm),'int32'); %40-75// Reserved – Do not use
        %===End Head Write for Message Type 2060
        %===Begin checking for Number Bytes This Record
        HSizeFollowingMessageNew=ftell(fId2)-JsfHead.RSeek(m); %estimate
        if (HSizeFollowingMessageNew~=JsfHead.HSizeFollowingMessage(m)),error(['Error: gFJsfWrite2060, not correct JsfHead.HSizeFollowingMessage for message num=' num2str(m)]);end;
        %===End checking for Number Bytes This Record
    end;
end;
fclose(fId2);
fclose(fId);

%mail@ge0mlib.com 19/03/2018