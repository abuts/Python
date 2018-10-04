function test_deltaf
% let's test equations, used in fourier transformation of delta-functions
%

% check fft(Delta(v-V0)) = Sum_n{exp(-i*Omega_n*V0)}
Np=64;
iV = 32;
RangeMin = -1;
RangeMax =  3;
Range0 = 0.5*(RangeMax+RangeMin);
Range = RangeMax-RangeMin;
dX = Range/(Np-1);
V0 = RangeMin+(iV-1)*dX;
xx = RangeMin+(0:Np-1)*dX;
%ind = 0:Np-1;
ind = fft_ind(Np);
Omega_n = ind*(2*pi/Range);


DeltaF1 = zeros(1,Np);
DeltaF1(iV) = 1;
%omg = fftshift(Omega_n);
%DeltaF1 = exp(1i*omg(iV)*xx);

spec = fft(DeltaF1);
delR = ifft(spec);
theor_sp = exp(-1i*(V0-Range0)*Omega_n);
%theor_sp = zeros(size(DeltaF1)); %
%theor_sp(iV) = Np*exp(1i*omg(iV)*Range0);
theoR = ifft(theor_sp);
theoRR = sum((exp(1i*(xx-V0).*Omega_n')),1)/(Np-1);
plot(xx,real(DeltaF1),':',xx,real(delR),'*',xx,real(theoRR),'o',xx,real(theoR));
if any(abs(imag(DeltaF1))>1.e-9) || any(abs(imag(delR))>1.e-9) || any(abs(imag(theoR))>1.e-9)
    hold on;
    plot(xx,imag(DeltaF1),':',xx,imag(delR),'*',xx,imag(theoR));
    hold off;
end



expR = IX_dataset_1d(fftshift(Omega_n/(2*pi)),fftshift(real(spec)));
expI = IX_dataset_1d(fftshift(Omega_n/(2*pi)),fftshift(imag(spec)));

acolor('r');
aline('-');
dl(expR);
aline('--');
pd(expI);

theorR = IX_dataset_1d(fftshift(Omega_n/(2*pi)),fftshift(real(theor_sp)));
theorI = IX_dataset_1d(fftshift(Omega_n/(2*pi)),fftshift(imag(theor_sp)));
acolor('b');
aline('-');
pd(theorR);
aline('--')
pd(theorI);


