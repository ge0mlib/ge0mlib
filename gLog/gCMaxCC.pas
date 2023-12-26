program gCMaxCC20161004; //Ge0MLib.com
uses    windows,crt,strings;
var     rootdir,inipath:string;f:text;              //config file
        SNcom:string;Ncom0,Ncom:PChar;
        ComBaud:longword;ComBytesize,ComParity,ComStopbits:byte; //com-port parameters
        dcbz:_DCB;TOPR:COMMTIMEOUTS;hcom0,hcom1:HANDLE;ret:longword;   //com-port var
        b:byte;
        char1,key,zzz1,zzz2:char;
        Initz,InitCCS,InitCC:string;

begin
  clrscr;writeln('---gCMaxCC20161004//Ge0MLib.com---');
  //open config file from current dir
  rootdir:=paramstr(0);b:=length(rootdir)+1;repeat b:=b-1;until (b=0)or(rootdir[b]='\');
  if b=0 then begin WriteLn('Path to program incorrect');ReadKey;exit;end;
  rootdir[0]:=char(b);writeln('Path to work folder: ',rootdir);
  inipath:=paramstr(0);b:=length(inipath)+1;repeat b:=b-1;until (b=0)or(inipath[b]='.');
  if b=0 then begin WriteLn('Path to program incorrect');ReadKey;exit;end;
  inipath[0]:=char(b);inipath:=inipath+'ini';writeln('Expect ini-file name: ',inipath);
  assign(f,inipath);reset(f);
  //read configuration -- com number for CC
  readln(f,SNcom);Ncom0:=stralloc(16);strpcopy(Ncom0,SNcom);writeln('Read CC: COM Name=',SNcom);
  readln(f,InitCCS);writeln('Read CC: Init CC string=',InitCCS);
  readln(f,InitCC);writeln('Read CC: Init CC value=',InitCC);
  //read configuration -- com number for Relay
  readln(f,SNcom);Ncom:=stralloc(16);strpcopy(Ncom,SNcom);writeln('Read Relay: COM Name=',SNcom);
  //read configuration -- com baud, parity, stopbits
  readln(f,ComBaud,ComBytesize,ComParity,ComStopbits);writeln('Read Relay: BaudRate=',ComBaud,'; ByteSize=',ComBytesize,'; Parity=',ComParity,'; StopBits=',ComStopbits);
   //read DTR,RTS
  readln(f,zzz1,zzz2);writeln('Read Relay: DTR=''',zzz1,'''; RTS=''',zzz2,'''');
  close(f);

  //open port for CC
  hcom0:=CreateFile(Ncom0,GENERIC_READ or GENERIC_WRITE,0,nil,OPEN_EXISTING,0,0);
  if (hcom0=INVALID_HANDLE_VALUE) then begin writeln('Error: can not open CC Com');writeln('Press any key for Exit');ReadKey;exit;end;
  //set TDCB
  GetCommState(hcom0,dcbz);dcbz.BaudRate:=4800;dcbz.ByteSize:=8;dcbz.Parity:=0;dcbz.StopBits:=0;
  dcbz.Flags:=(dcbz.Flags And $FFFFC0FF) Or $00000100; //manage RTS
  if not(SetCommState(hcom0,dcbz)) then begin writeln('Error: can not config CC Com');writeln('Press any key for Exit');ReadKey;exit;end;
  EscapeCommFunction(hcom0,SETRTS);EscapeCommFunction(hcom0,SETDTR);
  GetCommState(hcom0,dcbz);WriteLn('Configed CC: BaudRate=',dcbz.BaudRate,'; ByteSize=',dcbz.ByteSize,'; Parity=',dcbz.Parity,'; StopBits=',dcbz.StopBits);
  //set CommTimeouts
  TOPR.ReadIntervalTimeout:=0;TOPR.ReadTotalTimeoutMultiplier:=0;TOPR.ReadTotalTimeoutConstant:=1000;
  if not(SetCommTimeouts(hcom0,TOPR)) then begin writeln('Error: can not set CC Com TimeOuts');writeln('Press any key for Exit');ReadKey;exit;end;
  PurgeComm(hcom0,PURGE_TXCLEAR or PURGE_RXCLEAR); //clear buffers

  //open port for Relay
  hcom1:=CreateFile(Ncom,GENERIC_READ or GENERIC_WRITE,0,nil,OPEN_EXISTING,0,0);
  if (hcom1=INVALID_HANDLE_VALUE) then begin writeln('Error: can not open Com');writeln('Press any key for Exit');ReadKey;exit;end;
  //set TDCB
  GetCommState(hcom1,dcbz);dcbz.BaudRate:=ComBaud;dcbz.ByteSize:=ComBytesize;dcbz.Parity:=ComParity;dcbz.StopBits:=ComStopbits;
  if ((zzz1='1')or(zzz1='0'))and((zzz2='1')or(zzz2='0')) then dcbz.Flags:=(dcbz.Flags And $FFFFC0FF) Or $00000100; //manage RTS
  if not(SetCommState(hcom1,dcbz)) then begin writeln('Error: can not config Com');writeln('Press any key for Exit');ReadKey;exit;end;
  if zzz1='1' then EscapeCommFunction(hcom1,SETRTS);if zzz1='0' then EscapeCommFunction(hcom1,CLRRTS);
  if zzz2='1' then EscapeCommFunction(hcom1,SETDTR);if zzz2='0' then EscapeCommFunction(hcom1,CLRDTR);
  GetCommState(hcom1,dcbz);WriteLn('Configed Relay: BaudRate=',dcbz.BaudRate,'; ByteSize=',dcbz.ByteSize,'; Parity=',dcbz.Parity,'; StopBits=',dcbz.StopBits);
  //set CommTimeouts
  TOPR.ReadIntervalTimeout:=0;TOPR.ReadTotalTimeoutMultiplier:=0;TOPR.ReadTotalTimeoutConstant:=1000;
  if not(SetCommTimeouts(hcom1,TOPR)) then begin writeln('Error: can not set Com TimeOuts');writeln('Press any key for Exit');ReadKey;exit;end;
  GetCommTimeouts(hcom1,TOPR);writeln('TimeOuts: ReadInterv=',TOPR.ReadIntervalTimeout,'ms; ReadTotalMulti=',TOPR.ReadTotalTimeoutMultiplier,'ms; ReadTotalConst=',TOPR.ReadTotalTimeoutConstant,'ms');
  writeln('=================');writeln('ESC -- Exit.');writeln('=================');
  PurgeComm(hcom1,PURGE_TXCLEAR or PURGE_RXCLEAR); //clear buffers

  //CC init
  delay(300);
  for b:=1 to byte(InitCCS[0]) do begin WriteFile(hcom0,InitCCS[b],1,ret,nil);write(InitCCS[b]);delay(50);end;writeln;
  for b:=1 to byte(InitCC[0]) do begin WriteFile(hcom0,InitCC[b],1,ret,nil);write(InitCC[b]);delay(50);end;writeln;
  //Initz:=InitCC+char(13);WriteFile(hcom0,Initz[1],longword(Initz[0]),ret,nil);delay(200);
  Initz:='T';WriteFile(hcom0,Initz[1],longword(Initz[0]),ret,nil);
  //main sycle
  repeat
    if KeyPressed then key:=ReadKey;
    ReadFile(hcom0,char1,1,ret,nil);
    if ret<>0 then begin WriteFile(hcom1,char1,1,ret,nil);write(char1);end;
  until (key=#27)or(key='Q');
  PurgeComm(HANDLE(hcom0),PURGE_TXCLEAR or PURGE_RXCLEAR);CloseHandle(hcom0);
  PurgeComm(HANDLE(hcom1),PURGE_TXCLEAR or PURGE_RXCLEAR);CloseHandle(hcom1);
end.
