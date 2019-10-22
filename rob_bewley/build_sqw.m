wk_dir = pwd;
%ef_file = fullfile(wk_dir,'det_Ef.dat');
ef_file = fullfile(wk_dir,'det_positions.dat');
spe_file = fullfile(wk_dir,'dE2_test.nxspe');
sqw_file = fullfile(wk_dir,'dE2_test.sqw');
fid = fopen(ef_file,'r');
clOb = onCleanup(@()fclose(fid));
tline = fgets(fid);
tline = fgets(fid);
n_det = textscan(tline,'%d10');
n_det = n_det{1};
tline = fgets(fid);
Data = zeros(1,n_det );
for k=1:n_det
    tline = fgets(fid);
    Cont = textscan(tline ,'%9d %11.5f %11.5f %11.5f  %11.5f  %11.5f');    
    Data(k) = Cont{6};
end


efix=Data;
valid = efix~=20;
nValid = sum(valid);
efix=efix(valid);
efix_av = sum(efix)/numel(efix);
dE_max = max(efix-efix_av);
dE_min = min(efix-efix_av);
fprintf('**** Energy variation: E_fix=%f mEv Dev_min=%f Dev_max=%f\n',efix_av,dE_min*100/efix_av,dE_max*100/efix_av)
emode=2;
alatt=[2*pi,2*pi,2*pi];
angdeg=[90,90,90];
u=[0,0,1];
v=[0,-1,0];
omega=0;dpsi=0;gl=0;gs=0;
psi = 0;


% Create sqw file
  gen_sqw ({spe_file,spe_file}, '', sqw_file, Data, emode, alatt, angdeg,...
            u, v, psi, omega, dpsi, gl, gs,'replicate') %,...
%            [1,1,1,1],[-1,-1,-1,0;3,3,3,6]);
% u=[1,0,0];
v=[0,1,0];
w2e = cut_sqw(sqw_file,struct('u',u,'v',v),[0,0.01,3],[0,1.5],[0,1.1],[0,0.02,6]);
plot(w2e)
keep_figure
w2xy = cut_sqw(sqw_file,struct('u',u,'v',v),[0,3],[0,0.01,1.5],[0,0.01,1.1],[0,6]);
plot(w2xy)
keep_figure
w2xz = cut_sqw(sqw_file,struct('u',u,'v',v),[0,0.01,3],[0,1.5],[0,0.01,1.1],[0,6]);
plot(w2xz)
keep_figure
w2yz = cut_sqw(sqw_file,struct('u',u,'v',v),[0,0.01,3],[0,0.01,1.5],[0,1.1],[0,6]);
plot(w2yz)
keep_figure

% w4 = read_sqw(sqw_file);
% sigma = 0.1;
% w4S = sqw_eval(w4,@calc_disp,sigma);
% w2s = cut_sqw(w4S,struct('u',u,'v',v),[-2,0.01,1],[],[],[0,0.02,3.2]);
% plot(w2s)
% logz


function disp = calc_disp(qh, qk, ql, en, p)
sigma = p(1);
disp = exp(-((qh+1)/sigma).^2).*exp(-(qk/sigma).^2).*exp(-(ql/sigma).^2);
end