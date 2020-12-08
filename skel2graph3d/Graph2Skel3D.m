function skel = Graph2Skel3D(node,link,w,l,h,color)

if(~color)
    % create binary image
    skel = false(w,l,h);

    % for all nodes
    for i=1:length(node)
        if(~isempty(node(i).links)) % if node has links
            skel(node(i).idx)=true; % node voxels
            a = [link(node(i).links(node(i).links>0)).point];
            if(~isempty(a))
                skel(a)=1; % edge voxels
            end
        end
    end
else
    %create RBG image
    skel = zeros(w, l, h);
    sz = [w, l, h];
    
    % for all nodes
    for i=1:length(node)
        if(~isempty(node(i).links)) % if node has links
            [M, N, P] = ind2sub(sz, node(i).idx);
            skel(M, N, P) = node(i).gen;
            for j = 1 : length(node(i).links)
                a = [link(node(i).links(j)).point];
                r = link(node(i).links(j)).gen;
                if(~isempty(a))
                    for k = 1: length(a)
                        [X, Y, Z] = ind2sub(sz, a(k));
                        skel(X, Y, Z) = r;
                    end
                end
            end
        end
    end
end

