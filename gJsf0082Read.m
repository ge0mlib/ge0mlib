function [Head,Data]=gJsf0082Read(JsfHead,ChN,SubSys)
%Read [Head,Data] from JsfHead.fName (*.jsf) file for Message Type 0082 (Side Scan Data Message; 0004824_REV_1.18 used). Warning: NOT TESTED.
%function [Head,Data]=gJsf0082Read(JsfHead,ChN,SubSys), where
%JsfHead - Xsf Header structure;
%Head - Header structure;
%ChN - channel number;
%SubSys - subsystem number;
%Data - Data Body for sonar channel number ChN, subsystem number SubSys.
%Head include the addition fields: HMessageType, HChannelMulti, HSubsystem, HMessageNum.
%Example: [Head,Data]=gJsf0082Read(JsfHead,20,1);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead0082: ' mes]);end;
LHead=(JsfHead.HMessageType==82)&(JsfHead.HChannelMulti==ChN)&(JsfHead.HSubsystem==SubSys);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 0082
Head=struct('HMessageType',0082,'HChannelMulti',ChN,'HSubsystem',SubSys,'HMessageNum',zeros(1,LenHead),...
    'HMessageNum',zeros(1,LenHead),'Subsystem',zeros(1,LenHead),'ChannelNumber',zeros(1,LenHead),'PingNumber',zeros(1,LenHead),'PacketNumber',zeros(1,LenHead),'TriggerSource',zeros(1,LenHead),'SamplesInPacket',zeros(1,LenHead),...
    'SampleInterval',zeros(1,LenHead),'StartingDepth',zeros(1,LenHead),'WeightingFactor',zeros(1,LenHead),'GainFactorAdc',zeros(1,LenHead),'MaximumAbsoluteValueAdc',zeros(1,LenHead),...
    'RangeSetting',zeros(1,LenHead),'PulseIdentifier',zeros(1,LenHead),'MarkNumber',zeros(1,LenHead),'DataFormat',zeros(1,LenHead),'NumberSimultaneousPulses',zeros(1,LenHead),...
    'Reserved1',zeros(1,LenHead),'MillisecondsToday',zeros(1,LenHead),'Year',zeros(1,LenHead),'Day',zeros(1,LenHead),'Hour',zeros(1,LenHead),...
    'Minute',zeros(1,LenHead),'Second',zeros(1,LenHead),'CompassHeading',zeros(1,LenHead),'Pitch',zeros(1,LenHead),...
    'Roll',zeros(1,LenHead),'Heave',zeros(1,LenHead),'Yaw',zeros(1,LenHead),'Pressure',zeros(1,LenHead),'TemperatureInUnits',zeros(1,LenHead),'WaterTemperature',zeros(1,LenHead),...
    'Altitude',zeros(1,LenHead),'Reserved2',zeros(4,LenHead));
%===End Head Allocate for Message Type 0082
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 0082
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.Subsystem(m)=fread(fId,1,'uint16'); %0-1// Subsystem (0 .. n)
    Head.ChannelNumber(m)=fread(fId,1,'uint16'); %2-3// Channel Number (0 .. n)
    Head.PingNumber(m)=fread(fId,1,'uint32'); %4-7// Ping Number (increments with each ping)
    Head.PacketNumber(m)=fread(fId,1,'uint16'); %8-9// Packet number (1..n) Each ping starts with packet 1
    Head.TriggerSource(m)=fread(fId,1,'uint16'); %10-11// TriggerSource (0 = internal, 1 = external) 
    Head.NumberDataSamples(m)=fread(fId,1,'uint32'); %12-15// Samples in this packet
    Head.SampleInterval(m)=fread(fId,1,'uint32'); %16-19// Sample interval in ns of stored data 
    Head.StartingDepth(m)=fread(fId,1,'uint32'); %20-23// Starting Depth (window offset) in samples
    Head.WeightingFactor(m)=fread(fId,1,'int16'); %24-25// Weighting Factor : Defined as 2^–N volts 
    Head.GainFactorAdc(m)=fread(fId,1,'uint16'); %26-27// Gain factor of ADC
    Head.MaximumAbsoluteValueAdc(m)=fread(fId,1,'uint16'); %28-29// Maximum absolute value for ADC samples for this packet
    Head.RangeSetting(m)=fread(fId,1,'uint16'); %30-31// Range Setting (in decameters) (meters times 10)
    Head.PulseIdentifier(m)=fread(fId,1,'uint16'); %32-33// Unique pulse identifier 
    Head.MarkNumber(m)=fread(fId,1,'uint16'); %34-35// Mark Number (0 = no mark)
    Head.DataFormat(m)=fread(fId,1,'uint16'); %36-37// Data format. 0 = 1 short per sample  - envelope data the total number of bytes of data to follow is 2 * samples; 1 = 2 shorts per sample  - stored as real(1), imag(1), the total number of bytes of data to follow is 4 * samples
    Head.NumberSimultaneousPulses(m)=fread(fId,1,'uint8'); %38// Number of simultaneous pulses in the water
    Head.Reserved1(m)=fread(fId,1,'uint8'); %39// Reserved – Do not use
    %Computer date / time data acquired
    Head.MillisecondsToday(m)=fread(fId,1,'uint32'); %40-43// Milliseconds today
    Head.Year(m)=fread(fId,1,'int16'); %44-45// Year
    Head.Day(m)=fread(fId,1,'uint16'); %46-47// Day (1–366)
    Head.Hour(m)=fread(fId,1,'uint16'); %48-49// Hour of day (0–23)
    Head.Minute(m)=fread(fId,1,'uint16'); %50-51// Minute (0–59)
    Head.Second(m)=fread(fId,1,'uint16'); %52-53// Second (0–59)
    %Auxiliary sensor information 
    Head.CompassHeading(m)=fread(fId,1,'uint16'); %54-55// Compass heading in minutes (0–360)x60
    Head.Pitch(m)=fread(fId,1,'int16'); %56-57// Pitch Scale by 180/32768 to get degrees, + = bow up
    Head.Roll(m)=fread(fId,1,'int16'); %58-59// Roll Scale by 180/32768 to get degrees, + = port up
    Head.Heave(m)=fread(fId,1,'int16'); %60-61// Heave (centimeters)
    Head.Yaw(m)=fread(fId,1,'int16'); %62-63// Yaw (minutes)
    Head.Pressure(m)=fread(fId,1,'uint32'); %64-67// Pressure in units of 1/1000 PSI
    Head.TemperatureInUnits(m)=fread(fId,1,'uint16'); %68-69// Temperature in units of 1/10 of a degree Celsius
    Head.WaterTemperature(m)=fread(fId,1,'int16'); %70-71// Water Temperature in units of 1/10 of a degree Celsius
    Head.Altitude(m)=fread(fId,1,'int32'); %72-75// Altitude in millimeters (or -1 if no valid reading)
    Head.Reserved2(:,m)=fread(fId,4,'uint8'); %76-79// Reserved – Do not use
    %===End Head Read for Message Type 0082
    df=ftell(fId);
end;
%===Begin Data Allocate for Message Type 0082
if all(Head.DataFormat==0), Data=zeros(max(Head.NumberDataSamples),LenHead);
elseif all(Head.DataFormat==1), Data=complex(zeros(max(Head.NumberDataSamples),LenHead));
else error('Error gJsf0082Read: unknown/bad Head.DataFormat');
end;
%===End Data Allocate for Message Type 0082
fseek(fId,0,'bof');df=0;
for m=1:LenHead,
    if ~mod(m,5000), disp(['Trace: ',num2str(m)]);end;
    %===Begin Data Read for Message Type 0082
    fseek(fId,JsfHead.RSeek(nHead(m))+80-df,'cof');
    switch Head.DataFormat(m),
        case 0,
            tmp=fread(fId,Head.NumberDataSamples(m),'int16');
            Data(1:Head.NumberDataSamples(m),m)=tmp.*2.^(-Head.WeightingFactor(m));
        case 1,
            tmp=fread(fId,Head.NumberDataSamples(m).*2,'int16');tmp=reshape(tmp,2,length(tmp)./2);
            Data(1:Head.NumberDataSamples(m),m)=complex(tmp(1,:),tmp(2,:)).*2.^(-Head.WeightingFactor(m));
    end;
    %===End Data Read for Message Type 0082
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018