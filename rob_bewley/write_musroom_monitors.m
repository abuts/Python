function fh_out = write_musroom_monitors(neutronic_pos_info,mon_file_name)
% Function saves the Mushroom monitors information in the form of the
% format, recognized by Mantid.
%
Npix_per_tube = 138;
x_step = 0.08;
x_min = 0.4-x_step;
y_min = 0;
y_step = 0.08;
tube_id_offset = 1000;
%
n_pos = size(neutronic_pos_info,1);
if rem(n_pos,Npix_per_tube) ~=0
    error('SAVE_MUSHROOM_MONITORS:invalid_argument',...
        'Number of neutronic positions is not proportional to the number of physical positions');
end
n_tubes = floor(n_pos/Npix_per_tube);

clob = [];
if ischar(mon_file_name) % file name is given. Process file
    fh = fopen(mon_file_name,'w');
    clob = onCleanup(@()fclose(fh));
    fh_out = [];
elseif isnumeric(mon_file_name)
    fh = mon_file_name;
    fname = fopen(fh);
    if isempty(fname) || isnumeric(fname)
        error('WRITE_MUSHROOM_MONITORS:runtime_error',' got handle to file which is not open')
    end
    fh_out = fh;
else
    error('WRITE_MUSHROOM_MONITORS:invalid_argument',...
        'Unknown type of target. Can be filename or handle to an open file')
end
single_analyzer_name = 'tube';
write_analysers_block(fh,'analyser',single_analyzer_name,tube_id_offset,Npix_per_tube,n_tubes)

ic = 1;
z = 0;
for i=1:n_tubes
    tube_id = i*tube_id_offset ;
    y = y_min+ (i-1)*y_step;
    header = sprintf('<type name=\"%s%d\">\n',single_analyzer_name,i);
    fwrite(fh,header);
    for j=1:Npix_per_tube
        det_id = tube_id+j;
        x = x_min+x_step*(j-1);
        write_pix_component(fh,det_id,x,y,z,neutronic_pos_info(ic,:));
    end
    footer = sprintf("</type>\n");
    fwrite(fh,footer);
    
end
%
function write_pix_component(fh,det_id,x,y,z,neutr_pos)
%     <component type="pixel">
%       <location name="5" x="0.487260681056" y="0.21631015625" z="2.39457769788">
%         <neutronic p="1.04109" r="4.72838" t="11.5018"/>
%       </location>
%       <parameter name="Efixed">
%         <value val="2.08275"/>
%       </parameter>
%     </component>

header = sprintf('     <component type="pixel">\n');
footer = sprintf('     </component>\n');
location_dat    =sprintf('       <location name=\"%d\" x=\"%f\" y=\"%f\" z=\"%f\">\n',det_id,x,y,z);
neutronic_dat   =sprintf('         <neutronic p=\"%f\" r=\"%d\" t=\"%f\"/>\n',neutr_pos(4),neutr_pos(2),neutr_pos(3));
location_close = sprintf('       </location>\n');
efix_dat     =   sprintf('       <parameter name=\"Efixed\">  <value val=\"%f\"/> </parameter>\n',neutr_pos(5));
fwrite(fh,header);
fwrite(fh,location_dat);
fwrite(fh,neutronic_dat);
fwrite(fh,location_close);
fwrite(fh,efix_dat);
fwrite(fh,footer);


function write_analysers_block(fh,block_name,comp_name,comp_offset,Nparts,N_comp)
header = sprintf('<!-- ANALYZERS BLOCK START         -->\n');
fwrite(fh,header);
header = sprintf('   <component type=\"%s\">\n    <location/>\n   </component>\n',block_name);
fwrite(fh,header);

header = sprintf('    <type name=\"%s\">\n',block_name);
fwrite(fh,header);
for i=1:N_comp
    header = sprintf('     <component idlist=\"%s%d\"  type=\"%s%d\">\n',comp_name,i,comp_name,i);
    data =   sprintf('        <location/>\n');
    footer = sprintf('     </component>\n');
    fwrite(fh,header);
    fwrite(fh,data);
    fwrite(fh,footer);
end
footer = sprintf('    </type>\n');
fwrite(fh,footer);

for i=1:N_comp
    header = sprintf('    <idlist idname=\"%s%d\">\n',comp_name,i);
    data =   sprintf('        <id start=\"%d\" end=\"%d\" />\n',i*comp_offset,i*comp_offset+Nparts-1);
    footer = sprintf('     </idlist>\n');
    fwrite(fh,header);
    fwrite(fh,data);
    fwrite(fh,footer);
end

header = sprintf('<!-- ANALYZERS BLOCK END        -->\n');
fwrite(fh,header);