function write_mushroom_xyz_idf()
% simple script to write MUSHROOM IDF given model of physical and files of
% neutronic positions of the Mushroom detectors.
%
% DEFININTIONS:
working_dir = fileparts(mfilename('fullpath'));
% file with neutronic detector positions and incident energies per detector
det_dat_file = fullfile(working_dir,'det_positions.dat');

%
IDF_head_file = fullfile(working_dir,'MUSHROOM_IDF_head.xml');
IDF_foot_file = fullfile(working_dir,'MUSHROOM_IDF_foot.xml');

% target file to write
IDF_fname = fullfile(working_dir,'MUSHROOM_Definition.xml');

% get detector info:
pos = read_det_dat_pos(det_dat_file);

% copy MUSHROOM header information
fh = copy_file(IDF_head_file,IDF_fname);
% calculate physical positions of the monitors and write neutronic and physical positions into idf file.
% The information about correspondence between physical detectors and
% neutronic detectors is provided within this file. 
fh = write_musroom_xyz_monitors(pos,fh);
% copy mushroom footer file. Do not forget to manually modify monitor ID when number
% of tubes have changed to make monitor ID higher than the all other detectors
copy_file(IDF_foot_file,fh);




function warargout = copy_file(source_file,target)
% copy source file in the target, which is either a file or open file
% handle
%
fhs = fopen(source_file,'rb');
if fhs<0
    error('WRITE_MUSHROOM_IDF:runtime_error',' Can not open source file %s',...
        source_file);
end
clobr = onCleanup(@()fclose(fhs));
if ischar(target)
    fht = fopen(target,'wb');
    if fht<0
        error('WRITE_MUSHROOM_IDF:runtime_error',' Can not open target file %s',...
        target);        
    end
elseif isnumeric(target)
    fht = target;
    fname = fopen(fht);
    if isempty(fname) || isnumeric(fname)
        error('WRITE_MUSHROOM_IDF:runtime_error',' got handle to file which is not open')
    end
else
   error('WRITE_MUSHROOM_IDF:invalid_argument',...
       'Unknown type of target. Can be filename or handle to an open file')
end

cont = fread(fhs);
fwrite(fht,cont);

if nargout > 0
    warargout = fht;
else
    fclose(fht);
end



function neutron_pos_data= read_det_dat_pos(det_dat_file)
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
x  = zeros(n_rows,1);
y    = zeros(n_rows,1);
z    = zeros(n_rows,1);
efix   = zeros(n_rows,1);
for ic = 1:n_rows
    tline = fgetl(fh);
    data = sscanf(tline,'%d %f %f %f %f %f');
    det_id(ic) = data(1);
    L2(ic) = data(2);
    x(ic) = data(3);    
    y(ic) = data(4);    
    z(ic) = data(5);        
    efix(ic) = data(6);
end

neutron_pos_data = [det_id,L2,x,y,z,efix];