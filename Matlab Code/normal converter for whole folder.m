clear all; clc;close all;
data_set = 'D:\50_set\';
addpath(data_set);
data_1 = (dir(fullfile(data_set,'*.asc')));
data_1 = {data_1(~[data_1.isdir]).name};
for j = 1:length(dir(fullfile(data_set,'*.asc')))
a = char(data_1(j));
X = load(data_1{j});
save
X=X';
filename=[a([1:9]),'.pcd'];
savepcd(filename,X);
xyzPoints=load('matlab.mat');
ptCloud = pointCloud(xyzPoints.X);
normals = pcnormals(ptCloud);
str=['N',a]
save(str,'normals','-ascii');
normals=normals';
filename1=['N',a([1:9]),'.pcd'];
nsavepcd(filename1,normals);
delete matlab.mat
clear('a','X','filename','filename1','xyzPoints','ptCloud','normals','str','normals');
end