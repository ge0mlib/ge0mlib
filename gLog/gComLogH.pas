program gComLogH20200303; //Ge0MLib.com
uses windows,crt,dos,strings,dateutils,sysutils;
var     rootdir,inipath:string;iniext:string;f:text;              //config file
        fname,fPath:string;fPathP:PChar;fz:char;
        FileHandle,FileHandleNew:THandle;OverLap:Overlapped;Written,LastError:DWORD;FileFl:byte;
        SNcom,SNcom2:string;Ncom,Ncom2:PChar;
        ComBaud:longword;ComBytesize,ComParity,ComStopbits:byte; //com-port parameters
        dcbz,dcbz2:_DCB;TOPR:COMMTIMEOUTS;hcom1,hcom2:HANDLE;ret:longword;   //com-port var
        buf0,buf1:pointer;bufOld,buf:^char;BufSize,BufLim:longint;bufFl:byte;
        Y,Mo,Dda,Ddao,Dow:word;H,Ho,M,S,SS:qword;DTNow:TDateTime;
        Ltime,dLtime,Ltimeo,EOLtime:int64;SLtime:string;LenSLtime:word;PLtime:pointer;
        i,i1:integer;b:byte;
        fl:boolean;char1,key,EOLchar,c1,c2,z1,z2,z3,z4:char;
        t,tt:qword;tKey:char;

procedure GetSystemTimePreciseAsFileTime(var time:QWord); stdcall; external 'Kernel32.dll'; //100th of nanosecond from 1 January 1601 year

function LZero(w:qword):string;
  var s:string;
  begin str(w:0,s); if length(s)=1 then s:='0'+s; LZero:=s;end;

procedure DecodeTimeZ(DTNow:TDateTime;var H,M,S,SS:qword);
  var Hz,Mz,Sz,SSz:word;
  begin DecodeTime(DTNow,Hz,Mz,Sz,SSz);H:=qword(Hz);M:=qword(Mz);S:=qword(Sz);SS:=qword(SSz);end;

procedure HeadWrite;
  begin
    fl:=false;
    buf^:=c1;inc(buf);str(Ltime,SLtime);LenSLtime:=length(SLtime);
    for i:=LenSLtime to 11 do SLtime:='0'+SLtime;
    move(PLtime^,buf^,12);buf:=buf+12;buf^:=c2;inc(buf);write(c1,SLtime,c2);
  end;

procedure FWrite;
  begin
    if not GetOverlappedResult(FileHandle,OverLap,Written,True) then begin writeln('GetOverlappedResult Error=',GetLastError);halt(1);end;
    if FileFl=1 then begin CloseHandle(FileHandle); FileHandle:=FileHandleNew;FileFl:=0;end;
    if bufFl=0 then begin
      if not WriteFile(FileHandle,buf0^,buf-buf0,Written,@OverLap) then begin
        LastError:=GetLastError;if not(LastError=ERROR_IO_PENDING) then begin writeln('WriteFile Error=',GetLastError);halt(1);end;
      end;
      buf:=buf1;bufOld:=buf1;bufFl:=1;
    end
    else begin
      if not WriteFile(FileHandle,buf1^,buf-buf1,Written,@OverLap) then begin
        LastError:=GetLastError;if not(LastError=ERROR_IO_PENDING) then begin writeln('WriteFile Error=',GetLastError);halt(1);end;
      end;
      buf:=buf0;bufOld:=buf0;bufFl:=0;
    end;
  end;

//================================================
begin
  clrscr;writeln('---gComLogH20200303//Ge0MLib.com---');
  //open config file from current dir
  rootdir:=paramstr(0);b:=length(rootdir)+1;repeat b:=b-1;until (b=0)or(rootdir[b]='\');
  if b=0 then begin WriteLn('Path to program incorrect');ReadKey;exit;end;
  rootdir[0]:=char(b);writeln('Path to work folder: ',rootdir);
  inipath:=paramstr(0);b:=length(inipath)+1;repeat b:=b-1;until (b=0)or(inipath[b]='.');
  if b=0 then begin WriteLn('Path to program incorrect');ReadKey;exit;end;
  inipath[0]:=char(b);inipath:=inipath+'ini';writeln('Expect ini-file name: ',inipath);
  assign(f,inipath);reset(f);
  //read configuration -- com number
  readln(f,SNcom);Ncom:=stralloc(16);strpcopy(Ncom,SNcom);writeln('Read: COM Name=',SNcom);
  readln(f,SNcom2);
  if SNcom2[1]='\' then begin Ncom2:=stralloc(16);strpcopy(Ncom2,SNcom2);writeln('Read: COM_Out Name=',SNcom2);end
  else writeln('Read: COM_Out is not used');
  //read configuration -- com baud, parity, stopbits
  readln(f,ComBaud,ComBytesize,ComParity,ComStopbits);writeln('Read: BaudRate=',ComBaud,'; ByteSize=',ComBytesize,'; Parity=',ComParity,'; StopBits=',ComStopbits);
  //read end of line symbol and time out
  readln(f,b,EOLtime);EOLchar:=char(b);writeln('Read: EOL code=',b,'; EOL time=',EOLtime,'ms');
  //read BufSize
  readln(f,BufSize);writeln('Read: BufferSize=',BufSize,'byte');
  //read extension for log
  readln(f,iniext);writeln('Read: log files extension=',iniext);
  //read auto-break code for file
  readln(f,fz);writeln('Read: autobreak code=',fz);
  //read delimiters
  readln(f,c1,c2);writeln('Read: LeftDelim=''',c1,'''; RightDelim=''',c2,'''');
  //read DTR,RTS
  readln(f,z1,z2,z3,z4);writeln('Read: DTR1=''',z1,'''; RTS1=''',z2,'''','DTR2=''',z3,'''; RTS2=''',z4,'''');
  //read TimeKey: if 'P' than set high-precision mode
  readln(f,tKey);if tKey='P' then writeln('Read: TimeKey >> set the high-precision mode');
  close(f);
  //set variables
  PLTime:=addr(SLtime[1]);
  getmem(buf0,BufSize+16);getmem(buf1,BufSize+16);buf:=buf0;bufOld:=buf0;bufFl:=0;
  //open port
  hcom1:=CreateFile(Ncom,GENERIC_READ,0,nil,OPEN_EXISTING,0,0);
  if (hcom1=INVALID_HANDLE_VALUE) then begin writeln('Error: can not open Com');writeln('Press any key for Exit');ReadKey;exit;end;
  if SNcom2[1]='\' then begin
    hcom2:=CreateFile(Ncom2,GENERIC_WRITE,0,nil,OPEN_EXISTING,0,0);
    if (hcom2=INVALID_HANDLE_VALUE) then begin writeln('Error: can not open Com_Out');writeln('Press any key for Exit');ReadKey;exit;end;
  end;
  //set TDCB
  GetCommState(hcom1,dcbz);dcbz.BaudRate:=ComBaud;dcbz.ByteSize:=ComBytesize;dcbz.Parity:=ComParity;dcbz.StopBits:=ComStopbits;SetCommState(hcom1,dcbz);
  GetCommState(hcom1,dcbz);WriteLn('Configed: BaudRate=',dcbz.BaudRate,'; ByteSize=',dcbz.ByteSize,'; Parity=',dcbz.Parity,'; StopBits=',dcbz.StopBits);
  if ((z1='1')or(z1='0'))and((z2='1')or(z2='0')) then dcbz.Flags:=(dcbz.Flags And $FFFFC0FF) Or $00000100; //manage RTS
  if z1='1' then EscapeCommFunction(hcom1,SETRTS);if z1='0' then EscapeCommFunction(hcom1,CLRRTS);
  if z2='1' then EscapeCommFunction(hcom1,SETDTR);if z2='0' then EscapeCommFunction(hcom1,CLRDTR);
  if not(SetCommState(hcom1,dcbz)) then begin writeln('Error: can not config Com');writeln('Press any key for Exit');ReadKey;exit;end;
  if SNcom2[1]='\' then begin
    GetCommState(hcom2,dcbz2);dcbz2.BaudRate:=ComBaud;dcbz2.ByteSize:=ComBytesize;dcbz2.Parity:=ComParity;dcbz2.StopBits:=ComStopbits;SetCommState(hcom2,dcbz2);
    GetCommState(hcom2,dcbz2);WriteLn('Configed2: BaudRate=',dcbz2.BaudRate,'; ByteSize=',dcbz2.ByteSize,'; Parity=',dcbz2.Parity,'; StopBits=',dcbz2.StopBits);
    if ((z3='1')or(z3='0'))and((z4='1')or(z4='0')) then dcbz2.Flags:=(dcbz2.Flags And $FFFFC0FF) Or $00000100; //manage RTS
    if z3='1' then EscapeCommFunction(hcom2,SETRTS);if z3='0' then EscapeCommFunction(hcom2,CLRRTS);
    if z4='1' then EscapeCommFunction(hcom2,SETDTR);if z4='0' then EscapeCommFunction(hcom2,CLRDTR);
    if not(SetCommState(hcom2,dcbz2)) then begin writeln('Error: can not config Com2');writeln('Press any key for Exit');ReadKey;exit;end;
  end;
  //set CommTimeouts
  TOPR.ReadIntervalTimeout:=0;TOPR.ReadTotalTimeoutMultiplier:=0;TOPR.ReadTotalTimeoutConstant:=1000;
  if not(SetCommTimeouts(hcom1,TOPR)) then begin writeln('Error: can not set Com TimeOuts');writeln('Press any key for Exit');ReadKey;exit;end;
  GetCommTimeouts(hcom1,TOPR);writeln('TimeOuts: ReadInterv=',TOPR.ReadIntervalTimeout,'ms; ReadTotalMulti=',TOPR.ReadTotalTimeoutMultiplier,'ms; ReadTotalConst=',TOPR.ReadTotalTimeoutConstant,'ms');
  writeln('=================');writeln('ESC -- Hard Exit.');writeln('Q   -- Soft Exit (EOL symbol wailing).');writeln('C   -- New log-file.');writeln('...data waiting.');
  PurgeComm(hcom1,PURGE_TXCLEAR or PURGE_RXCLEAR); //clear buffers
  if SNcom2[1]='\' then PurgeComm(hcom2,PURGE_TXCLEAR or PURGE_RXCLEAR); //clear buffers
  //overlap
  ZeroMemory(@OverLap,sizeof(OverLap));Overlap.hEvent:=CreateEvent(nil,True,False,nil);ResetEvent(OverLap.hEvent);OverLap.Offset:=$FFFFFFFF;OverLap.OffsetHigh:=$FFFFFFFF; //0xFFFFFFFF==4294967295
  //variables for main sycle
  if tKey='P' then begin GetSystemTimePreciseAsFileTime(t);DecodeDate(TDateTime((t div 864000000000)-109205),Y,Mo,Dda);
    tt:=t mod 864000000000;H:=tt div(36000000000);M:=(tt-H*36000000000)div(600000000);S:=(tt-H*36000000000-M*600000000)div(10000000);SS:=(tt-H*36000000000-M*600000000-S*10000000);end
  else begin DTNow:=Now;DecodeDate(DTNow,Y,Mo,Dda);DecodeTimeZ(DTNow,H,M,S,SS);SS:=SS*10000;end;
  Ho:=H;Ddao:=Dda; //"old" date-time and values for filename
  fname:=lzero(Y)+lzero(Mo)+lzero(Dda)+'_'+lzero(H)+lzero(M)+lzero(S)+iniext;
  FileFl:=0;fPath:=rootdir+fname;fPathP:=stralloc(byte(fPath[0])+1);strpcopy(fPathP,fPath);FileHandle:=CreateFile(fPathP,GENERIC_WRITE,0,nil,OPEN_ALWAYS,FILE_FLAG_OVERLAPPED,0);
  Ltimeo:=H*36000000000+M*600000000+S*10000000+SS*10000;key:=#0;fl:=true;
  delay(50);
//===============================================
  repeat
    ReadFile(hcom1,char1,1,ret,nil);
    if KeyPressed then key:=ReadKey;
    if ret<>0 then begin
      if tKey='P' then begin // >>>> get time in 100th of nanosecond from 1 January 1601 year
        GetSystemTimePreciseAsFileTime(t);
        if SNcom2[1]='\' then WriteFile(hcom2,char1,1,ret,nil); //send byte to ComOut
        DecodeDate(TDateTime((t div 864000000000)-109205),Y,Mo,Dda);
        tt:=t mod 864000000000;
        H:=tt div(36000000000);M:=(tt-H*36000000000)div(600000000);S:=(tt-H*36000000000-M*600000000)div(10000000);SS:=(tt-H*36000000000-M*600000000-S*10000000);
      end
      else begin // >>>> get time millisecond from 30 December 1899 year
        DTNow:=Now;
        if SNcom2[1]='\' then WriteFile(hcom2,char1,1,ret,nil); //send byte to ComOut
        DecodeDate(DTNow,Y,Mo,Dda);DecodeTimeZ(DTNow,H,M,S,SS);SS:=SS*10000;
      end;
      //if long time last byte take, then prepare to move Head to buffer
      Ltime:=H*36000000000+M*600000000+S*10000000+SS;
      if (H=0)and(Ho=23) then dLtime:=Ltime+36000000000-Ltimeo else dLtime:=Ltime-Ltimeo;
      Ltimeo:=Ltime;
      //if EOL symbol and (new hour&H or new day&D) then move buffer to file, clear buffer, create new file
      if ((fl)or(dLtime>EOLtime))and(((H<>Ho)and(fz='H'))or((Dda<>Ddao)and(fz='D'))) then begin
        Ho:=H;Ddao:=Dda;fname:=lzero(Y)+lzero(Mo)+lzero(Dda)+'_'+lzero(H)+lzero(M)+lzero(S)+iniext;
        FWrite;FileFl:=1;fPath:=rootdir+fname;strpcopy(fPathP,fPath);FileHandleNew:=CreateFile(fPathP,GENERIC_WRITE,0,nil,OPEN_ALWAYS,FILE_FLAG_OVERLAPPED,0);
      end;
      //move Head to buffer (long time last byte take)
      if (dLtime>EOLtime)or(fl) then HeadWrite;
      //load char1 to buffer. if EOL symbol then set flag
      buf^:=char1;inc(buf);write(char1);
      if char1=EOLchar then fl:=true;
      //if buffer size>1024 then move buffer to file and clear buffer
      if ((bufFl=0)and((buf-buf0)>=BufSize))or((bufFl=1)and((buf-buf1)>=BufSize)) then FWrite;
    end;
    //if pressed 'C' and last char==EOL, then create new file
    if (key='C')and(fl) then begin
      key:=#0;Ho:=H;Ddao:=Dda;fname:=lzero(Y)+lzero(Mo)+lzero(Dda)+'_'+lzero(H)+lzero(M)+lzero(S)+iniext;
      FWrite;FileFl:=1;fPath:=rootdir+fname;strpcopy(fPathP,fPath);FileHandleNew:=CreateFile(fPathP,GENERIC_WRITE,0,nil,OPEN_ALWAYS,FILE_FLAG_OVERLAPPED,0);
    end;
  until (key=#27)or((key='Q')and(fl));
  FWrite;
  while WaitForSingleObject(Overlap.hEvent,1000)=WAIT_TIMEOUT do writeln('wait 1000ms');
  CloseHandle(FileHandle);CloseHandle(OverLap.hEvent);
  PurgeComm(HANDLE(hcom1),PURGE_TXCLEAR or PURGE_RXCLEAR);CloseHandle(hcom1);
  if SNcom2[1]='\' then begin PurgeComm(HANDLE(hcom2),PURGE_TXCLEAR or PURGE_RXCLEAR);CloseHandle(hcom2);end;
end.