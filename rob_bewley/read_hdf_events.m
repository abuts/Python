function read_hdf_events(filename)
if ~exist('filename','var')
    filename = 'mccode_rod3D.h5';
end
% this program takes diffraction data in x,y format and then gets the FWHM
% of each peak it finds

L1=40; % distance from moderator to sample in m
filename2='det_positions.dat';

% this reads the event mode data
events = h5read(filename,'/entry1/data/k01_events_dat_list_p_x_y_n_id_t/events');

detidevent= events(5,:) ;
dettimeevent=events(6,:);


% this reads the deector data for
fid = fopen(filename2,'r');


line1 = fgets(fid);
line1 = fgets(fid);
line1 = fgets(fid);

det = textscan(fid,'%d %f %f %f %f %f ');
detid= det{1,1} ;
detx=det{1,3};
dety=det{1,4};
detz=det{1,5};
detef=det{1,6};

% calclate hw and Qx for eah event
for loop=2:length(detidevent)
    
    ind=find(detidevent(loop)==detid);
    x=detx(ind);y=dety(ind);z=detz(ind);ef=detef(ind);t=dettimeevent(loop);
    [azimuth,elevation,L2] = cart2sph(x,z,y);
    v2=sqrt(ef)*437.393;% speed in m/s of neutron in secondary
    t2=L2/v2; % time taken to travel secondary
    t1=t-t2; % time to travel secondary
    v1=L1/t1; % velocity in primary
    kzp=v1*0.00158825; % primary k along z
    ei=5.22704e-6*v1^2; % incident energy
    et(loop)=ei-ef; % transfered energy
    kf=v1*0.00158825; % magnitude f secondary k vector
    ky=sin(elevation)*kf; % vertical k value
    kplane=sqrt(kf^2-ky^2); % value of k in plane
    kx(loop)=-cos(azimuth)*kplane; % kx value
    %kz(loop)=kzp+sin(azimuth)*kplane
end
figure
scatter(-kx,et)
