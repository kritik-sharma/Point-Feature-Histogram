clear all;
clc;
%Normal finder
str='04217d002.asc';
N=load(str);
save
xyzPoints=load('matlab.mat');
ptCloud = pointCloud(xyzPoints.N);
%pcshow(ptCloud)
normals = pcnormals(ptCloud);
%pcshow(ptCloud)
%x = ptCloud.Location(:,1);
%y = ptCloud.Location(:,2);
%z = ptCloud.Location(:,3);
%u = normals(:,1);
%v = normals(:,2);
%w = normals(:,3);
%hold on
%quiver3(x,y,z,u,v,w);
%hold off
str=['N',str];
save(str,'normals','-ascii');