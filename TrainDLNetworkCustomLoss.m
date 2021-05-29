
lgraph = BuildTrackNetV2Model(false);

X = randn(6,5);
dlX = dlarray(X, "CB");


%dlX2 = dlarray(rand([6, 20]),"SB");

dlnet = dlnetwork(lgraph, dlX);

numEpochs = 2000;
BATCH_SIZE = 8;

figure
lineLossTrain = animatedline('Color',[0.85 0.325 0.098], 'DisplayName', 'Loss');
lineEllipseTrain = animatedline('Color',[0.15 0.125 0.298], 'DisplayName', 'Ellipse Center Err');
lineSquareTrain = animatedline('Color',[0.45 0.025 0.998], 'DisplayName', 'Ellipse Square');
lineMSETrain = animatedline('Color',[0.0 0.888 0.0], 'DisplayName', 'MSE center');
ylim([0 inf])
set(gca, 'YScale', 'log')
xlabel("Iteration")
ylabel("Loss")
grid on

counter = 1;
iteration = 0;
start = tic;

averageGrad = [];
averageSqGrad = [];

% Loop over epochs.
for epoch = 1:numEpochs
    % Shuffle data.
    %shuffle(mbq);
    
    % Loop over mini-batches.
    if true
        iteration = iteration + 1;
        
        % Read mini-batch of data.
        [dlX, dlY, counter] = getData(inputsT, targetsT, counter,BATCH_SIZE);
        
        % Evaluate the model gradients, state, and loss using dlfeval and the
        % modelGradients function and update the network state.
        [gradients,state,loss, el, sq, ms_e] = dlfeval(@modelGradients,dlnet,dlX,dlY);
        dlnet.State = state;        
      
        % Update the network parameters using the SGDM optimizer.
        [dlnet,averageGrad,averageSqGrad] = adamupdate(dlnet,gradients,averageGrad,averageSqGrad,iteration);
        
        % Display the training progress.
        D = duration(0,0,toc(start),'Format','hh:mm:ss');
        addpoints(lineLossTrain,iteration,loss)
        addpoints(lineEllipseTrain,iteration,double(gather(extractdata(el))))
        addpoints(lineSquareTrain,iteration,double(gather(extractdata(sq))))
        addpoints(lineMSETrain,iteration,double(gather(extractdata(ms_e))))
        title("Epoch: " + epoch + ", Elapsed: " + string(D))
        legend
        drawnow
    end
end

function [X, Y, counter] = getData(inputs, targets, counter, BATCH_SIZE)

function [X, Y] = nextData(arrX, arrY, off)
    X = dlarray(arrX(:, off:off+BATCH_SIZE), "CB");
    Y = dlarray(arrY(:, off:off+BATCH_SIZE), "CB");
end

    if counter + BATCH_SIZE >= size(inputs,2)
        counter = 1;
    else
        counter = counter + BATCH_SIZE;
    end
    [X, Y] = nextData(inputs, targets, counter);
end



function [gradients,state,loss, ellipse_center_loss, ellipse_square_loss, mse_o] = modelGradients(dlnet,dlX,Y)

[dlYPred,state] = forward(dlnet,dlX);

xPred = dlYPred(1, :);
yPred = dlYPred(2, :);

r1Pred = (dlYPred(3, :));
r2Pred = (dlYPred(4, :));

r1Corr = log(1 + exp(r1Pred));
r2Corr = log(1 + exp(r2Pred));

xT = Y(1, :);
yT = Y(2, :);

ellipse_center_loss = mean((((xPred - xT) ./ r1Corr).^2 + ((yPred - yT) ./ r2Corr).^2).^(0.5));

ellipse_square_loss = sum(r1Corr .* r2Corr);
mse_o = mse(dlYPred(1:2, :), [Y(1, :); Y(3, :)]);

loss = ellipse_square_loss + ellipse_center_loss;


gradients = dlgradient(loss,dlnet.Learnables);

loss = double(gather(extractdata(loss)));

end




