 function surf = surface(grains)
% calculates the area of the surface
%


n = normal(grains);

surf = sum(cellfun(@(c) sum(sqrt(sum(c.^2,2))),n),2);
surf = reshape(surf,size(grains));