function visualize_trained()

allColors = ['y', 'm', 'c', 'r', 'g', 'b'];
curColor = 1;
function col = getColor()
    col = allColors(curColor);
    curColor = curColor + 1;
end

function ret = plotCircle3D(center,normal,radius)
theta=0:0.01:2*pi;
v=null(normal);
points=repmat(center',1,length(theta))+radius*(v(:,1)*cos(theta)+v(:,2)*sin(theta));
ret = plot3(points(1,:),points(2,:),points(3,:),'r-', 'DisplayName', 'Predicted Ellipse');
end

function ret = pc_Draw(xyz, color, size, name)
% MYMEAN Example of a local function.
    ret = scatter3(xyz(:, 1),xyz(:, 2),xyz(:, 3), size, color, 'DisplayName',name);
    hold on    
end

function line_Draw(xyz, color)
% MYMEAN Example of a local function.
    plot3(xyz(:, 1),xyz(:, 2),xyz(:, 3), "-"+color, 'LineWidth', 0.8);
    hold on    
end

%data = readtable("C:\Users\egor\dubna\ariadne\data_bes3\210.txt"
data = PrepareData(false, false, true, true);

%figure;
%pcshow([data.x,data.y,data.z]);
%title('First 1000 events');
%xlabel('X');
%ylabel('Y');
%zlabel('Z');

single = data(data(:, 1) == 24000, :)


global TEST
figure;

legends = {};
leg = [];
for ii = 1:length(single(:, 2))
    track_row = single(ii, :);
    track_id = track_row(1, 2);
    if track_id == -1
        track_row = track_row(:, track_row ~= 0);
        track_row = track_row(:, 3:end);
        real_len = length(track_row) / 3;
        x = track_row(:, 1:real_len);
        y = track_row(:, real_len+1:2*real_len);
        z = track_row(:, 2*real_len+1:end);
        xyz = [x; y; z];
        color = 'k';
        size = 15;
        a = pc_Draw(xyz.', color, size, "Track id: " + track_id);
        leg = [leg a];
        continue;
    end
    in_data = track_row(:, 3:8);
    real_row = [track_row(:, 3:4), track_row(:, 9), track_row(:, 5:6), track_row(:, 10), track_row(:, 7:8), track_row(:, 11)];
    
    xyz = reshape(real_row, [3 3]);
    
    xyz_In = dlarray(in_data, "C");
    pred = predict(TEST, xyz_In);    
    
    color = getColor();
    xPred = double(gather(extractdata(pred(1, :))));
    yPred = double(gather(extractdata(pred(2, :))));

    r1Pred = (pred(3, :));
    r2Pred = (pred(4, :));
    r1Corr = double(gather(extractdata(log(1 + exp(r1Pred)))));
    r2Corr = double(gather(extractdata(log(1 + exp(r2Pred)))));
    
    normal = xyz(3, :) - xyz(2, :);
    normal = normal./norm(normal);
    plotCircle3D([xPred, xyz(3, 2), yPred], normal, max(r1Corr, r2Corr));
    size = 30;
    pc_Draw([[xPred], [xyz(3, 2)], [yPred]], 'r', 20, "Track id: " + track_id);
    
    a = pc_Draw(xyz, color, size, "Track id: " + track_id);
    leg = [leg a];
    %legend("Track id: " + track_row(1, 2))
    
    
    line_Draw(xyz, color);
    
    %legends(ii) = {"Track id: " + track_row(1, 2)};
    
end
legend(leg)
set(gcf,'color','w');
set(gca,'color','w');
set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])    
title('Single event');
xlabel('X');
ylabel('Y');
zlabel('Z');



end