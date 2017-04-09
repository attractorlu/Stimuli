function stim_gen_occluded_shape
% generate movie of occluded shape 
% for mouse object recognition task

ishape = 1;
ioccluder = 1;
output_filename = 'test.avi';

%param
shape_color = 'white';
background_color = 'black';
occluder_color = [.5 .5 .5];
move_range = 0.5;
FrameRate = 30;
nframes = 90;
speed = 0.5;  % cycle/s


% background
bg.color = background_color;
bg.range = [-1 1 -1 1]; 

%% shapes
% triangle
shapes{1}.x = [0 0 1]-0.5;
shapes{1}.y = [0 1 0]-0.5;
shapes{1}.shape_color = shape_color;

% circle
r=0.5;
theta = 0:0.1:2*pi;
shapes{2}.x = r*cos(theta);
shapes{2}.y = r*sin(theta);
shapes{2}.shape_color = shape_color;


%% occluder stripes
occluder_width = 0.2;
occluder_N = 5;

x = [0 0 occluder_width occluder_width]';
y = [-1 1 1 -1]';
x_tmp=[];
for i = 1:occluder_N
    x_tmp = [x_tmp x+occluder_width*2*(i-1)];
end
occluder{1}.x = x_tmp - occluder_width * (occluder_N*2 -1)/ 2;
occluder{1}.y = repmat(y, [1 5]);
occluder{1}.occluder_color = occluder_color;


%% draw
figure('position', [50 50 600 400]);
f(nframes) = struct('cdata',[],'colormap',[]);

for i = 1:nframes;
    % move shape
    
    shape = shapes{ishape};
    shape.x = shape.x + move_range * sin( (i-1)*2*pi / (FrameRate) * speed);
    draw_frame(shape, occluder{ioccluder}, bg);
    f(i) = getframe;
    
end

close(gcf);

v = VideoWriter(output_filename);
v.FrameRate = FrameRate;
open(v)
writeVideo(v,f)
close(v)


function draw_frame(shape, occluder, background)

clf(gcf)
axes('unit','normalized','position', [0 0 1 1]);
patch('xdata', shape.x, 'ydata', shape.y, 'EdgeColor', shape.shape_color, 'FaceColor',shape.shape_color);
hold on;
patch('xdata', occluder.x, 'ydata', occluder.y, 'EdgeColor',occluder.occluder_color, 'FaceColor',occluder.occluder_color);
hold off
set(gcf,'color', background.color)
axis equal
axis off
axis(background.range)



