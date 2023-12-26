function Head=gXtf003Read(XtfHead,SubCh)
%Read Head from XtfHead.fName (*.xtf) file for Message Type 003 (XTFATTITUDEDATA structure - Attitude data packet); SubCh==0.
%function Head=gXtf003Read(XtfHead,SubCh), where
%XtfHead- Xtf Header structure;
%SubCh- sub channel number;
%Head- Header structure;
%Head include the next addition fields: Head.HSubChannelNumber, Head.HMessageNum.
%Example: Head=gXtf003Read(XtfHead,1);

[fId, mes]=fopen(XtfHead.fName,'r');if ~isempty(mes), error(['gXtfRead0003: ' mes]);end;
LHead=(XtfHead.RHeaderType==3)&(XtfHead.RSubChannelNumber==SubCh);;LenHead=sum(LHead);nHead=find(LHead);
%===Begin Header and ChanInfo Allocate
Head=struct('HMessageType',3,'HSubChannelNumber',0,'HMessageNum',nan(1,LenHead),'HReserved2',nan(2,LenHead),'HEpochMicroseconds',nan(1,LenHead),'HSourceEpoch',nan(1,LenHead),...
    'HPitch',nan(1,LenHead),'HRoll',nan(1,LenHead),'HHeave',nan(1,LenHead),'HYaw',nan(1,LenHead),'HTimeTag',nan(1,LenHead),'HHeading',nan(1,LenHead),...
    'HYear',nan(1,LenHead),'HMonth',nan(1,LenHead),'HDay',nan(1,LenHead),'HHour',nan(1,LenHead),'HMinutes',nan(1,LenHead),'HSeconds',nan(1,LenHead),'HMilliseconds',nan(1,LenHead),'HReserved3',nan(1,LenHead));
%===End Header and ChanInfo Allocate
df=0;fseek(fId,0,'bof');
for n=1:LenHead,
    fseek(fId,XtfHead.RSeek(nHead(n))-df,'cof');
    %===Begin Header Read
    Head.HMessageNum(n)=nHead(n);
    %face=fread(fId,1,'uint16');if face~=64206, error('Error gFXtfRead000: MagicNumber~=FACE');end;Head.HHeaderType(n)=fread(fId,1,'uint8');Head.HSubChannelNumber(n)=fread(fId,1,'uint8');Head.HNumChansToFollow(n)=fread(fId,1,'uint16');Head.HReserved1(:,n)=fread(fId,2,'uint16')';Head.HNumBytesThisRecord(n)=fread(fId,1,'uint32');
    Head.HReserved2(:,n)=fread(fId,2,'uint32'); %Unused. Set to 0
    Head.HEpochMicroseconds(n)=fread(fId,1,'uint32'); %0 -999999
    Head.HSourceEpoch(n)=fread(fId,1,'uint32'); %Source Epoch Seconds since 1/1/1970, will be followed attitude data even to 64 bytes.
    Head.HPitch(n)=fread(fId,1,'float32'); %Positive value is nose up
    Head.HRoll(n)=fread(fId,1,'float32'); %Positive value is roll to starboard
    Head.HHeave(n)=fread(fId,1,'float32'); %Positive value is sensor up. Isis Note: The TSS sends heave positive up. The MRU sends heave positive down. In order to make the data logging consistent, the sign of the MRU’s heave is reversed before being stored in this field.
    Head.HYaw(n)=fread(fId,1,'float32'); %Positive value is turn right
    Head.HTimeTag(n)=fread(fId,1,'uint32'); %System time reference in milliseconds
    Head.HHeading(n)=fread(fId,1,'float32'); %In degrees, as reported by MRU. TSS doesn't report heading, so when using a TSS this value will be the most recent ship gyro value as received from GPS or from any serial port using  'G' in the template.
    Head.HYear(n)=fread(fId,1,'uint16'); %Fix year
    Head.HMonth(n)=fread(fId,1,'uint8'); %Fix month
    Head.HDay(n)=fread(fId,1,'uint8'); %Fix day
    Head.HHour(n)=fread(fId,1,'uint8'); %Fix hour.
    Head.HMinutes(n)=fread(fId,1,'uint8'); %Fix minute.
    Head.HSeconds(n)=fread(fId,1,'uint8'); %Fix seconds.
    Head.HMilliseconds(n)=fread(fId,1,'uint16'); %(0 – 999). Fix milliseconds. 
    Head.HReserved3(n)=fread(fId,1,'uint8'); %Unused. Set to 0.
    %if ~mod(n,5000), disp(['Trace: ',num2str(n)]);end;
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 25/06/2022