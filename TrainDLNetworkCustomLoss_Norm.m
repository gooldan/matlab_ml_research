
lgraph = BuildTrackNetV2Model(false);

X = randn(6,5);
dlX = dlarray(X, "CB");


%dlX2 = dlarray(rand([6, 20]),"SB");

dlnet = dlnetwork(lgraph, dlX);

numEpochs = 20;
BATCH_SIZE = 256;

figure
lineLossTrain = animatedline('Color',[0.85 0.325 0.098], 'DisplayName', 'Loss');
lineEllipseTrain = animatedline('Color',[0.15 0.125 0.298], 'DisplayName', 'Ellipse Center Err');
lineSquareTrain = animatedline('Color',[0.45 0.025 0.998], 'DisplayName', 'Ellipse Square');
lineMSETrain = animatedline('Color',[0.0 0.888 0.0], 'DisplayName', 'MSE center');

lineLossEval = animatedline('Color',[0.85 0.0 0.998], 'DisplayName', 'Eval Loss');
linemseEVAL = animatedline('Color',[0, 0.85 0.998], 'DisplayName', 'Eval MSE');

ylim([0 inf])
set(gca, 'YScale', 'log')
xlabel("Iteration")
ylabel("Loss")
grid on



counter = 1;
evalCounter = 1;
iteration = 0;
start = tic;

averageGrad = [];
averageSqGrad = [];

% Loop over epochs.
for epoch = 1:numEpochs
    % Shuffle data.
    %shuffle(mbq);
    
    % Loop over mini-batches.
    evalStart = iteration;

    while true
        iteration = iteration + 1;
        
        % Read mini-batch of data.
        [dlX, dlY, counter, endEpoch] = getData(inputsT, targetsT, counter,BATCH_SIZE);
        if endEpoch
            break;
        end
        % Evaluate the model gradients, state, and loss using dlfeval and the
        % modelGradients function and update the network state.
        [gradients,state,loss, el, sq, ms_e] = dlfeval(@modelGradients,dlnet,dlX,dlY);
        dlnet.State = state;        
      
        % Update the network parameters using the SGDM optimizer.
        [dlnet,averageGrad,averageSqGrad] = adamupdate(dlnet,gradients,averageGrad,averageSqGrad,iteration);
        
        % Display the training progress.
        D = duration(0,0,toc(start),'Format','hh:mm:ss');
        addpoints(lineLossTrain,iteration,loss)
        elip = double(gather(extractdata(el)));
        addpoints(lineEllipseTrain,iteration,elip)
        squar = double(gather(extractdata(sq)));
        addpoints(lineSquareTrain,iteration,squar)
        ms_er = double(gather(extractdata(ms_e)));
        addpoints(lineMSETrain,iteration,ms_er)
        title("Epoch: " + epoch + ", Elapsed: " + string(D) + ", Loss: " + loss ...
                + ", Square: " + elip + ", Center: " + squar + ", MSE: " + ms_er);
        legend
        drawnow
    end
    
    while true
        [dlX, dlY, evalCounter, endEpoch] = getData(inputsE, targetsE, evalCounter, BATCH_SIZE);
        if endEpoch
            break;
        end
        dlYPred = predict(dlnet,dlX);
        [loss_t, ~, ~, mse_o_t] = lossFunc(dlYPred, dlY);
        loss = double(gather(extractdata(loss_t)));
        mse_o = double(gather(extractdata(mse_o_t)));
        
        D = duration(0,0,toc(start),'Format','hh:mm:ss');
        addpoints(lineLossEval,evalStart,loss)
        addpoints(linemseEVAL,evalStart,mse_o)
        title("EVAL. Epoch: " + epoch + ", Elapsed: " + string(D) + ", Loss: " + loss);
        legend
        drawnow
        evalStart = evalStart+1;
    end
    
end

global TEST;
TEST = dlnet;

function [X, Y, counter, endEpoch] = getData(inputs, targets, counter, BATCH_SIZE)

function [X, Y] = nextData(arrX, arrY, off)
    X = dlarray(arrX(:, off:off+BATCH_SIZE), "CB");
    Y = dlarray(arrY(:, off:off+BATCH_SIZE), "CB");
end

    if counter + BATCH_SIZE*2 >= size(inputs,2)
        counter = 1;
        endEpoch= true;
    else
        counter = counter + BATCH_SIZE;
        endEpoch = false;
    end
    [X, Y] = nextData(inputs, targets, counter);
end

function [loss, ellipse_center_loss, ellipse_square_loss, mse_o] = lossFunc(pred, Y)

xPred = pred(1, :);
yPred = pred(2, :);

r1Pred = (pred(3, :));
r2Pred = (pred(4, :));

r1Corr = log(1 + exp(r1Pred));
r2Corr = log(1 + exp(r2Pred));

xT = Y(1, :);
yT = Y(3, :);

ellipse_center_loss = mean((((xPred - xT) ./ r1Corr).^2 + ((yPred - yT) ./ r2Corr).^2).^(0.5));

ellipse_square_loss = sum(r1Corr .* r2Corr);
mse_o = mse(pred(1:2, :), [Y(1, :); Y(3, :)]);

loss = 0.1 * ellipse_square_loss + 0.9 * ellipse_center_loss;

end

function [gradients,state,loss, ellipse_center_loss, ellipse_square_loss, mse_o] = modelGradients(dlnet,dlX,Y)

[dlYPred,state] = forward(dlnet,dlX);

[loss, ellipse_center_loss, ellipse_square_loss, mse_o] = lossFunc(dlYPred, Y);

gradients = dlgradient(loss,dlnet.Learnables);

loss = double(gather(extractdata(loss)));

end




