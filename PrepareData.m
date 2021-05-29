function [dataset, inputs, targets] = PrepareData(isTrain, isShort, normalize, leaveFake)

data = ReadBES3Data(isTrain, isShort, normalize);

count = 11;
if leaveFake
    count = 400;
end
dataset = zeros(size(data, 1), count);

dataId = 1;

GroupApply("event", data, @EventIterate);

dataset = dataset(1:dataId-1, :);
inputs = dataset(:, 3:end-3);
targets = dataset(:, end-2:end);

function AddToDataset(event_id, group, slice)
    if leaveFake || ((group ~= -1) && (size(slice, 1) == 3))
        if ((group ~= -1) && (size(slice, 1) ~= 3))
            return;
        end
        dataset(dataId, 1) = event_id;
        dataset(dataId, 2) = group;
        %input = [slice.x, slice.y, slize.z];
        input = [slice.x(1:end-1), slice.y(1:end-1), slice.z(1:end-1)];
        tgt = [slice.x(end), slice.y(end), slice.z(end)];
        data_arr = reshape(input,[1,length(slice.x)*3 - 3]);
        
        dataset(dataId, 3:size(data_arr, 2)+2) = data_arr;
        dataset(dataId, size(data_arr, 2)+3:size(data_arr, 2)+5) = tgt;
        dataId = dataId + 1;
    end
end

function EventIterate(event_id, single_event)
    GroupApply("track", single_event, PartialFunc(@AddToDataset, event_id));
end

end

