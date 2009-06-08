cs = symmetry('6mm');
ss = symmetry('mmm');

q1 = axis2quat(xvector+zvector,40*degree);
q2 = axis2quat(vector3d(1,2,1),70*degree);
q3 = axis2quat(xvector-2*zvector,20*degree);

odf = 0.5*unimodalODF(q1,cs,ss) + ...
  0.5*fibreODF(Miller(1,1,0),vector3d(1,3,1),cs,ss)+...
  2*unimodalODF(q2,cs,ss) + ...
  0.5*unimodalODF(q3,cs,ss);

%%
plotpdf(odf,[Miller(1,0,0),Miller(1,1,1),Miller(0,0,1),Miller(1,1,0)],'gray','contourf','antipodal')
%%
plotipdf(odf,[xvector,yvector,vector3d(1,1,1)],'complete')

%% 

annotate([q1,q2,q3,q])


%%

q = modalOrientation(odf)

%%
figure(2)
plotodf(odf,'gray','complete')

%%

plotodf(odf,'alpha','projection','plain','sections',5)

%%

annotate([q1,q2,q3,q],'MarkerSize',30,'MarkerFaceColor','none','MarkerEdgeColor','w')

%%

annotate(q)
