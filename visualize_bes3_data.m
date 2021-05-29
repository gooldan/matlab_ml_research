function visualize_bes3_data()

allColors = ['y', 'm', 'c', 'r', 'g', 'b'];
curColor = 1;
function col = getColor()
    col = allColors(curColor);
    curColor = curColor + 1;
end

function pc_Draw(xyz, color, size)
% MYMEAN Example of a local function.
    scatter3(xyz.x,xyz.y,xyz.z, size, color);
    legend("test")
    hold on    
end

%data = readtable("C:\Users\egor\dubna\ariadne\data_bes3\210.txt"
data = ReadBES3Data(true, true, false);

%figure;
%pcshow([data.x,data.y,data.z]);
%title('First 1000 events');
%xlabel('X');
%ylabel('Y');
%zlabel('Z');

single = data(data.event == 0, :);




figure;
unique_track_ids = unique(single.track);
legends = {};

for ii = 1:length(unique_track_ids)
    track_id = unique_track_ids(ii);

    if track_id == -1
        color = 'k';
        size = 15;
    else
        color = getColor();
        size = 30;
    end
    trackPts = single(single.track == track_id, :);
    pc_Draw(trackPts, color, size);
    legends(ii) = {"Track id: " + track_id};
    
end
legend([legends])
set(gcf,'color','w');
set(gca,'color','w');
set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])    
title('Single event');
xlabel('X');
ylabel('Y');
zlabel('Z');



end