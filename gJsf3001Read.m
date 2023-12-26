function Head=gJsf3001Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 3001 (Attitude Message Type; 0014932_REV_D March 2016 used).
%function Head=gJsf3001Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%AttitudeMessageType is a source for roll, pitch, heave, and heading data. Yaw is not used. Some or all of these fields may be valid (or set to 1) depending on which type(s) of sensor is (are) used.
%Example: Head=gJsf3001Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead3001: ' mes]);end;
LHead=(JsfHead.HMessageType==3001);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 3001
Head=struct('HMessageType',3001,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'NanosecondSupplementTime',zeros(1,LenHead),'DataValidFlag',zeros(1,LenHead),...
    'Heading',zeros(1,LenHead),'Heave',zeros(1,LenHead),'Pitch',zeros(1,LenHead),'Roll',zeros(1,LenHead),'Yaw',zeros(1,LenHead));
%===End Head Allocate for Message Type 3001
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 3001
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'uint32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.NanosecondSupplementTime(m)=fread(fId,1,'uint32'); %4-7// Nanosecond Supplement to Time; The time stamp accuracy of this message with respect to the sonar ping emission time is approximately 1 millisecond at 80% and 2 milliseconds at 100% of the samples.
    Head.DataValidFlag(m)=fread(fId,1,'uint32'); %8-11// Data Valid Flag: Bit0-Heading; Bit1-Heave; Bit2-Pitch; Bit3-Roll; Bit4-Yaw. 0 is clear, 1 is set. The validity of each field is indicated in the Data Valid Flag (bytes 8-11) and it is imperative that this is used to correctly parse the fields.
    Head.Heading(m)=fread(fId,1,'float32'); %12-15// Heading (0 to 359.9), Degrees.
    Head.Heave(m)=fread(fId,1,'float32'); %16-19// Heave, Meters, positive down.
    Head.Pitch(m)=fread(fId,1,'float32'); %20-23// Pitch, Degrees, positive bow up.
    Head.Roll(m)=fread(fId,1,'float32'); %24-27// Roll, Degrees, positive port up.
    Head.Yaw(m)=fread(fId,1,'float32'); %28-31// Yaw, Degrees, positive to starboard.
    %===End Head Read for Message Type 3001
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018