wk_dir = pwd;
ef_file = fullfile(wk_dir,'det_Ef.dat');
spe_file = fullfile(wk_dir,'oned_test.nxspe');
sqw_file = fullfile(wk_dir,'oned_test.sqw');
fid = fopen(ef_file,'r');
clOb = onCleanup(@()fclose(fid));
Cont = textscan(fid ,'%10.3f %10.4f');

efix=Cont{2};
emode=2;
alatt=[1,1,1];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;
psi = 0;


% Create sqw file
gen_sqw (spe_file, '', sqw_file, efix, emode, alatt, angdeg,...
         u, v, psi, omega, dpsi, gl, gs);
