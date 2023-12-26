function [Head,Data]=gXtf000DeleteSlant(Head,Data,mask)
%Delete slant-range data in Xtf-structure for for Message Type 000 (Sonar Data Message)
%function [Head,Data]=gXtf000DeleteSlant(Head,Data,mask), where
%[Head,Data]- Xtf structure // Data must contained traces with equal length;
%mask- mask for slant-range data delete (logical or trace_numbers);
%[Head,Data]- Xtf structure with deleted slant-range data.
%Example: XtfHead=gXtfHeaderRead('e:\ND49_V17B1212_SSSH.xtf',1);[Head,Data]=gXtf000Read(XtfHead,0);
%figure(1);imagesc(Data(:,:,1));figure(2);imagesc(Data(:,:,2));
%[Head,Data]=gXtf000DeleteSlant(Head,Data,1:2000);
%figure(3);imagesc(Data(:,:,1));figure(4);imagesc(Data(:,:,2));gXtf000Write(XtfHead,Head,Data,'e:\ND49_V17B1212_SSSHzz.xtf',1);

if islogical(mask), mask=find(~mask);end;
CNumSamples=Head.CNumSamples-length(mask);
Head.CSlantRange=Head.CSlantRange./Head.CNumSamples.*CNumSamples;
Head.CNumSamples(:)=CNumSamples;
Head.CTimeDuration=Head.CSlantRange./repmat(Head.HSoundVelocity,size(Head.CTimeDuration,1),1);

tmp1=Data(:,:,1);tmp1(mask,:)=[];
tmp2=Data(:,:,2);tmp2(size(Data,1)-mask+1,:)=[];
Data=cat(3,tmp1,tmp2);

%mail@ge0mlib.com 27/04/2017