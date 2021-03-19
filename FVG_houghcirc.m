function [ centers, radii, centers_new, radii_new, index_new ] = FVG_houghcirc( I_bw, d_fibre, s )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

r_max=round(d_fibre(2)/(2*s));
r_min=round(d_fibre(1)/(2*s));


[centers, radii, metric] = imfindcircles(I_bw,[r_min r_max],...
    'Sensitivity',0.97);% 'sensivity' > 0.97 not recommended

if ~isempty(centers)

%% find intersecting and interlaying circles
count=0;
for i=1:length(centers)
    for n=1:length(centers)
      [xout,yout] = circcirc(centers(i,1),centers(i,2),radii(i),...
          centers(n,1),centers(n,2),radii(n)); 
      % find intersecting circles
      if  norm([diff(xout);diff(yout)],2)>radii(i)
        count=count+1;
        index(count,:)=[i n];  
      % find interlaying circles
      elseif (pdist([centers(i,:);centers(n,:)])>0 && pdist([centers(i,:);centers(n,:)]) < radii(i))
        count=count+1;
        index(count, :)=[i n];
      else
      end
    end
end
%% compare intersecting circles by metric and intersection
if ~isempty(index)
for m=1:length(index)
  
        if metric(index(m,1))<metric(index(m,2)) % 
             index_dc(m)=index(m,1);
        else
            index_dc(m)=index(m,2);
        end   
end
else
end

index_new=unique(index_dc);
centers_new=centers;
radii_new=radii;
centers_new(unique(index_dc),:)=[];
radii_new(unique(index_dc))=[];
else
end
end

