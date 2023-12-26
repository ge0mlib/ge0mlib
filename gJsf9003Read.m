function Head=gJsf9003Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 9003 ( DISCOVER II Acoustic Prefix Message; 0004824_REV_1.18 used). Warning: NOT TESTED.
%function Head=gJsf9003Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%This is a prefix message with supplementary data for the acoustic (type 80) message which follows it. This message consists of a fixed header containing supplementary acoustic information, followed by the situation information for that channel.
%Example: Head=gJsf9003Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead9003: ' mes]);end;
LHead=(JsfHead.HMessageType==9003);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 9003
Head=struct('HMessageType',9003,'HMessageNum',zeros(1,LenHead),'Timestamp',zeros(1,LenHead),'DataSourceSerialNumber',zeros(1,LenHead),'MessageVersionNumber',zeros(4,LenHead),'DataSourceDevice',zeros(1,LenHead),...
    'PingNumber',zeros(1,LenHead),'MixerFrequency',zeros(1,LenHead),'MixerPhase',zeros(1,LenHead),'SampleRate',zeros(1,LenHead),'SampleOffset',zeros(1,LenHead),...
    'ProcessingFlags',zeros(1,LenHead),'PulseIndex',zeros(1,LenHead),'OriginalDataSource',zeros(1,LenHead),'DataSource',zeros(1,LenHead),'MpxPulseNumber',zeros(1,LenHead),'PacketNumber',zeros(1,LenHead));
%===End Head Allocate for Message Type 9003
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 9003
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.Timestamp(m)=fread(fId,1,'int64'); %0-7// Timestamp in the higher resolution DISCOVER II format. This is equivalent to the Microsoft Dot Net DateTime. Ticks property. The resolution is 10^-7 of a second (0.1 microsecond per increment), and is referenced to 12:00 midnight, Jan 1, 0001 C.E. in the Gregorian Calendar.
    Head.DataSourceSerialNumber(m)=fread(fId,1,'int32'); %8-11// Data Source Serial Number. A unique serial number, which could for example distinguish one tow fish from another, otherwise identically configured tow fish.
    Head.MessageVersionNumber(m)=fread(fId,1,'int16'); %12-13// Message Version Number. This is the version number of this message. This number may differ from the protocol version number in the main message header.
    Head.DataSourceDevice(m)=fread(fId,1,'int16'); %14-15// Data Source Device. For each Serial Number, there may be multiple devices.
    Head.PingNumber(m)=fread(fId,1,'int32'); %16-19// Ping Number (for redundant validation of the following messages ping number).
    Head.MixerFrequency(m)=fread(fId,1,'float32'); %20-23// Mixer Frequency in kHz if the data is base banded.
    Head.MixerPhase(m)=fread(fId,1,'float32'); %24-27// Mixer Phase at first sample of ping measured in Turns. Range is 0.0 to 1.0 where 0.0 indicates a phase of 0 and 0.5 indicates a phase of 180 degrees.
    Head.SampleRate(m)=fread(fId,1,'float32'); %28-31// Sample Rate in kHz.
    Head.SampleOffset(m)=fread(fId,1,'uint32'); %32-35// Sample Offset in samples to the first sample in the acoustic message.
    Head.ProcessingFlags(m)=fread(fId,1,'uint16'); %36-37// Processing Flags - Reserved.
    Head.PulseIndex(m)=fread(fId,1,'uint16'); %38-39// Pulse Index of active pulse in configuration.
    Head.OriginalDataSource(m)=fread(fId,1,'uint8'); %40// Original Data Source - Reserved.
    Head.DataSource(m)=fread(fId,1,'uint8'); %41// Data source: 1=Acquire (Diagnostic output only); 2=Acquire Windowed (AKA raw data); 3=Match Filtered (Diagnostic output only); 4=Math Filtered Windowed (AKA match filtered data); 5=Post Match Filter Processed.
    %Note: It is possible to get the same data at multiple processing stages in the file. The normal output would be type 4 or type 5 - where type 5 would be present if there is a post-match filter processor (e.g. MPX or Dynamic Focus blending).
    Head.MpxPulseNumber(m)=fread(fId,1,'uint8'); %42// MPX Pulse Number (0 to 3).
    Head.PacketNumber(m)=fread(fId,1,'uint8'); %43// Packet Number (Only applies to diagnostic multi-packed data).
    %===End Head Read for Message Type 9003
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018