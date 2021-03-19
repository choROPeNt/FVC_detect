function [ FVG, tri, index] = FVG_delaunay( I2, centers_new, radii_new, color, Str )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
figure,imshow(I2),title(Str),hold on
viscircles(centers_new, radii_new,'EdgeColor','white');

tri = delaunay(centers_new(:,1),centers_new(:,2));
% triplot(tri,centers(:,1),centers(:,2),'Color','red')

count=0;
for i=1:length(tri)
    %% calculate FVG
    % Area of Polygon or Triangle
    tri_area(i)=polyarea(centers_new(tri(i,:),1),centers_new(tri(i,:),2));
    
    % calculate angle between points
     a1 = atan2(2*tri_area(i),...
         dot([centers_new(tri(i,2),1);centers_new(tri(i,2),2)]-[centers_new(tri(i,1),1);centers_new(tri(i,1),2)],...
         [centers_new(tri(i,3),1);centers_new(tri(i,3),2)]-[centers_new(tri(i,1),1);centers_new(tri(i,1),2)]));
    
     a2 = atan2(2*tri_area(i),dot([centers_new(tri(i,1),1);centers_new(tri(i,1),2)]...
         -[centers_new(tri(i,2),1);centers_new(tri(i,2),2)],...
         [centers_new(tri(i,3),1);centers_new(tri(i,3),2)]-[centers_new(tri(i,2),1);centers_new(tri(i,2),2)]));
     
     a3 = pi-sum([a1 a2]);
     deg=10;
     %% dismiss distoreted triangles at boundaries
     if a1>deg/180*pi  && a2>deg/180*pi && a3>deg/180*pi
     count=count+1;
     % calculate area of circles
     circ_area1=pi*radii_new(tri(i,1))^2*a1/(2*pi);
     circ_area2=pi*radii_new(tri(i,2))^2*a2/(2*pi);
     circ_area3=pi*radii_new(tri(i,3))^2*a3/(2*pi);

     FVG(count)=sum([circ_area1 circ_area2 circ_area3])/tri_area(i);
     
     
     
     
     %% Ploting
     if FVG(count)< 0.9069
     p=patch(centers_new(tri(i,:),1),centers_new(tri(i,:),2),color(round(FVG(count)*64),:),...
            'FaceAlpha',.5);
     else
       p=patch(centers_new(tri(i,:),1),centers_new(tri(i,:),2),[0 0 0]); 
       index=i;
     end
         
    % add number 
%         text(centers(i,1),centers(i,2),num2str(count),'HorizontalAlignment','center','FontSize',20)    
     else
     end
end
hold off
end

