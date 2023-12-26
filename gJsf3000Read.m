function [Head,Data]=gJsf3000Read(JsfHead,ChN,SubSys)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 3000 (Bathymetric Data Message Type; 0014932_REV_D March 2016 used).
%function Head=gJsf3000Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%This is the primary message sent from the Bathymetry System. For each ping, there is one message for the port side, and one for the starboard side.
%This message contains the time delay, angle and amplitude of each assumed seafloor echo. Multiple messages of this type are interspersed throughout the data file or  data  stream.
%This message consists of a header, followed by a number of bathymetric samples (numberOfSamples), one corresponding to each sounding point.
%Example: Head=gJsf3000Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead3000: ' mes]);end;
LHead=(JsfHead.HMessageType==3000)&(JsfHead.HChannelMulti==ChN)&(JsfHead.HSubsystem==SubSys);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 3000
Head=struct('HMessageType',3000,'HChannelMulti',ChN,'HSubsystem',SubSys,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'NanosecondSupplementTime',zeros(1,LenHead),'PingNumber',zeros(1,LenHead),'NumberBathymetricSampleType',zeros(1,LenHead),'Channel',zeros(1,LenHead),'AlgorithmType',zeros(1,LenHead),...
    'NumberPulses',zeros(1,LenHead),'PulsePhase',zeros(1,LenHead),'PulseLength',zeros(1,LenHead),'TransmitPulseAmplitude',zeros(1,LenHead),...
    'ChirpStartFrequency',zeros(1,LenHead),'ChirpEndFrequency',zeros(1,LenHead),'MixerFrequency',zeros(1,LenHead),'SampleRate',zeros(1,LenHead),'OffsetFirstSample',zeros(1,LenHead),'TimeDelayUncertainty',zeros(1,LenHead),...
    'TimeScaleFactor',zeros(1,LenHead),'TimeScaleAccuracy',zeros(1,LenHead),'AngleScaleFactor',zeros(1,LenHead),'Reserved1',zeros(1,LenHead),'TimeFirstBottomReturn',zeros(1,LenHead),'FormatRevisionLevel',zeros(1,LenHead),...
    'BinningFlag',zeros(1,LenHead),'TVG',zeros(1,LenHead),'Reserved2',zeros(1,LenHead),'Span',zeros(1,LenHead),'Reserved3',zeros(1,LenHead));
%===End Head Allocate for Message Type 3000
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 3000
    %Use these data to derive the raw X and Z data samples prior to any motion correction. As of May 2014 bytes 18-19, 44-47, 60-63, and 70 have been modified.
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'uint32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.NanosecondSupplementTime(m)=fread(fId,1,'uint32'); %4-7// Nanosecond Supplement to Time; The time stamp accuracy of this message with respect to the sonar ping emission time is approximately 1 millisecond at 80% and 2 milliseconds at 100% of the samples.
    Head.PingNumber(m)=fread(fId,1,'uint32'); %8-11// Ping Number.
    Head.NumberBathymetricSampleType(m)=fread(fId,1,'uint16'); %12-13// Number of BathymetricSampleType Entries.
    Head.Channel(m)=fread(fId,1,'uint8'); %14// Channel (0–port, 1–starboard).
    Head.AlgorithmType(m)=fread(fId,1,'uint8'); %15// Algorithm Type.
    Head.NumberPulses(m)=fread(fId,1,'uint8'); %16// Number of Pulses.
    Head.PulsePhase(m)=fread(fId,1,'uint8'); %17// Pulse Phase.
    Head.PulseLength(m)=fread(fId,1,'uint16'); %18-19// Pulse Length, Milliseconds.
    Head.TransmitPulseAmplitude(m)=fread(fId,1,'float32'); %20-23// Transmit Pulse Amplitude (0 to 1).
    Head.ChirpStartFrequency(m)=fread(fId,1,'float32'); %24-27// Chirp Start Frequency, Hertz.
    Head.ChirpEndFrequency(m)=fread(fId,1,'float32'); %28-31// Chirp End Frequency, Hertz.
    Head.MixerFrequency(m)=fread(fId,1,'float32'); %32-35// Mixer Frequency, Hertz.
    Head.SampleRate(m)=fread(fId,1,'float32'); %36-39// Sample Rate, Hertz.
    Head.OffsetFirstSample(m)=fread(fId,1,'uint32'); %40-43// OffsetFirstSample, Nanoseconds.
    Head.TimeDelayUncertainty(m)=fread(fId,1,'float32'); %44-47// Time Delay Uncertainty, Seconds.
    %The Time Delay Uncertainty Estimate (bytes 44-47) is the potential acoustic uncertainty of the true delay to each detected echo. This field is used to compute the range uncertainty, in meters, for each sample in the data packet and is expressed at the 2-sigma level.
    Head.TimeScaleFactor(m)=fread(fId,1,'float32'); %48-51// Time Scale Factor, Seconds.
    Head.TimeScaleAccuracy(m)=fread(fId,1,'float32'); %52-55// Time Scale Accuracy, Percent.
    Head.AngleScaleFactor(m)=fread(fId,1,'uint32'); %56-59// Angle Scale Factor, Degrees.
    Head.Reserved1(m)=fread(fId,1,'uint32'); %60-63// Reserved.
    Head.TimeFirstBottomReturn(m)=fread(fId,1,'uint32'); %64-67// Time to First Bottom Return, Nanoseconds.
    Head.FormatRevisionLevel(m)=fread(fId,1,'uint8'); %68// Format Revision Level (0 to 4).
    %The Format Revision Level (byte 68) may have a value between 0 and 4. 
    %Revisions 0 through 2 only provide information for interferometric data, whereas Revision 3 and 4 supports the interferometric and pseudo multibeam data formats.
    %Even though the latest Format Revision Level supports interferometric output, it is rarely used and should not be implemented unless absolutely necessary.
    Head.BinningFlag(m)=fread(fId,1,'uint8'); %69// Binning Flag (0 to 2).
    %The Binning Flag (byte69) specifies the type of binning output and may have a value between 0 and 2.
    %A value of 0 indicates that no binning has been carried out and the data output is purely interferometric;
    %A value of 1 indicates the data have been binned based on a user defined equidistant across track bin size to produce multibeam-like data;
    %A value of 2 indicates that the data have been binned based on a user defined equiangular beam size to produce an alternate form of multibeam-like data.
    %When this binning process is carried out, the data are filtered (or cleaned of outliers) as much as possible prior to binning so that each local estimate is not corrupted by surface or wake artifacts. A median estimate, as opposed to an average, is also used to reduce the effects of outliers on the local estimates.
    %As of July 2014 the DISCOVER BATHYMETRIC Acquisition Software no longer supports the interferometric output and only binned data are provided. This change affects the Flag Interpretation Fields.
    Head.TVG(m)=fread(fId,1,'uint8'); %70// TVG, dB/100m.
    %The TVG field (byte 70) is the particular value that has been applied to the bathymetry datagrams during data collection. This TVG does not apply to the side scan records.
    Head.Reserved2(m)=fread(fId,1,'uint8'); %71// Reserved.
    Head.Span(m)=fread(fId,1,'float32'); %72-75// Span, Meter or Degrees.
    %Span (bytes 72-75) states the number of samples returned per side, per ping. This parameter can be specified in meters or in degrees and depends on the binning type selected in byte 69.
    %The correlation between Binning and Span:
    %If Binning=0, then Span=Maximum processing range defined in the bathymetric processing parameters (in meters).
    %If Binning=1, then Span=Number of bins x bin size (in meters).
    %If Binning=2, then Span=Number of beams x beam size (in degrees).
    %Therefore, the final data set would be computed as Span x 2;
    Head.Reserved3(m)=fread(fId,1,'uint32'); %76-79// Reserved.
    %===End Head Read for Message Type 3000
    df=ftell(fId);
end;
%===Begin Data Allocate for Message Type 3000
tmp=max(Head.NumberBathymetricSampleType);
if all(Head.FormatRevisionLevel==0)||all(Head.FormatRevisionLevel==1)||all(Head.FormatRevisionLevel==2)||all(Head.FormatRevisionLevel==3), error('gJsfRead3000: FormatRevisionLevel==1..3 is not defined.');
elseif all(Head.FormatRevisionLevel==4),
    Data=struct('TimeDelay',nan(tmp,LenHead),'Angle',nan(tmp,LenHead),'Amplitude',nan(tmp,LenHead),'AngleUncertainty',nan(tmp,LenHead),'Flag',nan(tmp,LenHead),'SNR',nan(tmp,LenHead),'Quality',nan(tmp,LenHead));
else error('gJsfRead3000: unknown/bad FormatRevisionLevel.');
end;
%===End Data Allocate for Message Type 3000
fseek(fId,0,'bof');df=0;
for m=1:LenHead,
    if ~mod(m,5000), disp(['Trace: ',num2str(m)]);end;
    %===Begin Data Read for Message Type 3000
    fseek(fId,JsfHead.RSeek(nHead(m))+80-df,'cof');
    switch Head.FormatRevisionLevel(m),
        case {0,1,2,3}
            error('gJsfRead3000: FormatRevisionLevel==0..3 is not defined.');
        case {4}
            for mm=1:Head.NumberBathymetricSampleType(m),
                Data.TimeDelay(mm,m)=fread(fId,1,'uint16').*Head.TimeScaleFactor(m); %0-1// Time Delay. See Time Scale Factor Bytes 48-51.
                Data.Angle(mm,m)=fread(fId,1,'int16').*Head.AngleScaleFactor(m); %2-3// Angle. See Angle Scale Factor Bytes 56-59.
                Data.Amplitude(mm,m)=fread(fId,1,'uint8'); %4// Amplitude, dB.
                %Amplitude is a fundamental attribute that is used to trim invalid data points from the final data set and primarily excludes weak echoes, such as the water column or very weak backscatter, based on some minimum threshold.
                %Typically good seafloor echoes are above 25 dB to 30 dB depending on bottom type; values less than 20 dB are typically not bottom echoes (i.e. noise).
                %The data points measured by the system can have an amplitude value between 0–127.5dB and is reported in 0.5dB increments.
                Data.AngleUncertainty(mm,m)=fread(fId,1,'uint8'); %5// Angle Uncertainty, Degrees, 2-sigma level.
                %The Angle Uncertainty Estimate is reported at the 2-sigma level and can vary between 0 and 5.1 degrees, reported in 0.02 degree increments. Any angle uncertainty larger than 5.1 degrees is clamped to 5.1 degrees.
                Data.Flag(mm,m)=fread(fId,1,'uint8'); %6// Flag.
                %These flags are used for data cleaning and if set to 1 indicate data which have been deemed as invalid points by the processing algorithm.                
                %NOTE: As of July 2014 the DISCOVER BATHYMETRIC Acquisition Software no longer supports the interferometric output, therefore bits 0 through 4 can be safely disregarded, unless parsing interferometric data is required.
                %NOTE: Bit 5, however, is essential to interpreting the binned data correctly (Binning Flag=1 or  2). If it is not, then there will be a false sounding reported at the sonar head’s location (0,0).
                %Bit0: Outlier Removal Flag – if set the processing algorithm deems these data points as having excessive deviations from the norm.
                %Bit1: Water Column Flag – if set the processing algorithm deems these data points as water column and are not used in determining the seafloor estimates.
                %Bit2: Amplitude – if set the processing algorithm deems these data points as invalid based on the calculated threshold. This fundamental attribute is used primarily to exclude weak  echo  points, such as the water column returns and very weak backscatter amplitudes.
                %Bit3: Quality – if set the processing algorithm deems these data points as invalid based on angle uncertainty. This filter is used to eliminate points whose phase differences are greater than some specified tolerance.
                %Bit4: SNR – if set the processing algorithm deems these data points as invalid based on the SNR. This filter is very useful in trimming data points where the angle estimation quality is low due to noise and multipath effects.
                %Bit5: Null Content Binned Data – if set the binned data contains null content and should be excluded from all processing (i.e. if the total across track extent is too large for the depth, then some bins may be empty and will be deemed as null). This bit is only valid when the data are binned. (See caution on following page.)
                %Bit6: Reserved;
                %Bit7: Reserved.
                tmp=fread(fId,1,'uint8'); %7// SNR and Quality bits.
                Data.SNR(mm,m)=bitand(tmp,31); %7// SNR, dB, bits 0-4.
                %Coherent SNR is a very useful statistic that is used to trim invalid data points where the angle noise is high  due  to  multipath  effects. When estimating the primary (largest  amplitude) angle of arrival the process also returns an estimate of the power in this angle.
                %This power is compared to the total power in the signal at that instant and so a coherent Signal (primary echo) to Noise (noise plus all multipath echoes) can be  estimated. In practice  the true noise component of this is very small over the useful range of the bathymetry data and is almost all due to multipath interference echoes.
                %SNR values greater than 20dB are excellent in terms of angle estimation quality, while less than 10dB are quite poor. Useful thresholds are between 10-20 dB, depending on the desire to have maximum swath (more noise) or lower noise and narrower swath widths.
                %This metric is described by a 5 bit value that ranges between 0 and 31dB in 1dB increments. Any value higher than 31dB is limited to 31dB.
                Data.Quality(mm,m)=bitshift(bitand(tmp,224),-5); %7// Quality, Percent, bits 5-7.
                %The EdgeTech Bathymetric Quality Factor is a metric used to identify how well the interstave phase measurements agree. The array used to determine the angles has 10 x ½ wavelength spaced elements. This allows the estimation of 9 interstave phase estimates.
                %In the most ideal case (no errors, no noise, no interfering multipath) these would all agree. In practice this is not the case and interstave phases may either agree quite well (+/- 5 – 10 degrees) or not at all (up to +/- 90 deg).
                %This metric is described by a 3 bit value and has been broken down into 8 discrete numbers associated with each:
                %0 is quality<50%; 1 is 50%<=quality<60%; 2 is 60%<=quality<70%; 3 is 70%<=quality<75%; 4 is 75%<=quality<80%; 5 is 80%<=quality<85%; 6 is 85%<=quality<90%; 7 is 90%<=quality.
                %NOTE: For most cases, any data with a Quality Factor less than 50% should be discarded. High quality data is considered to be anything above 70-80%. The quality factor can be set quite high (90%) in most cases, especially when the sea floor is very flat.
            end;
    end;
    %===End Data Read for Message Type 3000
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018