function graphOut = BuildTrackNetV2Model(show)

    mainLayers = [
        featureInputLayer(6, 'Name', 'Input')
        fullyConnectedLayer(32, 'Name','fc')
        fullyConnectedLayer(32, 'Name','gru1')
        fullyConnectedLayer(16, 'Name','gru2')];

    ellipse = [
        fullyConnectedLayer(2, 'Name','fc_ellipsecenter')
        ];
    
    radius = [fullyConnectedLayer(2, 'Name','fc_r1r2')
        softplusLayer('name', 'softplus_r1r2')];

    concat = [concatenationLayer(1,2,'Name','concat')
        %,regressionLayer('Name','out')
        ]

    lgraph = layerGraph(mainLayers);

    lgraph = addLayers(lgraph,ellipse);
    lgraph = addLayers(lgraph,radius);
    lgraph = addLayers(lgraph,concat);

    lgraph = connectLayers(lgraph,'gru2','fc_ellipsecenter'); 
    lgraph = connectLayers(lgraph,'gru2','fc_r1r2'); 
    lgraph = connectLayers(lgraph,'fc_ellipsecenter','concat/in1'); 
    lgraph = connectLayers(lgraph,'softplus_r1r2','concat/in2'); 

    graphOut = lgraph;
    if show
        plot(lgraph);
        analyzeNetwork(graphOut,'TargetUsage','dlnetwork')
    end
end
%lgraph = connectLayers(lgraph,'gnBranch2','add/in2');  