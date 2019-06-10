function neutron_pos_data= read_neutronic_pos(det_dat_file,efix_file)
% read det.dat and efix files and return array containing the neutronic
% positions and the analyser's energies of the detectors
fh = fopen(det_dat_file);
clob = onCleanup(@()fclose(fh));
% skip desctiptor
fgetl(fh);
% get n-rows
tline = fgetl(fh);
data = sscanf(tline,'%d %d');
n_rows = data(1);
% skip header
fgetl(fh);

det_id = zeros(n_rows,1);
L2     = zeros(n_rows,1);
theta  = zeros(n_rows,1);
phi    = zeros(n_rows,1);
for ic = 1:n_rows
    tline = fgetl(fh);
    data = sscanf(tline,'%d %f %f %d %f %f');
    det_id(ic) = data(1);
    L2(ic) = data(3);
    theta(ic) = data(5);    
    phi(ic) = data(6);    
end
fh1 = fopen(efix_file);
clob = onCleanup(@()fclose(fh1));

det_id1 = zeros(n_rows,1);
efix    = zeros(n_rows,1);
for ic = 1:n_rows
    tline = fgetl(fh1);
    data = sscanf(tline,'%d %f');
    det_id1(ic) = data(1);
    efix(ic) = data(2);
end
if any(det_id ~= det_id1)
    error('READ_NEUTRONIC_POSITIONS:invalid_argument',...
        'detector ID-s from det.dat file and efix files are different')
end
neutron_pos_data = [det_id,L2,theta,phi,efix];