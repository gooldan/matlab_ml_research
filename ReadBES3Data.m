function result = ReadBES3Data(train, short)
    %pathToFile = "C:\Users\egor\dubna\ariadne\data_bes3\train.txt";
    path = "C:\Users\egor\dubna\ariadne\data_bes3\test.txt";
    if train
        path = "C:\Users\egor\dubna\ariadne\data_bes3\train.txt";
    end
    opts = detectImportOptions(path);
    opts.VariableNames =  {'event',  'x', 'y', 'z', 'station','track', 'px', 'py', 'pz', 'X0', 'Y0', 'Z0'};
    if short
        opts.DataLines = [1 46072];
    end
    result = readtable(path, opts);
    result = result(:,1:6);
end