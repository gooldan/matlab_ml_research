function result = ReadBES3Data(train, short, normalize)
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
    if normalize
        x = [-166.6 166.6];
        y = [-166.6, 166.6];
        z = [-423.5, 423.5];
        
        x_norm = 2 * (result.x - x(1)) / (x(2) - x(1)) - 1;
        y_norm = 2 * (result.y - y(1)) / (y(2) - y(1)) - 1;
        z_norm = 2 * (result.z - z(1)) / (z(2) - z(1)) - 1;
        assert(max(x_norm) < 1 && min(x_norm) > -1)
        assert(max(y_norm) < 1 && min(y_norm) > -1)
        assert(max(z_norm) < 1 && min(z_norm) > -1)
        phi = atan2(y_norm, x_norm);
        r = sqrt(x_norm.^2 + y_norm.^2);
        result.x = phi;
        result.y = r;
        result.z = z_norm;
    end
end