wk_dir = pwd;
ef_file = fullfile(wk_dir,'det_Ef.dat');
spe_file = fullfile(wk_dir,'oned_test.nxspe');
sqw_file = fullfile(wk_dir,'oned_test.sqw');
fid = fopen(ef_file,'r');
clOb = onCleanup(@()fclose(fid));
Cont = textscan(fid ,'%10.3f %10.4f');

efix=Cont{2};
valid = efix~=0;
nValid = sum(valid);
efix_av = sum(efix)/nValid;
dE_max = max(efix(valid)-efix_av);
dE_min = min(efix(valid)-efix_av);
fprintf('**** Energy variation: E_fix=%f mEv Dev_min=%f Dev_max=%f\n',efix_av,dE_min*100/efix_av,dE_max*100/efix_av)
emode=2;
alatt=[1,1,1];
angdeg=[90,90,90];
u=[0,0,1];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;
psi = 0;


% Create sqw file
%gen_sqw (spe_file, '', sqw_file, efix_av, emode, alatt, angdeg,...
%         u, v, psi, omega, dpsi, gl, gs);
w2 = cut_sqw(sqw_file,struct('u',u,'v',v),[0.,0.002,0.5],[-1,1],[-1,1],[0,0.02,3.2]);
plot(w2)