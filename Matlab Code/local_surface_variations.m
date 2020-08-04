clear all; clc;close all;

data_set = 'C:\Users\Kritik Sharma\OneDrive\Desktop\Point\';
addpath(data_set);
data_1 = (dir(fullfile(data_set,'*.asc')));
data_1 = {data_1(~[data_1.isdir]).name};

for j = 1:length(dir(fullfile(data_set,'*.asc')))
    a = char(data_1(j));
    X = load(data_1{j});
    %X=load('04213d001.asc');
    X=X';
    X = X - repmat(mean(X,2),1,length(X));
    
    for i = 1:length(X)
        I=nearestneighbour(X(:,i),X,'n',15);
        %I = knnsearch(X',X','k',15);
        %x1 = X(:,I(i,:));
        x1 = X(:,I);
        x1 = x1 - repmat(mean(x1,2),1,length(x1));
        covar_iance = x1*x1';
        [eig_vec,eig_val] = eig(covar_iance);
        lamda = diag(eig_val);
        surf_var(i) = lamda(1)/sum(lamda);
    end
    
    [val,idx] = find(surf_var>0.08);
    ftr_pts = X(:,idx);
    %%%%%
%     plot3(X(1,:),X(2,:),X(3,:),'.r')
%     hold on
%     plot3(ftr_pts(1,:),ftr_pts(2,:),ftr_pts(3,:),'ob')
    %%%%%
    a=a(1:9);
    a=['ftr_pt',a];
    %filename = ['ftr_pts',num2str(j),'.mat'];
    save(a,'idx')
    clear ftr_pts X surf_var
 end