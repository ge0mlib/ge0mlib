function Head=gJsf2020Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 2020 (Pitch Roll Data; 0004824_REV_1.20 used).
%function Head=gJsf2020Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%A pitch roll message consists of a single reading from a pitch roll sensor such as a Seatex MRU, TSS or Octans device.
%Example: Head=gJsf2020Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead2020: ' mes]);end;
LHead=(JsfHead.HMessageType==2020);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 2020
Head=struct('HMessageType',2020,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'MillisecondsCurrentSecond',zeros(1,LenHead),'Reserved1',zeros(4,LenHead),...
    'AccelerationX',zeros(1,LenHead),'AccelerationY',zeros(1,LenHead),'AccelerationZ',zeros(1,LenHead),'RateGyroX',zeros(1,LenHead),'RateGyroY',zeros(1,LenHead),...
    'RateGyroZ',zeros(1,LenHead),'PitchMultiply',zeros(1,LenHead),'RollMultiply',zeros(1,LenHead),'TemperatureInUnits',zeros(1,LenHead),'DeviceSpecificInfo',zeros(1,LenHead),...
    'Heave',zeros(1,LenHead),'Heading',zeros(1,LenHead),'DataValidFlags',zeros(1,LenHead),'Yaw',zeros(1,LenHead),'Reserved2',zeros(1,LenHead));
%===End Head Allocate for Message Type 2020
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 2020
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.MillisecondsCurrentSecond(m)=fread(fId,1,'int32'); %4-7// Milliseconds in the current second
    Head.Reserved1(:,m)=fread(fId,4,'uint8'); %8-11// Reserved – Do not use
    Head.AccelerationX(m)=fread(fId,1,'int16'); %12-13// Acceleration in x: Multiply by (20 * 1.5) / (32768) to get Gs
    Head.AccelerationY(m)=fread(fId,1,'int16'); %14-15// Acceleration in y: Multiply by (20 * 1.5) / (32768) to get Gs
    Head.AccelerationZ(m)=fread(fId,1,'int16'); %16-17// Acceleration in z: Multiply by (20 * 1.5) / (32768) to get Gs
    Head.RateGyroX(m)=fread(fId,1,'int16'); %18-19// Rate Gyro in x: Multiply by (500 * 1.5) / (32768) to get Degrees/Sec
    Head.RateGyroY(m)=fread(fId,1,'int16'); %20-21// Rate Gyro in y: Multiply by (500 * 1.5) / (32768) to get Degrees/Sec
    Head.RateGyroZ(m)=fread(fId,1,'int16'); %22-23// Rate Gyro in z: Multiply by (500 * 1.5) / (32768) to get Degrees/Sec
    Head.PitchMultiply(m)=fread(fId,1,'int16'); %24-25// Pitch Multiply by (180.0 / 32768.0) to get Degrees Bow up is positive
    Head.RollMultiply(m)=fread(fId,1,'int16'); %26-27// Roll: Multiply by (180.0 / 32768.0) to get Degrees Port up is positive
    Head.TemperatureInUnits(m)=fread(fId,1,'int16'); %28-29// Temperature in units of 1/10 of a degree Celsius
    Head.DeviceSpecificInfo(m)=fread(fId,1,'uint16'); %30-31// Device specific info.  This is device specific info provided for Diagnostic purposes
    Head.Heave(m)=fread(fId,1,'int16'); %32-33// Estimated Heave in millimeters. Positive is Down.
    Head.Heading(m)=fread(fId,1,'uint16'); %34-35// Heading in units of 0.01 Degrees (0…360)
    Head.DataValidFlags(m)=fread(fId,1,'int32'); %36-39// Data valid flags. Bit0:ax; Bit1:ay; Bit2:az; Bit3:rx; Bit4:ry; Bit5:rz; Bit6:pitch; Bit7:roll; Bit8:heave; Bit9:heading; Bit10:temperature; Bit 11:devInfo; Bit 12: yaw.
    Head.Yaw(m)=fread(fId,1,'int16'); %40-41// Yaw (in 0.01 units span 0 to 360 degrees)
    Head.Reserved2(m)=fread(fId,1,'int16'); %42-43// Reserved – Do not use
    %===End Head Read for Message Type 2020
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018