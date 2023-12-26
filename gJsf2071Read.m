function Head=gJsf2071Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 2071 (Reflection Coefficient Message; 0023492_Rev_C used).
%function Head=gJsf2071Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%The refection coefficient message contains details used in the reflection coefficient calculation. There is one 2071 message per ping at most. If the sonar is in dual alternating pulse mode (noted in the standard JSF field’s CHANNEL FIELD), each ping for each channel of JSF data gets its own reflection coefficient identified via that channel field.
%EdgeTech recommends smoothing the reflection coefficient values because they can be noisy. The values reported in 2071 are unaveraged, giving full control of the averaging scheme to whatever is processing the JSF downstream.
%Example: Head=gJsf2071Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead2071: ' mes]);end;
LHead=(JsfHead.HMessageType==2071);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 2071
Head=struct('HMessageType',2071,'HMessageNum',zeros(1,LenHead),...
    'PingNumber',zeros(1,LenHead),'ReflectionCoefficientDecibels',zeros(1,LenHead),'AltitudeMilliseconds',zeros(1,LenHead),...
    'CalibrationGainDecibels',zeros(1,LenHead),'CalibrationReferenceDecibels',zeros(1,LenHead),'Reserved',zeros((max(JsfHead.HSizeFollowingMessage(nHead))-20)./4,LenHead));
%===End Head Allocate for Message Type 2071
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 2071
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.PingNumber(m)=fread(fId,1,'uint32'); %0-3//  pingNumber. The ping number the reflection coefficient that was computed for. Use with the subsystem, channel, and timestamp unambiguously associated with a ping.
    Head.ReflectionCoefficientDecibels(m)=fread(fId,1,'float32'); %4-7// reflectionCoefficientDecibels. The reflection  coefficient in decibels. Good values are between 0 and -40.
    Head.AltitudeMilliseconds(m)=fread(fId,1,'float32'); %8-11// altitudeMilliseconds. Altitude in milliseconds where the reflection coefficient was computed.
    Head.CalibrationGainDecibels(m)=fread(fId,1,'float32'); %12-15// calibrationGainDecibels. Pulse calibration gain in decibels applied to sonar samples before reflection coefficient calculation.
    Head.CalibrationReferenceDecibels(m)=fread(fId,1,'float32'); %16-19// calibrationReferenceDecibels. The calibration “zero-point’ in decibels. This value was subtracted from the computer reflection coefficient value to get the value reported in the reflection.
    Head.Reserved(1:(JsfHead.HSizeFollowingMessage(nHead(m))-20)./4,m)=fread(fId,(JsfHead.HSizeFollowingMessage(nHead(m))-20)./4,'uint32'); %20-end// Reserved.
    %===End Head Read for Message Type 2071
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 08/04/2021