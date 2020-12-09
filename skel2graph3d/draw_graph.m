function [] = draw_graph(node, link, w, l, h)

% display result
figure();
hold on;
for i=1:length(node)
    x1 = node(i).comx;
    y1 = node(i).comy;
    z1 = node(i).comz;
    
    if(node(i).ep==1)
        ncol = 'c';
    else
        ncol = 'y';
    end
    
    for j=1:length(node(i).links)    % draw all connections of each node
%         if(node(node(i).conn(j)).ep==1)
%             link(j).colour = 'k'; %col='k'; % branches are black
%         else
%             link(j).colour = 'b'; %col='r'; % links are red
%         end
%         if(node(i).ep==1)
%             link(j).colour = 'k'; %col='k';
%         end

        
        % draw edges as lines using voxel positions
        for k=1:length(link(node(i).links(j)).point)-1            
            [x3,y3,z3]=ind2sub([w,l,h],link(node(i).links(j)).point(k));
            [x2,y2,z2]=ind2sub([w,l,h],link(node(i).links(j)).point(k+1));
            line([y3 y2],[x3 x2],[z3 z2],'Color',link(node(i).links(j)).colour,'LineWidth',2);
        end
    end
    
    % draw all nodes as yellow circles
    plot3(y1,x1,z1,'o','Markersize',9,...
        'MarkerFaceColor',ncol,...
        'Color','k');
    text(y1,x1,z1,string(i));
end
axis image;axis off;
set(gcf,'Color','white');
drawnow;
