function[validNode] = IsBifurcation(node,link,id,genNum)
    validNode = false;
    nodeNeighbours = node(id).links;
    goodNeighbour = 0;
    if length(nodeNeighbours) >= 3
        for j = 1: length(nodeNeighbours)
            if genNum >= 4
                if (node(link(nodeNeighbours(j)).n1).ep == 1 && ...
                    node(link(nodeNeighbours(j)).n2).ep == 0) || ...
                    (node(link(nodeNeighbours(j)).n1).ep == 0 && ...
                    node(link(nodeNeighbours(j)).n2).ep == 1)
                    goodNeighbour = goodNeighbour + 1;
                end
            else
                if node(link(nodeNeighbours(j)).n1).ep == 0 && ...
                    node(link(nodeNeighbours(j)).n2).ep == 0
                    goodNeighbour = goodNeighbour + 1;
                end
            end
        end
    end
    if genNum >= 4
        if goodNeighbour >= 2
            validNode = true;
        end
    else
        if goodNeighbour == 3
            validNode = true;
        end
    end
end