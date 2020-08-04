clear all;clc;close all;

data_set = 'D:\Studies\BTP\test\Data_testing\';
addpath(data_set);
data_1 = (dir(fullfile(data_set,'*.asc')));
data_1 = {data_1(~[data_1.isdir]).name};
data_set2 = 'D:\Studies\BTP\test\Data_training\';
addpath(data_set2);
data_2 = (dir(fullfile(data_set2,'*.asc')));
data_2 = {data_2(~[data_2.isdir]).name};
data_set3 = 'D:\Studies\BTP\test\Data_testing\saline\';
addpath(data_set3);
data_3 = (dir(fullfile(data_set3,'*.mat')));
data_3 = {data_3(~[data_3.isdir]).name};
data_set4 = 'D:\Studies\BTP\test\Data_training\saline\';
addpath(data_set4);
data_4 = (dir(fullfile(data_set4,'*.mat')));
data_4 = {data_4(~[data_4.isdir]).name};
for j = 1:length(dir(fullfile(data_set,'*.asc')))
    a = char(data_1(j));
    N = load(data_1{j});
    idx1 = load(data_3{j});
    idx1=idx1.idx;
    p = N(idx1(:),:);
    samp1=a(1:5);
    for jl = 1:length(dir(fullfile(data_set2,'*.asc')))
    	b = char(data_2(jl));
    	M = load(data_2{jl});
    	idx2 = load(data_4{jl});
    	idx2=idx2.idx;
    	q = M(idx2(:),:);
    	[t,n]=size(q);
		[TR,TT]=icp(q',p');
		p=TR*p'+TT;
		p=p';
		[n,d] = knnsearch(p,q,'k',10);
		[IdxCb1,DCb1] = knnsearch(p,q,'k',10,'Distance','Euclidean');
		for i=1:t
			check(i,1)=DCb1(i,1)/DCb1(i,2);
			check(i,2)=IdxCb1(i,1);
			check(i,3)=i;
		end
		for i=1:t
			check(i,1)=DCb1(i,1)/DCb1(i,2);
			if check(i,1)>0.8
				check(i,:)=NaN;
			end	
		end
		i=1;
		while i<=t
			if isnan(check(i,1))
				check(i,:)=[];
				t=t-1;i=i-1;
			end
			i=i+1;
		end
		samp2=b(1:5);
		filename=[a([1:9]),'-',b([1:9])];
		if not(strcmp(samp1,samp2))
			filename=['d',filename];
			save(filename,'check');
		else
			filename=['s',filename];
			save(filename,'check');
		end
		clear('check','samp2','IdxCb1','DCb1','TR','TT','b','M','idx2');
 	end
 	clear('a','N','idx1','p','samp1');
 end