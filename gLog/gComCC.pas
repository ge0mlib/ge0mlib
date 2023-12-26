program gComCC20190524; //Ge0MLib.com
uses windows,crt,strings,sysutils;
var     rootdir,inipath:string;iniext:string;f:text;              //config file
        f1:file;fname:string;fz:char;
        SNcom:string;Ncom:PChar;
        ComBaud:longword;ComBytesize,ComParity,ComStopbits:byte; //com-port parameters
        dcbz:_DCB;TOPR:COMMTIMEOUTS;hcom1:HANDLE;ret:longword;   //com-port var
        Y,Mo,Dda,Ddao,H,Ho,M,S,SS:word;DTNow:TDateTime;
        Ltime:longint;SLtime:string;LenSLtime:word;
        i:integer;b:byte;
        key,c1,c2:char;
        CC:integer;SCC:string;LenSCC:word;toCom:string;

function LZero(w:word):string;
  var s:string;
  begin str(w:0,s); if length(s)=1 then s:='0'+s; LZero:=s;end;

begin
  clrscr;writeln('---gComCableCounter20190524//Ge0MLib.com---');
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
  //read extension for log
  readln(f,iniext);writeln('Read: log files extension=',iniext);
  //read auto-break code for file
  readln(f,fz);writeln('Read: autobreak code=',fz);
  //read delimiters
  readln(f,c1,c2);writeln('Read: LeftDelim=''',c1,'''; RightDelim=''',c2,'''');
  close(f);
  //open port
  hcom1:=CreateFile(Ncom,GENERIC_WRITE,0,nil,OPEN_EXISTING,0,0);
  if (hcom1=INVALID_HANDLE_VALUE) then begin writeln('Error: can not open Com');writeln('Press any key for Exit');ReadKey;exit;end;
  //set TDCB
  GetCommState(hcom1,dcbz);dcbz.BaudRate:=ComBaud;dcbz.ByteSize:=ComBytesize;dcbz.Parity:=ComParity;dcbz.StopBits:=ComStopbits;
  if not(SetCommState(hcom1,dcbz)) then begin writeln('Error: can not config Com');writeln('Press any key for Exit');ReadKey;exit;end;
  GetCommState(hcom1,dcbz);WriteLn('Configed: BaudRate=',dcbz.BaudRate,'; ByteSize=',dcbz.ByteSize,'; Parity=',dcbz.Parity,'; StopBits=',dcbz.StopBits);
  //set CommTimeouts
  TOPR.ReadIntervalTimeout:=0;TOPR.ReadTotalTimeoutMultiplier:=0;TOPR.ReadTotalTimeoutConstant:=1000;
  if not(SetCommTimeouts(hcom1,TOPR)) then begin writeln('Error: can not set Com TimeOuts');writeln('Press any key for Exit');ReadKey;exit;end;
  GetCommTimeouts(hcom1,TOPR);writeln('TimeOuts: ReadInterv=',TOPR.ReadIntervalTimeout,'ms; ReadTotalMulti=',TOPR.ReadTotalTimeoutMultiplier,'ms; ReadTotalConst=',TOPR.ReadTotalTimeoutConstant,'ms');
  writeln('=================');writeln('ESC -- Hard Exit.');writeln('Q   -- Soft Exit (EOL symbol wailing).');writeln('B   -- Break log-file.');writeln('...data waiting.');
  PurgeComm(hcom1,PURGE_TXCLEAR or PURGE_RXCLEAR); //clear buffers

  //main sycle
  DTNow:=Now;DecodeDate(DTNow,Y,Mo,Dda);DecodeTime(DTNow,H,M,S,SS);Ho:=H;Ddao:=Dda;
  fname:=lzero(Y)+lzero(Mo)+lzero(Dda)+'_'+lzero(H)+lzero(M)+lzero(S)+iniext;assign(f1,rootdir+fname);rewrite(f1,1);
  key:=#0;CC:=0;
  repeat
    if KeyPressed then begin
      key:=ReadKey;
      DTNow:=Now;DecodeDate(DTNow,Y,Mo,Dda);DecodeTime(DTNow,H,M,S,SS);
      //if long time last byte take, then prepare to move Head to buffer
      Ltime:=H*3600000+M*60000+S*1000+SS;
      //if (new hour&H or new day&D) then move buffer to file, clear buffer, create new file
      if ((H<>Ho)and(fz='H'))or((Dda<>Ddao)and(fz='D')) then begin
        Ho:=H;Ddao:=Dda;fname:=lzero(Y)+lzero(Mo)+lzero(Dda)+'_'+lzero(H)+lzero(M)+lzero(S)+iniext;
        close(f1);assign(f1,rootdir+fname);rewrite(f1,1);
      end;
      //if pressed 'C' and then create new file
      if (key='C') then begin
        Ho:=H;Ddao:=Dda;fname:=lzero(Y)+lzero(Mo)+lzero(Dda)+'_'+lzero(H)+lzero(M)+lzero(S)+iniext;
        close(f1);assign(f1,rootdir+fname);rewrite(f1,1);
      end;
      if key='=' then CC:=CC+1;
      if key='-' then CC:=CC-1;if CC<0 then CC:=0;
      //move Head to buffer (long time last byte take)
      str(Ltime,SLtime);LenSLtime:=length(SLtime);for i:=LenSLtime to 7 do SLtime:='0'+SLtime;
      str(CC,SCC);LenSCC:=length(SCC);for i:=LenSCC to 3 do SCC:='0'+SCC;
      toCom:=c1+SLtime+c2+SCC+char(13)+char(10);
      write(toCom);
      WriteFile(hcom1,toCom[1],byte(toCom[0]),ret,nil);
      blockwrite(f1,toCom[1],byte(toCom[0]));
    end;
  until (key=#27)or((key='Q'));
  close(f1);
  PurgeComm(HANDLE(hcom1),PURGE_TXCLEAR or PURGE_RXCLEAR);CloseHandle(hcom1);
end.
