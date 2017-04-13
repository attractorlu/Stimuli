% generate drifting grating of different size 
function stim_gen_grating_vary_sizes(  )


%% parameters

x = 160;
y = 90;

grating_size = [10:10:60 80 120 200 ] ; % pixel, diameter
grating_ori = [45 135]; % orientation
repeat = 10;

stim_duration = 0.5;
blank_duration = 0.5;

contrast = 1;
spatial_freq = 0.05; % cycle per pixel
temporal_freq = 2; % cycle per sec
frame_rate = 28;
resx = 320;
resy = 180;
background = 127.5;
outputpath = '.';


%%
n_size = length(grating_size);
n_ori = length(grating_ori);

n_stim = n_size * n_ori * repeat;
template = cell(n_stim,1);

stim_frames = round(frame_rate*stim_duration);
blank_frames = round(frame_rate*blank_duration);

bg = zeros(resy, resx, blank_frames) + background;

k = 0;
for i = 1:n_size % different size
    
    for j = 1:n_ori
        
        k=k+1;
        
        mv = drifting_grating(resx, resy, stim_frames, frame_rate, ...
            x, y, grating_size(i), grating_ori(j), spatial_freq, temporal_freq, background);
        
        template{k} = mv;
        
    end
    
end

% implay(template)
 
%% movie data

blank =  zeros(resy, resx, blank_frames) + background;

% stim = blank;
stim = [];
seq=[];

for i=1:repeat
    ind=randperm(length(template));
    template_rand=template(ind);
    seq=[seq ind];
    for j=1:length(template)
        stim = cat(3, stim, template_rand{j},  blank );
    end
end

stim = uint8(stim);


implay(stim)

%%


params.x = x;
params.y = y;

params.grating_size = grating_size;
params.grating_ori = grating_ori;
params.repeat = repeat;

params.stim_duration = stim_duration;
params.blank_duration = blank_duration;

params.contrast = contrast;
params.spatial_freq =spatial_freq; % cycle per pixel
params.temporal_freq = temporal_freq; % cycle per sec
params.frame_rate = frame_rate;
params.resx = resx;
params.resy = resy;
params.background = background;
params.outputpath = outputpath;

datetime_str=datestr(now,'yyyy.mm.dd-HH.MM.SS');
filename = ['Grating_vary_sizes_' num2str(frame_rate) 'Hz_' num2str(n_size) 'size_' num2str(repeat) 'repeat_' datetime_str '.mat'];
save(fullfile(params.outputpath, filename),'stim', 'frame_rate', 'template', 'params','seq','-v7.3');




function mv = drifting_grating(resx, resy, nframe, frame_rate, x0, y0, size, ori, sf, tf, background)

upsampling = 4;
[xx, yy] = meshgrid(1:resx*upsampling,1:resy*upsampling);
mask = (xx-x0*upsampling).^2 + (yy-y0*upsampling).^2 > (size/2*upsampling)^2;

ori = ori/180*pi;
x = (xx).*cos(ori) - (yy).*sin(ori);

mv = zeros(resy,resx,nframe);
for i = 1:nframe
    g = sin( x*sf*2*pi/upsampling + i/frame_rate*tf*2*pi )*127.5+127.5;
    g(mask) = background;
    mv(:,:,i) = imresize(g,1/upsampling);
end


