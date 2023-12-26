function q=gLogCheckSum(st)
%Checksum calculation for NMEA message.
%function q=gLogCheckSum(st), where
%st- string for checksum calculation;
%q- checksum in Hex.
%Not used $,!,* for: $GPGLL,5057.970,N,00146.110,E,142451,A*27<CR><LF> used 'GPGLL,5057.970,N,00146.110,E,142451,A'
%Example: q=gLogCheckSum(['$GPGLL,5057.970,N,00146.110,E,142451,A*27' char([13 10])]);

L=(st=='$')|(st=='*')|(st=='!')|(st==char(10))|(st==char(13));st(L)=[];
q=uint8(0);for n=1:numel(st), q=bitxor(q,uint8(st(n)));end;q=dec2hex(q);

%mail@ge0mlib.com 15/09/2017