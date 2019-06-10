function write_mushroom_idf()
% simple script to write MUSHROOM IDF given model of physical and files of
% neutronic positions of the Mushroom detectors.
%
% DEFININTIONS:
working_dir = pwd;
% file with neutronic detector positions. 
det_dat_file = fullfile(working_dir,'MUSHROOM_det_cor_pos_test2.dat');
% file with detectors efixed. 
det_efix_file = fullfile(working_dir,'MUSHROOM_det_Ef.dat');
%
IDF_head_file = fullfile(working_dir,'MUSHROOM_IDF_head.xml');
IDF_foot_file = fullfile(working_dir,'MUSHROOM_IDF_foot.xml');

% target file to write
IDF_fname = fullfile(working_dir,'MUSHROOM_Definition.xml');

% get detector info:
pos = read_neutronic_pos(det_dat_file,det_efix_file);

% copy MUSHROOM header information
fh = copy_file(IDF_head_file,IDF_fname);
% calculate physical positions of the monitors and write neutronic and physical positions into idf file.
% The information about correspondence between physical detectors and
% neutronic detectors is provided within this file. 
fh = write_musroom_monitors(pos,fh);
% copy mushroom footer file
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



