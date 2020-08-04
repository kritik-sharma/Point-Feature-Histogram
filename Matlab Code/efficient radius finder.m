clear all; clc;close all;

data_set = 'D:\pfh\';
addpath(data_set);
data_1 = (dir(fullfile(data_set,'*.asc')));
data_1 = {data_1(~[data_1.isdir]).name};
value(length(dir(fullfile(data_set,'*.asc'))))=0;
for j = 1:length(dir(fullfile(data_set,'*.asc')))
    a = char(data_1(j));
    X = load(data_1{j});
    [m,n]=size(X);
    magnitude(m,m)=0;
    for x=1:m
        for y=1:m
            for z=1:125
                magnitude(x,y)=magnitude(x,y)+((X(x,z)-X(y,z))*(X(x,z)-X(y,z)));
            end
            magnitude(x,y)=sqrt(magnitude(x,y));
        end
    end
    T=unique(magnitude);
    [p,o]=size(T);
    value(j)=o*p/m;
    clear('p','m','magnitude','T','x','y','z','a','X','o');
 end
 [maxvalue,index]=max(value);