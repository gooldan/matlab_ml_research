function result = ReadBES3Data(path)
    %pathToFile = "C:\Users\egor\dubna\ariadne\data_bes3\210.txt";
    opts = detectImportOptions(path);
    opts.VariableNames =  {'event',  'x', 'y', 'z', 'station','track', 'px', 'py', 'pz', 'X0', 'Y0', 'Z0'};
    opts.DataLines = [1 46072];
    result = readtable("C:\Users\egor\dubna\ariadne\data_bes3\210.txt", opts);
    result = result(:,1:6);
end