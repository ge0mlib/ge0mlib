function gXtfFilesAppend(fNameNew,varargin)
%Append Xtf files in order, using Header data.
%function gXtfFilesAppend(fNameNew,varargin), where
%fNameNew- file name for appending result;
%varargin{1..N}- file names will be appended.
%The XTFFILEHEADER Structure and CHANINFO Structure get from file varargin{1}. It must be equal for all appending files.
%ShortHeader structures and Data Blocks appended from all files.
%Example: gXtfFilesAppend('c:\temp\App.xtf','c:\temp\1.xtf','c:\temp\2.xtf','c:\temp\3.xtf');

XtfHead=gXtfHeaderRead(varargin{1},0);

[fId2, mes]=fopen(fNameNew,'w');if ~isempty(mes), error(['gFXtfWriteHeader: ' mes]);end;
%===Begin XTFFILEHEADER Structure Write
fwrite(fId2,XtfHead.HFileFormat,'uint8'); %Set to 123 (0x7B)
fwrite(fId2,XtfHead.HSystemType,'uint8');%Set to 1
fwrite(fId2,XtfHead.HRecordingProgramName,'char*1'); %Example: "Isis
fwrite(fId2,XtfHead.HRecordingProgramVersion,'char*1'); %Example: "556" for version 5.56
fwrite(fId2,XtfHead.HSonarName,'char*1'); %Name of server used to access sonar.  Example: "C31_SERV.EXE"
fwrite(fId2,XtfHead.HSonarType,'uint16'); %
fwrite(fId2,XtfHead.HNoteString,'char*1'); %Notes as entered in the Sonar Setup dialog box
fwrite(fId2,XtfHead.HThisFileName,'char*1'); %Name of this file. Example:"LINE12-B.XTF"
fwrite(fId2,XtfHead.HNavUnits,'uint16'); %0=Meters (i.e., UTM) or 3=Lat/Long
fwrite(fId2,XtfHead.HNumberOfSonarChannels,'uint16'); %if > 6, header grows to 2K in size
fwrite(fId2,XtfHead.HNumberOfBathymetryChannels,'uint16'); %
fwrite(fId2,XtfHead.HNumberOfSnippetChannels,'uint8'); %
fwrite(fId2,XtfHead.HNumberOfForwardLookArrays,'uint8'); %
fwrite(fId2,XtfHead.HNumberOfEchoStrengthChannels,'uint16'); %
fwrite(fId2,XtfHead.HNumberOfInterferometryChannels,'uint8'); %
fwrite(fId2,XtfHead.HReserved1,'uint8'); %Reserved. Set to 0.
fwrite(fId2,XtfHead.HReserved2,'uint16'); %Reserved. Set to 0.
fwrite(fId2,XtfHead.HReferencePointHeigh,'float32'); %Height of reference point above water line (m)
fwrite(fId2,XtfHead.HProjectionType,'char*1'); %Navigation System Parameters. Not currently used. Set to 0.
fwrite(fId2,XtfHead.HSpheriodType,'char*1'); %Navigation System Parameters. Not currently used. Set to 0.
fwrite(fId2,XtfHead.HNavigationLatency,'int32'); %Navigation System Parameters. Latency of nav system in milliseconds. (Usually GPS). ISIS Note: This value is entered on the Serial port setup dialog box.  When computing a position, Isis will take the time of the navigation and subtract this value.
fwrite(fId2,XtfHead.HOriginY,'float32'); %Navigation System Parameters. Not currently used. Set to 0
fwrite(fId2,XtfHead.HOriginX,'float32'); %Navigation System Parameters. Not currently used. Set to 0
fwrite(fId2,XtfHead.HNavOffsetY,'float32'); %Navigation System Parameters. Orientation of positive Y is forward. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HNavOffsetX,'float32'); %Navigation System Parameters. Orientation of positive X is to starboard. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HNavOffsetZ,'float32'); %Navigation System Parameters. Orientation of positive Z is down.  Just like depth. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HNavOffsetYaw,'float32'); %Navigation System Parameters. Orientation of positive yaw is turn to right. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HMRUOffsetY,'float32'); %Navigation System Parameters. Orientation of positive Y is forward. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HMRUOffsetX,'float32'); %Navigation System Parameters. Orientation of positive X is to starboard. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HMRUOffsetZ,'float32'); %Navigation System Parameters. Orientation of positive Z is down.  Just like depth. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HMRUOffsetYaw,'float32'); %Navigation System Parameters. Orientation of positive yaw is turn to right. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HMRUOffsetPitch,'float32'); %Navigation System Parameters. Orientation of positive pitch is nose up. ISIS Note: This offset is entered in the Multibeam setup dialog box. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HMRUOffsetRoll,'float32'); %Navigation System Parameters. Orientation of positive roll is lean to starboard. ISIS Note: This offset is entered in the Multibeam setup dialog box
nChanel=XtfHead.HNumberOfSonarChannels+XtfHead.HNumberOfBathymetryChannels+XtfHead.HNumberOfSnippetChannels+XtfHead.HNumberOfForwardLookArrays+XtfHead.HNumberOfEchoStrengthChannels+XtfHead.HNumberOfInterferometryChannels;
%===End XTFFILEHEADER Structure Write
for m=1:nChanel,
    %===Begin CHANINFO Structure Write
    fwrite(fId2,XtfHead.CTypeOfChannel(m),'uint8'); %SUBBOTTOM=0, PORT=1, STBD=2, BATHYMETRY=3
    fwrite(fId2,XtfHead.CSubChannelNumber(m),'uint8'); %Index for which CHANINFO structure this is
    fwrite(fId2,XtfHead.CCorrectionFlags(m),'uint16'); %1=sonar imagery stored as slant-range, 2=sonar imagery stored as ground range (corrected)
    fwrite(fId2,XtfHead.CUniPolar(m),'uint16'); %0=data is polar, 1=data is unipolar
    fwrite(fId2,XtfHead.CBytesPerSample(m),'uint16'); %1 (8-bit data) or 2 (16-bit data) or 4 (32-bit)
    fwrite(fId2,XtfHead.CReserved(m),'uint32'); %Isis Note: Previously this was SamplesPerChannel.  Isis now supports the recording of every sample per ping, which means that number of samples per channel can vary from ping to ping if the range scale changes.  Because of this, the NumSamples value in the XTFPINGCHANHEADER structure (defined in Section 3.18) holds the number of samples to read for a given channel. For standard analog systems, this Reserved value is still filled in with 1024, 2048 or whatever the initial value is for SamplesPerChannel.
    fwrite(fId2,XtfHead.CChannelName(:,m),'char*1'); %Text describing channel.  i.e., "Port 500"
    fwrite(fId2,XtfHead.CVoltScale(m),'float32'); %This states how many volts are represented by a maximum sample value in the range  [-5.0 to +4.9998] volts. Default is 5.0.
    fwrite(fId2,XtfHead.CFrequency(m),'float32'); %Center transmit frequency
    fwrite(fId2,XtfHead.CHorizBeamAngle(m),'float32'); %Typically 1 degree or so
    fwrite(fId2,XtfHead.CTiltAngle(m),'float32'); %Typically 30 degrees
    fwrite(fId2,XtfHead.CBeamWidth(m),'float32'); %3dB beam width, Typically 50 degrees
    fwrite(fId2,XtfHead.COffsetX(m),'float32'); %Orientation of positive X is to starboard. Note: This offset is entered in the Multibeam setup dialog box
    fwrite(fId2,XtfHead.COffsetY(m),'float32'); %Orientation of positive Y is forward. Note: This offset is entered in the Multibeam setup dialog box
    fwrite(fId2,XtfHead.COffsetZ(m),'float32'); %Orientation of positive Z is down.  Just like depth. Note: This offset is entered in the Multibeam setup dialog box
    fwrite(fId2,XtfHead.COffsetYaw(m),'float32'); %Orientation of positive yaw is turn to right. If the multibeam sensor is reverse mounted (facing backwards), then OffsetYaw will be around 180 degrees. Note: This offset is entered in the Multibeam setup dialog box
    fwrite(fId2,XtfHead.COffsetPitch(m),'float32'); %Orientation of positive pitch is nose up. Note: This offset is entered in the Multibeam setup dialog box
    fwrite(fId2,XtfHead.COffsetRoll(m),'float32'); %Orientation of positive roll is lean to starboard. Note: This offset is entered in the Multibeam setup dialog box
    fwrite(fId2,XtfHead.CBeamsPerArray(m),'uint16'); %For forward look only (i.e., Sonatech DDS)
    fwrite(fId2,XtfHead.CReservedArea2(:,m),'char*1'); %Unused Set value to 0
    %===End CHANINFO Structure Write
end;
z=zeros(1024-mod(ftell(fId2),1024),1);fwrite(fId2,z,'uint8'); %0 to 1024*n

for nn=1:length(varargin),
    XtfHead=gXtfHeaderRead(varargin{nn},0);
    [fId, mes]=fopen(XtfHead.fName,'r+');if ~isempty(mes), error(['gFXtfWriteHeader: ' mes]);end;
    if strcmp(fNameNew,XtfHead.fName), error('gFXtfWriteHeader: XtfHead.fName and fNameNew must be different.');end;

    df=0;fseek(fId,0,'bof');
    for m=1:size(XtfHead.RHeaderType,2),
        if XtfHead.ROnFlag(m),
            %===Begin ShortHeader structure Write
            fwrite(fId2,XtfHead.RFace,'uint16'); %FACE
            fwrite(fId2,XtfHead.RHeaderType(m),'uint8'); %HeaderType
            fwrite(fId2,XtfHead.RSubChannelNumber(m),'uint8'); %SubChannelNumber
            fwrite(fId2,XtfHead.RNumChansToFollow(m),'uint16'); %NumChansToFollow
            fwrite(fId2,XtfHead.RUnused(m),'uint32'); %Unused. Set to 0
            fwrite(fId2,XtfHead.RNumBytesThisRecord(m),'uint32'); %NumBytesThisRecord
            %===End ShortHeader structure Write
            %===Begin DataBlock Write
            fseek(fId,XtfHead.RSeek(m)-df,'cof');
            zz=fread(fId,XtfHead.RNumBytesThisRecord(m)-14,'uint8')';df=ftell(fId);
            fwrite(fId2,zz,'uint8'); %Byte field
            %===End DataBlock Write
        end;
    end;
    fclose(fId);
end;
fclose(fId2);

%mail@ge0mlib.com 01/08/2016