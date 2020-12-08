function [skel2,node,link,gnum,firstId] = GenerationLabels(skel,node,link, startingNode, needFirst)
    firstId = 0;
    genNum = 1;
    currentNodeListIdx = [];
    currentNodeListIdx = [currentNodeListIdx, startingNode];
    goOn = true;
    colorList = ['r', 'g', 'b', 'c', 'm'];
    colorIndex = 1;

    if needFirst == 1
        if link(node(startingNode).links).n1 ~= startingNode
            firstId = link(node(startingNode).links).n1;
        else
            firstId = link(node(startingNode).links).n2;
        end
    end
    
    while goOn
        nodeList = [];
        for i = 1: length(currentNodeListIdx)
            
            if length(currentNodeListIdx) >= 2
                for k=1:length(node(currentNodeListIdx(i)).links)
                    linkId = node(currentNodeListIdx(i)).links(k);
                    if (link(linkId).n1 == currentNodeListIdx(i) && ...
                            node(link(linkId).n2).beenThere == true) || ...
                            (link(linkId).n2 == currentNodeListIdx(i) && ...
                            node(link(linkId).n1).beenThere == true)
                        genNum = link(linkId).gen;
                        colorIndex = find(colorList == link(linkId).colour);
                    end
                end
            end

            if (needFirst == 1 && currentNodeListIdx(i) == firstId) || ...
                    IsBifurcation(node, link, currentNodeListIdx(i), genNum)
                genNum = genNum + 1;
                if (colorIndex == length(colorList))
                    colorIndex = 1;
                else
                    colorIndex = colorIndex + 1;
                end
            end

            node(currentNodeListIdx(i)).gen = genNum;
            node(currentNodeListIdx(i)).beenThere = true;
            linkList = [];
            for j=1:length(node(currentNodeListIdx(i)).links)
                linkIdx = node(currentNodeListIdx(i)).links(j);
                if link(linkIdx).gen == 0
                   link(linkIdx).gen = genNum;
                   link(linkIdx).colour = colorList(colorIndex);
                   link(linkIdx).beenThere = true;
                   linkList = [linkList, linkIdx];
                end
            end
            
            for k = 1: length(linkList)
                if(link(linkList(k)).n1 ~= currentNodeListIdx(i))
                    if (node(link(linkList(k)).n1).ep ~= 1)
                        nodeList = [nodeList, link(linkList(k)).n1];
                    end
                elseif(link(linkList(k)).n2 ~= currentNodeListIdx(i))
                    if (node(link(linkList(k)).n2).ep ~= 1)
                        nodeList = [nodeList, link(linkList(k)).n2];
                    end
                end
            end
        end
        currentNodeListIdx = nodeList;
        if(isempty(currentNodeListIdx))
            goOn = false;
        end
    end
    
    gnum = genNum;
    w2 = size(skel,1);
    l2 = size(skel,2);
    h2 = size(skel,3);
    skel2 = Graph2Skel3D(node,link,w2,l2,h2, true);

end