function gJsfHeaderWrite(JsfHead,fNameNew)
%Write JsfHead structure (16-Byte Message Header) to New *.jsf file (0004824_REV_1.20 used).
%function gJsfHeaderWrite(JsfHead,fNameNew), where
%JsfHead - structure with parent jsf-file description; 
%fNameNew - string, the target file for writing.
%gFJsfWriteHeader used file JsfHead.fName as data source. The file JsfHead.fName must be presented; names JsfHead.fName and fNameNew must be different.
%You can use JsfHead.ROnFlag to except any record from new Jsf-file.
%Example: gJsfHeaderWrite(JsfHead,'c:\temp\1new.xtf');

[fId, mes]=fopen(JsfHead.fName,'r+');if ~isempty(mes), error(['gFJsfWriteHeader: ' mes]);end;
if strcmp(fNameNew,JsfHead.fName), error('gFJsfWriteHeader: JsfHead.fName and fNameNew must be different.');end;
[fId2, mes]=fopen(fNameNew,'w');if ~isempty(mes), error(['gFJsfWriteHeader: ' mes]);end;
df=0;
for m=1:size(JsfHead.RSeek,2),
    if JsfHead.ROnFlag(m),
        %===Begin JsfHeader Record Write
        fwrite(fId2,JsfHead.HMarkerForStart(m),'uint16'); %0-1// Marker for the Start of Header = 0x1601
        fwrite(fId2,JsfHead.HVersionOfProtocol(m),'uint8'); %2// Version of Protocol used
        fwrite(fId2,JsfHead.HSessionIdentifier(m),'uint8'); %3// Session Identifier
        fwrite(fId2,JsfHead.HMessageType(m),'uint16'); %4-5// Message Type
        fwrite(fId2,JsfHead.HCommandType(m),'uint8'); %6// Command Type. 2=Normal data source.
        fwrite(fId2,JsfHead.HSubsystem(m),'uint8'); %7// Subsystem for a Multi-System Device. Common  subsystem assignments are as follows: Sub-bottom data - 0; Single frequency side scan data - 20; Lower frequency data of a dual frequency side scan - 20; Higher frequency data of a dual frequency side scan - 21; Higher frequency data of a tri-frequency side scan - 22; Raw serial/UDP/TCP data - 100 (v.1.20); Parsed serial/UDP/TCP data - 101 (v1.20); Raw UDP data - 103 (v.1.18);Parsed UPD data  - 104 (v1.18).
        fwrite(fId2,JsfHead.HChannelMulti(m),'uint8'); %8// Channel for a Multi-Channel Subsystem For Side Scan Subsystems; 0 = Port; 1 = Starboard; For Serial Ports: Port #. Single channel Sub-Bottom systems channel is 0.
        fwrite(fId2,JsfHead.HSequenceNumber(m),'uint8'); %9// Sequence Number
        fwrite(fId2,JsfHead.HReserved(m),'uint16'); %10-11// Reserved
        fwrite(fId2,JsfHead.HSizeFollowingMessage(m),'uint32'); %12-15// Size of following Message in Bytes
        %===End JsfHeader Record Write
        %===Begin DataBlock Write (DataBlock length from JsfHead.HSizeFollowingMessage, DataBlock begin from JsfHead.RSeek)
        fseek(fId,JsfHead.RSeek(m)-df,'cof');zz=fread(fId,JsfHead.HSizeFollowingMessage(m),'uint8')';df=ftell(fId);
        fwrite(fId2,zz,'uint8'); %Byte field
        %===End DataBlock Write
    end;
end;
fclose(fId2);
fclose(fId);

%mail@ge0mlib.com 19/03/2018