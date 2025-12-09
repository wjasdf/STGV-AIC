function I1=AIC(I,value,lower,upper)
gamma_matrix=zeros(size(I));
m=mean2(I);
adap_gamma=log10(value)/log10(m);

gamma_matrix=(m./(I+eps)).*log10(value)./(log10(I+eps)+eps);
if m<value
    if upper*adap_gamma>1
        up=1;
    else
        up=upper*adap_gamma;
    end
    low=lower*adap_gamma;
    gamma_matrix(gamma_matrix>up)=up;
else
    if lower*adap_gamma<1
        low=1;
    else
        low=lower*adap_gamma;
    end
    up=upper*adap_gamma;
    gamma_matrix(gamma_matrix>up)=up;
end

gamma_matrix(gamma_matrix<low)=low;

I1=I.^gamma_matrix;
end