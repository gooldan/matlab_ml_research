function [dataset, inputs, targets] = PrepareData(isTrain, isShort)

data = ReadBES3Data(isTrain, isShort);

dataset = zeros(size(data, 1), 11);

dataId = 1;

GroupApply("event", data, @EventIterate);

dataset = dataset(1:dataId-1, :);
inputs = dataset(:, 3:end-3);
targets = dataset(:, end-2:end);

function AddToDataset(event_id, group, slice)
    if (group ~= -1) && (size(slice, 1) == 3)
        dataset(dataId, 1) = event_id;
        dataset(dataId, 2) = group;
        dataset(dataId, 3:end) = reshape([slice.x, slice.y, slice.z],[1,9]);
        dataId = dataId + 1;
    end
end

function EventIterate(event_id, single_event)
    GroupApply("track", single_event, PartialFunc(@AddToDataset, event_id));
end

end

