function XtfHead=gXtfHeaderMessOff(XtfHead,Head,mask)
%Mark messages typed in Head to Delete from Xtf structure; need write file with gXtfWriteHeader for Deleting.
%function XtfHead=gXtfHeaderMessOff(XtfHead,Head,mask), where
%[XtfHead,Head]- Xtf structure;
%mask- mask for messages marked off/on (logical or trace_numbers);
%XtfHead- Xtf structure with messages switched off/on.
%Example: XtfHead=gFXtfReadHeader('e:\ND49_V17B1212_SSSH.xtf',1);[Head,Data]=gFXtfRead000(XtfHead,0);
%mask=logical(ones(1,size(Data,2)));mask(1:4000)=0;XtfHead=gXtfFileSetMessOff(XtfHead,Head,mask);gXtfHeaderWrite(XtfHead,'e:\ND49_V17B1212_SSSHz.xtf');
%XtfHead=gXtfHeaderMessOff(XtfHead,Head,1:6000);gXtfHeaderWrite(XtfHead,'e:\ND49_V17B1212_SSSHz.xtf');

if islogical(mask), mask=~mask;end;
XtfHead.ROnFlag(Head.HMessageNum(mask))=0;
disp('Message gXtfSetTraceOff: Write file to remove messages');

%mail@ge0mlib.com 27/04/2017