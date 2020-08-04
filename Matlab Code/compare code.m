clear all; clc;close all;

data_set1 = 'D:/today/PFH/';
addpath(data_set1);
data_set2 = 'D:/today/PFH/';
addpath(data_set2);
data_1 = (dir(fullfile(data_set1,'*.asc')));
data_1 = {data_1(~[data_1.isdir]).name};
data_2 = (dir(fullfile(data_set1,'*.asc')));
data_2 = {data_1(~[data_2.isdir]).name};
compare(length(dir(fullfile(data_set,'*.asc'))),length(dir(fullfile(data_set,'*.asc'))))=0;
for i = 1:1
	a = char(data_1(i));
	histomodel=load(data_1{i});
    for j = 4:4
        b = char(data_1(j));
		histotest=load(data_1{j});
        [m,lol]=size(histomodel);
        [n,lol]=size(histotest);
        if m>n
        histo=histomodel;
        clear('histomodel');
        histomodel=histotest;
        clear('histotest');
        histotest=histo;
        clear histo;
        end
        Index=0;
        Index2=0;
        tempc1=0;
        tempc2=0;
        faans=0;
        check=0;
        to=1;
        [m,lol]=size(histomodel);
        [n,lol]=size(histotest);
        for t=1:m
        	[p,n] = size(histotest);
        	clear('aans');
        	aans(p)=0;
        	for l=1:p
        		numer=0;
        		denom=0;
        		clear('temp');
        		temp=histotest;
        		for k=1:125 
        			numer=numer+((histomodel(t,k)-histotest(l,k))*(histomodel(t,k)-histotest(l,k)));
        		end
        		aans(l)=sqrt(numer);
        	end
        	[M,I1] = min(aans);
        	m1=M;
        	tempc1=I1;
        	temp(I1,:)=[];
        	[M,I2] = min(aans);
        	m2=M;
        	tempc2=I2;
        	temp(I2,:)=[];
        	if	m1==0
        		check=0;
        	else 
        		if m2~=0
        			check=m1/m2;
        		end
        	end
        	if	check<0.9
        		faans=faans+m1;
        		Index(to,1)=t;
        		Index2(to,1)=tempc1;
        		to=to+1;
        	end
        end      
        compare(i,j)=(to-1)/m;
        compare(j,i)=compare(i,j);  
        filen=a(7:15);
        filen=['compare',filen];
        filen=[filen,'-'];
        filen=[filen,b(7:15)];
        filen=[filen,'.mat'];
        save(filen,'Index','Index2');
        clear('b','histotest','m','n','t','Index','Index2','tempc1','tempc2','faans','check','p','numer','denom','aans','m1','m2','I1','I2','M','z','k','to','temp','l','filen');
     end
     clear('histomodel','a');
 end
 save('compare','compare');