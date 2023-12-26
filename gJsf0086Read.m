function [Head,Data]=gJsf0086Read(JsfHead,ChN,SubSys)
%Read [Head,Data] from JsfHead.fName (*.jsf) file for Message Type 0086 (4400-SAS Processed Data; 990-0000048-1000_Revision:1.7/Nov2006 used). Warning: NOT TESTED.
%function [Head,Data]=gJsf0086Read(JsfHead,ChN,SubSys), where
%JsfHead - Xsf Header structure;
%Head - Header structure;
%ChN - channel number;
%SubSys - subsystem number;
%Data - Data Body for sonar channel number ChN, subsystem number SubSys.
%Head include the addition fields: HMessageType, HChannelMulti, HSubsystem, HMessageNum.
%SAS (Synthetic Aperture Sonar) processed data consists of a 152 byte header, followed by port and starboard data.  This message is only present if there is SAS image data present. Unused fields are set to 0.
%Example: [Head,Data]=gJsf0086Read(JsfHead,0,0);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead0086: ' mes]);end;
LHead=(JsfHead.HMessageType==0086)&(JsfHead.HChannelMulti==ChN)&(JsfHead.HSubsystem==SubSys);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 0086
Head=struct('HMessageType',0086,'HChannelMulti',ChN,'HSubsystem',SubSys,'HMessageNum',zeros(1,LenHead),...
    'RangeLineCounter',zeros(1,LenHead),'Year',zeros(1,LenHead),'Month',zeros(1,LenHead),'Day',zeros(1,LenHead),'Hour',zeros(1,LenHead),'Minute',zeros(1,LenHead),'Second',zeros(1,LenHead),...
    'Latitude',zeros(1,LenHead),'Longitude',zeros(1,LenHead),'Heading',zeros(1,LenHead),'Pitch',zeros(1,LenHead),'Roll',zeros(1,LenHead),'Speed',zeros(1,LenHead),'Depth',zeros(1,LenHead),'Altitude',zeros(1,LenHead),...
    'SoundSpeed',zeros(1,LenHead),'BeamNumber',zeros(1,LenHead),'DataFormat',zeros(1,LenHead),...
    'PortDataAvailable',zeros(1,LenHead),'PortCarrierFrequency',zeros(1,LenHead),'PortWaveform',zeros(1,LenHead),'PortLongTrackSampleSize',zeros(1,LenHead),'PortLongTrackResolution',zeros(1,LenHead),...
    'PortCrossTrackSampleSize',zeros(1,LenHead),'PortCrossTrackResolution',zeros(1,LenHead),'PortStartingRange',zeros(1,LenHead),'PortNumberSamples',zeros(1,LenHead),...
    'StarboardDataAvailable',zeros(1,LenHead),'StarboardCarrierFrequency',zeros(1,LenHead),'StarboardWaveform',zeros(1,LenHead),'StarboardLongTrackSampleSize',zeros(1,LenHead),'StarboardLongTrackResolution',zeros(1,LenHead),...
    'StarboardCrossTrackSampleSize',zeros(1,LenHead),'StarboardCrossTrackResolution',zeros(1,LenHead),'StarboardStartingRange',zeros(1,LenHead),'StarboardNumberSamples',zeros(1,LenHead));
%===End Head Allocate for Message Type 0086
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 0086
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.RangeLineCounter(m)=fread(fId,1,'int32'); %0-3// Range line counter
    Head.Year(m)=fread(fId,1,'int32'); %4-7// Year
    Head.Month(m)=fread(fId,1,'int32'); %8-11// Month: 1-12
    Head.Day(m)=fread(fId,1,'int32'); %12-15// Day: 1-31
    Head.Hour(m)=fread(fId,1,'int32'); %16-19// Hour: 0-23
    Head.Minute(m)=fread(fId,1,'int32'); %20-23// Minute: 0-59
    Head.Second(m)=fread(fId,1,'float32'); %24-27// Second: 0.0-59.999
    %Navigation data
    Head.Latitude(m)=fread(fId,1,'float64'); %28-35// Latitude in degrees
    Head.Longitude(m)=fread(fId,1,'float64'); %36-43// Longitude in degrees
    Head.Heading(m)=fread(fId,1,'float32'); %44-47// Heading in degrees
    Head.Pitch(m)=fread(fId,1,'float32'); %48-51// Pitch in degrees
    Head.Roll(m)=fread(fId,1,'float32'); %52-55// Roll in degrees
    Head.Speed(m)=fread(fId,1,'float32'); %56-59// Speed over bottom in meters per second
    Head.Depth(m)=fread(fId,1,'float32'); %60-63// Depth in meters
    Head.Altitude(m)=fread(fId,1,'float32'); %64-67// Altitude in meters
    Head.SoundSpeed(m)=fread(fId,1,'float32'); %68-71// Sound speed in meters per second
    %Beam Information
    Head.BeamNumber(m)=fread(fId,1,'int32'); %72-75// Beam number 0-#
    Head.DataFormat(m)=fread(fId,1,'int32'); %76-79// Data format: 7= 2 floats per sample - stored as real(1),imag(1); 8= 1 float per sample - envelope data.
    %Port Information
    Head.PortDataAvailable(m)=fread(fId,1,'int32'); %80-83// Port data available 0 = No, all bits set = Yes 
    Head.PortCarrierFrequency(m)=fread(fId,1,'int32'); %84-87// Port carrier frequency in Hertz
    Head.PortWaveform(m)=fread(fId,1,'int32'); %88-91// Port waveform ID
    Head.PortLongTrackSampleSize(m)=fread(fId,1,'float32'); %92-95// Port long track sample size in meters
    Head.PortLongTrackResolution(m)=fread(fId,1,'float32'); %96-99// Port long track resolution in meters
    Head.PortCrossTrackSampleSize(m)=fread(fId,1,'float32'); %100-103// Port cross track sample size in meters
    Head.PortCrossTrackResolution(m)=fread(fId,1,'float32'); %104-107// Port cross track resolution in meters
    Head.PortStartingRange(m)=fread(fId,1,'float32'); %108-111// Port starting range in meters
    Head.PortNumberSamples(m)=fread(fId,1,'int32'); %112-115// Port number of samples
    %Starboard Information
    Head.StarboardDataAvailable(m)=fread(fId,1,'int32'); %116-119// Starboard data available 0 = No, all bits set = Yes
    Head.StarboardCarrierFrequency(m)=fread(fId,1,'int32'); %120-123// Starboard carrier frequency in Hertz
    Head.StarboardWaveform(m)=fread(fId,1,'int32'); %124-127// Starboard waveform ID
    Head.StarboardLongTrackSampleSize(m)=fread(fId,1,'float32'); %128-131// Starboard long track sample size in meters
    Head.StarboardLongTrackResolution(m)=fread(fId,1,'float32'); %132-135// Starboard long track resolution in meters
    Head.StarboardCrossTrackSampleSize(m)=fread(fId,1,'float32'); %136-139// Starboard cross track sample size in meters
    Head.StarboardCrossTrackResolution(m)=fread(fId,1,'float32'); %140-143// Starboard cross track resolution in meters
    Head.StarboardStartingRange(m)=fread(fId,1,'float32'); %144-147// Starboard starting range in meters
    Head.StarboardNumberSamples(m)=fread(fId,1,'int32'); %148-151// Starboard number of samples
    %===End Head Read for Message Type 0086
    df=ftell(fId);
end;
%===Begin Data Allocate for Message Type 0086
if all(Head.DataFormat==8), Data=zeros(max([Head.PortNumberSamples Head.StarboardNumberSamples]),LenHead,2);
elseif all(Head.DataFormat==7), Data=complex(zeros(max([Head.PortNumberSamples Head.StarboardNumberSamples]),LenHead,2));
else error('Error gJsf0086Read: unknown/bad Head.DataFormat');
end;
%===End Data Allocate for Message Type 0086
fseek(fId,0,'bof');df=0;
for m=1:LenHead,
    if ~mod(m,5000), disp(['Trace: ',num2str(m)]);end;
    %===Begin Data Read for Message Type 0086
    fseek(fId,JsfHead.RSeek(nHead(m))+152-df,'cof');
    switch Head.DataFormat(m),
        case 8,
            Data(1:Head.PortNumberSamples(m),m,1)=fread(fId,Head.PortNumberSamples(m),'float32');
            Data(1:Head.Head.StarboardNumberSamples(m),m,2)=fread(fId,Head.StarboardNumberSamples(m),'float32');
        case 7,
            tmp=fread(fId,Head.PortNumberSamples(m).*2,'float32');tmp=reshape(tmp,2,length(tmp)./2);
            Data(1:Head.PortNumberSamples(m),m,1)=complex(tmp(1,:),tmp(2,:));
            tmp=fread(fId,Head.StarboardNumberSamples(m).*2,'float32');tmp=reshape(tmp,2,length(tmp)./2);
            Data(1:Head.StarboardNumberSamples(m),m,1)=complex(tmp(1,:),tmp(2,:));
    end;
    %===End Data Read for Message Type 0086
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018