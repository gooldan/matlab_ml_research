
lgraph = BuildTrackNetV2Model(false);

X = randn(6,5);
dlX = dlarray(X, "CB");


%dlX2 = dlarray(rand([6, 20]),"SB");

dlnet = dlnetwork(lgraph, dlX);

numEpochs = 2000;

figure
lineLossTrain = animatedline('Color',[0.85 0.325 0.098]);
ylim([0 inf])
set(gca, 'YScale', 'log')
xlabel("Iteration")
ylabel("Loss")
grid on

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
        [dlX, dlY] = nextData(inputsT, targetsT);
        
        % Evaluate the model gradients, state, and loss using dlfeval and the
        % modelGradients function and update the network state.
        [gradients,state,loss] = dlfeval(@modelGradients,dlnet,dlX,dlY);
        dlnet.State = state;        
      
        % Update the network parameters using the SGDM optimizer.
        [dlnet,averageGrad,averageSqGrad] = adamupdate(dlnet,gradients,averageGrad,averageSqGrad,iteration);
        
        % Display the training progress.
        D = duration(0,0,toc(start),'Format','hh:mm:ss');
        addpoints(lineLossTrain,iteration,loss)
        title("Epoch: " + epoch + ", Elapsed: " + string(D))
        drawnow
    end
end


function [X, Y]= nextData(arrX, arrY)
    X = dlarray(arrX(:, 1:8), "CB");
    Y = dlarray(arrY(:, 1:8), "CB");
end


function [gradients,state,loss] = modelGradients(dlnet,dlX,Y)

[dlYPred,state] = forward(dlnet,dlX);

loss = mse(dlYPred(1:2, :), Y(1:2, :));
gradients = dlgradient(loss,dlnet.Learnables);

loss = double(gather(extractdata(loss)));

end




