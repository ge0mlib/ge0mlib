function gJsf2020Write(JsfHead,Head,fNameNew)
%Write [JsfHead,Head] to *.jsf file for Message Type 2020 (Pitch Roll Data; 0004824_REV_1.20 used).
%All another messages (not 2020) are copied to new file from “parent’s” file without any changes, in accordance with JsfHead.ROnFlag’s value.
%function gJsf2020Write(JsfHead,Head,fNameNew,flTraceLenChanged), where
%JsfHead - structure with parent jsf-file description;
%Head - Message Header structure.
%fNameNew - string, the target file for writing;
%Example: gJsf2020Write(JsfHead,Head,'c:\temp\1new.jsf');

[fId, mes]=fopen(JsfHead.fName,'r+');if ~isempty(mes), error(['gJsfWrite2020: ' mes]);end;
if strcmp(fNameNew,JsfHead.fName), error('gJsfWrite2020: XtfHead.fName and fNameNew must be different.');end;
[fId2, mes]=fopen(fNameNew,'w');if ~isempty(mes), error(['gJsfWrite2020: ' mes]);end;
df=0;mm=0;nHead=find(JsfHead.HMessageType==2020);
for m=1:size(JsfHead.HMessageType,2),
    if ~(JsfHead.HMessageType(m)==2020),
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
    elseif (JsfHead.HMessageType(m)==2020),
        %===Begin JsfHeader Record Write
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
        mm=mm+1;
        if nHead(mm)~=Head.HMessageNum(mm), error(['Error: gFJsfWrite2020, not correct Messages order for message num=' num2str(mm)]);end;        
        %===Begin Head Write for Message Type 2020 (Header data from Head)
        fwrite(fId2,Head.TimeInSeconds(mm),'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
        fwrite(fId2,Head.MillisecondsCurrentSecond(mm),'int32'); %4-7// Milliseconds in the current second
        fwrite(fId2,Head.Reserved1(:,mm),'uint8'); %8-11// Reserved – Do not use
        fwrite(fId2,Head.AccelerationX(mm),'int16'); %12-13// Acceleration in x: Multiply by (20 * 1.5) / (32768) to get Gs
        fwrite(fId2,Head.AccelerationY(mm),'int16'); %14-15// Acceleration in y: Multiply by (20 * 1.5) / (32768) to get Gs
        fwrite(fId2,Head.AccelerationZ(mm),'int16'); %16-17// Acceleration in z: Multiply by (20 * 1.5) / (32768) to get Gs
        fwrite(fId2,Head.RateGyroX(mm),'int16'); %18-19// Rate Gyro in x: Multiply by (500 * 1.5) / (32768) to get Degrees/Sec
        fwrite(fId2,Head.RateGyroY(mm),'int16'); %20-21// Rate Gyro in y: Multiply by (500 * 1.5) / (32768) to get Degrees/Sec
        fwrite(fId2,Head.RateGyroZ(mm),'int16'); %22-23// Rate Gyro in z: Multiply by (500 * 1.5) / (32768) to get Degrees/Sec
        fwrite(fId2,Head.PitchMultiply(mm),'int16'); %24-25// Pitch Multiply by (180.0 / 32768.0) to get Degrees Bow up is positive
        fwrite(fId2,Head.RollMultiply(mm),'int16'); %26-27// Roll: Multiply by (180.0 / 32768.0) to get Degrees Port up is positive
        fwrite(fId2,Head.TemperatureInUnits(mm),'int16'); %28-29// Temperature in units of 1/10 of a degree Celsius
        fwrite(fId2,Head.DeviceSpecificInfo(mm),'uint16'); %30-31// Device specific info.  This is device specific info provided for Diagnostic purposes
        fwrite(fId2,Head.Heave(mm),'int16'); %32-33// Estimated Heave in millimeters
        fwrite(fId2,Head.Heading(mm),'uint16'); %34-35// Heading in units of 0.01 Degrees (0…360)
        fwrite(fId2,Head.DataValidFlags(mm),'int32'); %36-39// Data valid flags. Bit0:ax; Bit1:ay; Bit2:az; Bit3:rx; Bit4:ry; Bit5:rz; Bit6:pitch; Bit7:roll; Bit8:heave; Bit9:heading; Bit10:temperature; Bit 11:devInfo; Bit 12: yaw.
        fwrite(fId2,Head.Yaw(mm),'int16'); %40-41// Yaw (in 0.01 units span 0 to 360 degrees)
        fwrite(fId2,Head.Reserved2(mm),'int16'); %42-43// Reserved – Do not use
        %===End Head Write for Message Type 2020
        %===Begin checking for Number Bytes This Record
        HSizeFollowingMessageNew=ftell(fId2)-JsfHead.RSeek(m); %estimate
        if (HSizeFollowingMessageNew~=JsfHead.HSizeFollowingMessage(m)),error(['Error: gFJsfWrite2020, not correct JsfHead.HSizeFollowingMessage for message num=' num2str(m)]);end;
        %===End checking for Number Bytes This Record
    end;
end;
fclose(fId2);
fclose(fId);

%mail@ge0mlib.com 19/03/2018