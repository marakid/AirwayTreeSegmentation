function[skelLabeled] = GraphLabeling(skel)
    %convert to graph
    [~,node,link] = Skel2Graph3D(skel,0);
    w = size(skel,1);
    l = size(skel,2);
    h = size(skel,3);
    draw_graph(node, link, w, l, h);

    start_node = input("The starting node is:");
    need = input("Starting node connects to the first bifurcation node (1 - true, 0 - false):");

    [skelLabeled,node2,link2,gnum,firstId] = GenerationLabels(skel,node,link, start_node, need);
    
    niftiwrite(skelLabeled, 'SkeletonGenerationLabeled.nii');
end