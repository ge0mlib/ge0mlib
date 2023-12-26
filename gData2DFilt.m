function Data=gData2DFilt(Data,wk,normFl)
%Matrix filtration with 2D-slice-window (includes filter’s coefficients).
%function Data=gData2DFilt(Data,wk,normFl), where
%Data- input matrix;
%wk- 2D filter coefficients;
%normFl- normalization flag; if normFl~=0, than wk=wk./sum(wk);
%Data- output filtered matrix.
%Example: X=zeros(10);X(2,2)=1;h=zeros(7);h(4,4)=1;Data1=gData2DFilt(X,h,0);

if normFl~=0, wk=wk./sum(sum(wk));end;
Data1=filter2(wk,Data,'full');
lw1_1=fix(size(wk,1)./2+1e-6);if rem(size(wk,1),2), lw2_1=lw1_1; else lw2_1=lw1_1-1;end;
lw1_2=fix(size(wk,2)./2+1e-6);if rem(size(wk,2),2), lw2_2=lw1_2; else lw2_2=lw1_2-1;end;
Data=Data1(lw1_1+1:end-lw2_1,lw1_2+1:end-lw2_2);

%mail@ge0mlib.com 27/05/2018