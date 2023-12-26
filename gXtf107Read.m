function Head=gXtf107Read(XtfHead)
%Read Head from XtfHead.fName (*.xtf) file for Message Type 107 (XTF POSRAW NAVIGATION); SubCh==0; Size of this packet is always 64 bytes.
%function Head=gXtf107Read(XtfHead), where
%XtfHead- Xtf Header structure;
%Head- Header structure;
%Head include the next addition fields: Head.HSubChannelNumber, Head.HMessageNum.
%Example: Head=gXtf107Read(XtfHead);

[fId, mes]=fopen(XtfHead.fName,'r');if ~isempty(mes), error(['gXtfRead0107: ' mes]);end;
LHead=(XtfHead.RHeaderType==107);LenHead=sum(LHead);nHead=find(LHead);
if ~all(XtfHead.RSubChannelNumber(nHead)==0),warning('Not all XtfHead.RSubChannelNumber==0');end; if ~all(XtfHead.RNumChansToFollow(nHead)==0),warning('Not all XtfHead.RNumChansToFollow==0');end;
%===Begin Header and ChanInfo Allocate
Head=struct('HMessageType',0107,'HSubChannelNumber',0,'HMessageNum',nan(1,LenHead),'HYear',nan(1,LenHead),'HMonth',nan(1,LenHead),'HDay',nan(1,LenHead),'HHour',nan(1,LenHead),'HMinute',nan(1,LenHead),...
    'HSecond',nan(1,LenHead),'HMSeconds',nan(1,LenHead),'HRawYcoordinate',nan(1,LenHead),'HRawXcoordinate',nan(1,LenHead),'HRawAltitude',nan(1,LenHead),...
    'HPitch',nan(1,LenHead),'HRoll',nan(1,LenHead),'HHeave',nan(1,LenHead),'HHeading',nan(1,LenHead),'HReserved2',nan(1,LenHead));
%===End Header and ChanInfo Allocate
df=0;fseek(fId,0,'bof');
for n=1:LenHead,
    fseek(fId,XtfHead.RSeek(nHead(n))-df,'cof');
    %===Begin Header Read
    Head.HMessageNum(n)=nHead(n);
    %face=fread(fId,1,'uint16');if face~=64206, error('Error gFXtfRead000: MagicNumber~=FACE');end;Head.HHeaderType(n)=fread(fId,1,'uint8');Head.HSubChannelNumber(n)=fread(fId,1,'uint8');Head.HNumChansToFollow(n)=fread(fId,1,'uint16');Head.HReserved1(:,n)=fread(fId,2,'uint16')';Head.HNumBytesThisRecord(n)=fread(fId,1,'uint32');
    Head.HYear(n)=fread(fId,1,'uint16'); %Ping year
    Head.HMonth(n)=fread(fId,1,'uint8'); %Ping month
    Head.HDay(n)=fread(fId,1,'uint8'); %Ping day
    Head.HHour(n)=fread(fId,1,'uint8'); %Ping hour
    Head.HMinute(n)=fread(fId,1,'uint8'); %Ping minute
    Head.HSecond(n)=fread(fId,1,'uint16'); %WORD MicroSeconds (0 – 9999). Fix tenths of milliseconds.
    Head.HRawYcoordinate(n)=fread(fId,1,'float64'); %Raw position from POSRAW or other time stamped nav source.
    Head.HRawXcoordinate(n)=fread(fId,1,'float64'); %Raw position from POSRAW or other time stamped nav source.
    Head.HRawAltitude(n)=fread(fId,1,'float64'); %Altitude, can hold RTK altitude.
    Head.HPitch(n)=fread(fId,1,'float32'); %Positive value is nose up
    Head.HRoll(n)=fread(fId,1,'float32'); %Positive value is roll to starboard
    Head.HHeave(n)=fread(fId,1,'float32'); %Positive value is sensor up. Isis Note: The TSS sends heave positive up. The MRU sends heave positive down. In order to make the data logging consistent, the sign of the MRU’s heave is reversed before being stored in this field.
    Head.HHeading(n)=fread(fId,1,'float32'); %In degrees, as reported by MRU. TSS doesn’t report heading, so when using a TSS this value will be the most recent ship gyro value as received from GPS or from any serial port using ‘G’ in the template.
    Head.HReserved2(n)=fread(fId,1,'uint8'); %Unused.
    %if ~mod(n,5000), disp(['Trace: ',num2str(n)]);end;
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 25/06/2022