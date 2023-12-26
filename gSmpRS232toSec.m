function Time=gSmpRS232toSec(BaudRate,ByteSize,Parity,StopBits)
%Calculate one byte reading time in seconds for COM-port (RS-232).
%function Time=gSmpRS232toSec(BaudRate,ByteSize,Parity,StopBits), where
%BaudRate,ByteSize,Parity,StopBits are COM-port settings >>>
%BaudRate: 110,300,600,1200,2400,4800,9600,14400,19200,14400,19200,38400,57600,115200,128000,256000.
%ByteSize: 1,2,3,4,5,6,7,8.
%Parity: NOPARITY==0;ODDPARITY==1;EVENPARITY==2;MARKPARITY==3;SPACEPARITY==4.
%StopBits: ONESTOPBIT==0;ONE5STOPBITS==1;TWOSTOPBITS==2.
%Example: Time=gSmpRS232toSec(9600,8,0,0);

Bits=1;%start bit
Bits=Bits+ByteSize; %byte size
if (Parity~=0),Bits=Bits+1;end %parity bit
switch StopBits %stop bits
    case 0,Bits=Bits+1;
    case 1,Bits=Bits+1.5;
    case 2,Bits=Bits+2;
    otherwise,error('Incorrect StopBits value');
end
Time=Bits./BaudRate; %time for one byte transmitting

%mail@ge0mlib.com 16/05/2022