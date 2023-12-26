function Data1=gDataTraceFilt(Data,wk,normFl)
%Traces/columns filtration with slice-window (includes filter’s coefficients).
%function Data1=gDataTraceFilt(Data,wk,normFl), where
%Data- input matrix with traces; Data(trace_length,trace_num);
%wk- filter's coefficients;
%normFl- normalization flag; if normFl~=0, than wk=wk./sum(wk);
%Data1- output matrix with traces.
%Example: wk1=gausswin(12,3);Data1=gDataTraceFilt(Data,wk1,normFl); %wk1=gausswin(N,Alpha);wk2=chebwin(L,r);wk3=blackman(N,SFLAG);wk4=blackmanharris(N,SFLAG);

wk=wk(:)';
if normFl~=0, wk=wk./sum(wk);end;
lw=length(wk)-1;lw2=fix(length(wk)./2+1e-6);
s=size(Data);Data1=nan(s);
for nz=1:s(1)-lw, Data1(nz+lw2,:)=wk*Data(nz:nz+lw,:);end;

%mail@ge0mlib.com 18/08/2016