function n = normal(grains)
% face normal of polyeder


n = cell(size(grains,1),1);

F = get(grains,'F');
V = get(grains,'V');

I_FD = get(grains, 'I_FDext') + get(grains, 'I_FDsub');
I_FG = I_FD * get(grains,'I_DG');

[f,g,orientation] = find(I_FG);

F = F(f,:);

n = mat2cell(bsxfun(@times,cross(V(F(:,1),:)-V(F(:,2),:),V(F(:,1),:)-V(F(:,3),:)),orientation),sum(I_FG~=0,1),3);
if size(F,2)>3
  n(:,2) = mat2cell(bsxfun(@times,cross(V(F(:,3),:)-V(F(:,4),:),V(F(:,3),:)-V(F(:,1),:)),orientation),sum(I_FG~=0,1),3);
end

n(any(cellfun('isempty',n),2),:) = [];
