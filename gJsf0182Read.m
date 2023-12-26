function Head=gJsf0182Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 0182 (System Information Message; 0004824_REV_1.20 used).
%function Head=gJsf0182Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%The system information message contains details of the system used to acquire data. This message is normally present at the beginning of a JSF file, and may be repeated if configuration parameters change.
%Example: Head=gJsf0182Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead0182: ' mes]);end;
LHead=(JsfHead.HMessageType==0182);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 0182
Head=struct('HMessageType',0182,'HMessageNum',zeros(1,LenHead),...
    'SystemType',zeros(1,LenHead),'LowRateIO',zeros(1,LenHead),'VersionNumberSonarSoftware',zeros(4,LenHead),...
    'NumberSubsystems',zeros(1,LenHead),'NumberSerialPortDevices',zeros(1,LenHead),'SerialNumberTowVehicle',zeros(1,LenHead),'Reserved3',zeros(max(JsfHead.HSizeFollowingMessage(nHead))-24,LenHead));
%===End Head Allocate for Message Type 0182
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 0182
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.SystemType(m)=fread(fId,1,'int32'); %0-3// System Type see JsfHead.Descript.SystemTypeNumber.Code and JsfHead.Descript.SystemTypeNumber.Text
    Head.LowRateIO(m)=fread(fId,1,'int32'); %4-7// Low rate IO enabled option (0 =  disabled)
    Head.VersionNumberSonarSoftware(m)=fread(fId,1,'int32'); %8-11// Version Number of Sonar Software used to generate data
    Head.NumberSubsystems(m)=fread(fId,1,'int32'); %12-15// Number of Subsystems present in this message
    Head.NumberSerialPortDevices(m)=fread(fId,1,'int32'); %16-19// Number of Serial port devices present in this message
    Head.SerialNumberTowVehicle(m)=fread(fId,1,'int32'); %20-23// Serial Number of Tow Vehicle used to collect data
    Head.Reserved3(1:JsfHead.HSizeFollowingMessage(nHead(m))-24,m)=char(fread(fId,JsfHead.HSizeFollowingMessage(nHead(m))-24,'uint8')); %24-end// Reserved3 data
    %===End Head Read for Message Type 0182
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018