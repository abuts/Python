function [f_out,t_out] = fft_propagate_pulse_IntW(f_in,time_in,vel_in,L,V_pulse,t_char,v_char)
% Calculate interpolited time-velocity profile at the position L using fft
% W - version integrates from t_min = min(time_in)+L/v_max
%                        to   t_max = max(time_in)+L/v_min;
%
% f_in     -- 2D signal function in units tau(mks) vs
% time_in  -- time axis for signal  (sec)
% vel_in   -- velocity accis for signal (m/sec)
% L        -- distance to the target
% tau -- time at choper to shift function around (in chopper opening time
%
% Output:
%  Interpolated fime-velocity profile at position L
% f_out  --
% t_out -- time axis for the profile above (sec)
% v_out -- velocity axis for the profile above (in m/s)
v_min = min(vel_in);
v_max = max(vel_in);
%DV0 = v_max - v_min;
tp_min = min(time_in)+L/v_max;
tp_max = max(time_in)+L/v_min;
DT0 = tp_max-tp_min;
dt = time_in(2) - time_in(1);
% if dt<2e-6 % debugging -- not needed in reality
%     dt = 2e-6;
% end
[t_out,dt,Nt] = adjust_step(tp_min,tp_max,dt);
t_orig_min = min(time_in);
t_orig_max = tp_max-L/v_max;
dt0 = (t_orig_max-t_orig_min)/(Nt-1);
[t_in_expanded,dt0,Nt] = adjust_step(t_orig_min,t_orig_max,dt0);

dv = (vel_in(2)-vel_in(1));
%dv = 3*(vel_in(2)-vel_in(1));
%dv  = (v_max-v_min)/(Nt-1);
[v_out,dv,Nv] = adjust_step(v_min,v_max,dv);

[xb,yb] = meshgrid(time_in,vel_in);
[xi,yi]= meshgrid(t_in_expanded,v_out);
f_in = interp2(xb,yb,f_in,xi,yi,'linear',0);

v_index = fft_ind(Nv);
t_index = fft_ind(Nt);
DV0 = max(v_out)-min(v_out);

% %
% % % [xi,yi]= meshgrid(t_out,vel_in);
% % % [xb,yb] = meshgrid(t_int,vel_in);
% surf(xi/t_char,yi/v_char,f_in,'Edgecolor','None');
% view(0,90);

% f_in_int = interp2(xb,yb,f_in,xi,yi,'linear',0);
%
%
% fft frequencies do not correspond to indexes as index m in fft array
% has frequency m-1 if m<N/2 and end-m if bigger;
f_in_sp = (fft2(f_in,Nv,Nt));
v_min_norm = v_min/(DV0);
v_max_norm = v_max/(DV0);
res_name = sprintf('Cash_IntW_Nv%dNt%d',Nv,Nt);


% DNv = Nv-numel(vel_in);
%v_phase =  exp(1i*pi*v_index*((v_min_norm+v_max_norm))); % appears to shift zeros added at the end to zeros, added to the beginning

%
f_in_t  = ifft2(f_in_sp);
figure(20)
[xi,yi] = meshgrid(t_out/t_char,v_out/v_char);
surf(xi,yi,abs(f_in_t),'Edgecolor','None');
view(0,90);

%persistent f_con_mat;
f_con_mat = [];
if isempty(f_con_mat)
    if exist([res_name,'.mat'],'file')
        disp(['***** loading ',res_name]);
        cns = load(res_name);
        f_con_mat = cns.f_con_mat;
    else
        disp(['***** processing ',res_name]);
        f_con_mat = ones(Nv,Nt)*NaN;
    end
end
v_steps_norm = v_out/DV0;
betta0 = (L/DT0)/DV0;

t_start=tic;
if any(isnan(reshape(f_con_mat,1,numel(f_con_mat))))
    %     ws = warning('off','MATLAB:integral:MaxIntervalCountReached');
    %     clob = onCleanup(@()warning(ws));
    %I1 = Imk(1,2);
    for n=1:Nt
        undef = isnan(f_con_mat(:,n));
        if ~any(undef)
            continue;
        end
        
        vec_mat = f_con_mat(:,n);
        parfor m=1:Nv
            if undef(m)
                vec_mat(m) = I_mkvec(m,n,betta0,v_min_norm,v_max_norm,v_index,t_index);
            end
        end
        %         nt = t_index(n);
        %         if nt ~= 0
        %             vec_mat = int_fitter(vec_mat,v_steps_norm,nt,v_min_norm,v_max_norm);
        %         end
        %
        f_con_mat(:,n)= vec_mat;
        if rem(n,5) == 0
            fprintf('writing step %d#%d\n',n,Nt);
            
            
            save(res_name,'f_con_mat');
        end
    end
    %f_con_mat = reshape([f_arr{:}],Nt,Nv)';
    fprintf('final write of %d\n',Nv);
    save(res_name,'f_con_mat');
end
% for n=1:Nt
%     nt = t_index(n);
%     if nt ~= 0
%         f_con_mat(:,n) = phase_fitter(f_con_mat(:,n),v_steps_norm,betta0,nt,v_min_norm,v_max_norm);
%     end
% end

f_in_sp = f_in_sp.*f_con_mat;
% v_phase =  exp(1i*pi*v_index);
% % %f_in_sp = bsxfun(@times,f_in_sp,v_phase');
% % %v_phase =  exp(1i*pi*v_index);
% f_in_sp = bsxfun(@times,f_in_sp,v_phase');

%t_phase = exp(1i*pi*t_index*(L/(v_min*DT0))); %
t_phase = exp(1i*pi*t_index); %
f_in_sp = bsxfun(@times,f_in_sp,t_phase );
%

f_t = ifft2(f_in_sp);
[xi,yi] = meshgrid(t_out/t_char,v_out/v_char);
surf(xi,yi,abs(f_t),'Edgecolor','None');
view(0,90);

f_out_sp = sum(f_in_sp,1);
%t_phase =  exp(1i*pi*t_index*(1+2*v_min_norm-(tp_min+tp_max)/(DT0))); %
%t_phase =  exp(-1i*pi*t_index*((tp_min+tp_max)/(DT0))); %
% t_phase =  exp(-2i*pi*t_index*v_min_norm); %
%
time_c = toc(t_start)/60; % convert in minutes
fprintf(' Calculations take: %f min\n',time_c);
f_out = ifft(f_out_sp);



function in = I_mkvec(nv,kt,betta0,v_min_norm,v_max_norm,v_index,t_index)
if numel(nv)>1 || numel(kt) > 1
    in = zeros(numel(nv),numel(kt));
    for mp=1:numel(nv)
        nvt = nv(mp);
        for np = 1:numel(kt)
            ktt = kt(np);
            in(mp,np) = I_mk4(nvt,ktt,betta0,v_min_norm,v_max_norm,v_index,t_index);
        end
    end
else
    in = I_mk4(nv,kt,betta0,v_min_norm,v_max_norm,v_index,t_index);
end


