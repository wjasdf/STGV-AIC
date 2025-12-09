function N2 = Noise_trans(N1,C0,edges0)
%Transform noise distribution via histogram matching
%Input
% N1: origianl noise; C0: target noise
%Output
% N2: Transformed noise
[C1,edges1] = histcounts(N1,2000,'Normalization','cdf');
C1=[0,C1];
Cx= interp1(edges1,C1,N1);
N2= interp1(C0,edges0,Cx);

end

