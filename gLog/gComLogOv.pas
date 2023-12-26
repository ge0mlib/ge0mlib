program gComLogOv20190731; //Ge0MLib.com
uses windows,crt,dos,strings,dateutils,sysutils;
var     rootdir,inipath:string;iniext:string;f:text;              //config file
        fname,fPath:string;fPathP:PChar;fz:char;
        FileHandle,FileHandleNew:THandle;OverLap:Overlapped;Written,LastError:DWORD;FileFl:byte;
        SNcom:string;Ncom:PChar;
        ComBaud:longword;ComBytesize,ComParity,ComStopbits:byte; //com-port parameters
        dcbz:_DCB;TOPR:COMMTIMEOUTS;hcom1:HANDLE;ret:longword;   //com-port var
        buf0,buf1:pointer;bufOld,buf:^char;BufSize,BufLim:longint;bufFl:byte;
        Y,Mo,Dda,Ddao,Dow,H,Ho,M,S,SS,EOLtime:word;DTNow:TDateTime;
        Ltime,dLtime,Ltimeo:longint;SLtime:string;LenSLtime:word;PLtime:pointer;
        i,i1:integer;b:byte;
        fl:boolean;char1,key,EOLchar,c1,c2,zzz1,zzz2:char;

function LZero(w:word):string;
  var s:string;
  begin str(w:0,s); if length(s)=1 then s:='0'+s; LZero:=s;end;

procedure HeadWrite;
  begin
    fl:=false;
    buf^:=c1;inc(buf);str(Ltime,SLtime);LenSLtime:=length(SLtime);
    for i:=LenSLtime to 7 do SLtime:='0'+SLtime;
    move(PLtime^,buf^,8);buf:=buf+8;buf^:=c2;inc(buf);
    write(c1,SLtime,c2);
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


begin
  clrscr;writeln('---gComLogOvOut20190731//Ge0MLib.com---');
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
  readln(f,zzz1,zzz2);writeln('Read: DTR=''',zzz1,'''; RTS=''',zzz2,'''');
  close(f);
  //set variables
  PLTime:=addr(SLtime[1]);
  getmem(buf0,BufSize+16);getmem(buf1,BufSize+16);buf:=buf0;bufOld:=buf0;bufFl:=0;
  //open port
  hcom1:=CreateFile(Ncom,GENERIC_READ,0,nil,OPEN_EXISTING,0,0);
  if (hcom1=INVALID_HANDLE_VALUE) then begin writeln('Error: can not open Com');writeln('Press any key for Exit');ReadKey;exit;end;
  //set TDCB
  GetCommState(hcom1,dcbz);dcbz.BaudRate:=ComBaud;dcbz.ByteSize:=ComBytesize;dcbz.Parity:=ComParity;dcbz.StopBits:=ComStopbits;
  if ((zzz1='1')or(zzz1='0'))and((zzz2='1')or(zzz2='0')) then dcbz.Flags:=(dcbz.Flags And $FFFFC0FF) Or $00000100; //manage RTS
  if not(SetCommState(hcom1,dcbz)) then begin writeln('Error: can not config Com');writeln('Press any key for Exit');ReadKey;exit;end;
  if zzz1='1' then EscapeCommFunction(hcom1,SETRTS);if zzz1='0' then EscapeCommFunction(hcom1,CLRRTS);
  if zzz2='1' then EscapeCommFunction(hcom1,SETDTR);if zzz2='0' then EscapeCommFunction(hcom1,CLRDTR);
  GetCommState(hcom1,dcbz);WriteLn('Configed: BaudRate=',dcbz.BaudRate,'; ByteSize=',dcbz.ByteSize,'; Parity=',dcbz.Parity,'; StopBits=',dcbz.StopBits);
  //set CommTimeouts
  TOPR.ReadIntervalTimeout:=0;TOPR.ReadTotalTimeoutMultiplier:=0;TOPR.ReadTotalTimeoutConstant:=1000;
  if not(SetCommTimeouts(hcom1,TOPR)) then begin writeln('Error: can not set Com TimeOuts');writeln('Press any key for Exit');ReadKey;exit;end;
  GetCommTimeouts(hcom1,TOPR);writeln('TimeOuts: ReadInterv=',TOPR.ReadIntervalTimeout,'ms; ReadTotalMulti=',TOPR.ReadTotalTimeoutMultiplier,'ms; ReadTotalConst=',TOPR.ReadTotalTimeoutConstant,'ms');
  writeln('=================');writeln('ESC -- Hard Exit.');writeln('Q   -- Soft Exit (EOL symbol wailing).');writeln('C   -- New log-file.');writeln('...data waiting.');
  PurgeComm(hcom1,PURGE_TXCLEAR or PURGE_RXCLEAR); //clear buffers
  //overlap
  ZeroMemory(@OverLap,sizeof(OverLap));Overlap.hEvent:=CreateEvent(nil,True,False,nil);ResetEvent(OverLap.hEvent);OverLap.Offset:=$FFFFFFFF;OverLap.OffsetHigh:=$FFFFFFFF; //0xFFFFFFFF==4294967295
  //main sycle
  DTNow:=Now;DecodeDate(DTNow,Y,Mo,Dda);DecodeTime(DTNow,H,M,S,SS);Ho:=H;Ddao:=Dda;
  fname:=lzero(Y)+lzero(Mo)+lzero(Dda)+'_'+lzero(H)+lzero(M)+lzero(S)+iniext;
  FileFl:=0;fPath:=rootdir+fname;fPathP:=stralloc(byte(fPath[0])+1);strpcopy(fPathP,fPath);FileHandle:=CreateFile(fPathP,GENERIC_WRITE,0,nil,OPEN_ALWAYS,FILE_FLAG_OVERLAPPED,0);
  Ltimeo:=H*3600000+M*60000+S*1000+SS;key:=#0;fl:=true;
  repeat
    if KeyPressed then key:=ReadKey;
    ReadFile(hcom1,char1,1,ret,nil);
    if ret<>0 then begin
      DTNow:=Now;DecodeDate(DTNow,Y,Mo,Dda);DecodeTime(DTNow,H,M,S,SS);
      //if long time last byte take, then prepare to move Head to buffer
      Ltime:=H*3600000+M*60000+S*1000+SS;
      if (H=0)and(Ho=23) then dLtime:=Ltime+3600000-Ltimeo else dLtime:=Ltime-Ltimeo;
      Ltimeo:=Ltime;
      //if EOL symbol and (new hour&H or new day&D) then move buffer to file, clear buffer, create new file
      if ((fl)or(dLtime>EOLtime))and(((H<>Ho)and(fz='H'))or((Dda<>Ddao)and(fz='D'))) then begin
        Ho:=H;Ddao:=Dda;fname:=lzero(Y)+lzero(Mo)+lzero(Dda)+'_'+lzero(H)+lzero(M)+lzero(S)+iniext;
        FWrite;FileFl:=1;fPath:=rootdir+fname;strpcopy(fPathP,fPath);FileHandleNew:=CreateFile(fPathP,GENERIC_WRITE,0,nil,OPEN_ALWAYS,FILE_FLAG_OVERLAPPED,0);
      end;
      //move Head to buffer (long time last byte take)
      if (dLtime>EOLtime)or(fl) then HeadWrite;
      //load char1 to buffer. if EOL symbol then set flag
      buf^:=char1;inc(buf);
      write(char1);
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
end.
