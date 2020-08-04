clear all; clc;close all;

data_set = 'D:\ubuntu\data\pfhs\asc';
addpath(data_set);
data_1 = (dir(fullfile(data_set,'*.asc')));
data_1 = {data_1(~[data_1.isdir]).name};
compare(50,50)=0;
    for j = 1:1
        for i = 7:7
            if i~=j
                a1 = char(data_1(j));
                X1 = load(data_1{j});
                a2 = char(data_1(i));
                X2 = load(data_1{i});
                [m,n]=size(X1);
                [l,k]=size(X2);
                if m<=l
                    histomodel=X1;
                    histotest=X2;
                    match1(m)=0;
                    match2(m)=0;
                    counts=0;
                    temp1=1;
                    y=1;
                    z=1;
                    score(l)=0;
                    for y=1:m
                        for z=1:m
                            numer=0;
                            denom=0;
                            for k=1:125
                                if histomodel(y,k)<=histotest(z,k)
                                    numer=numer+histomodel(y,k);
                                else
                                    numer=numer+histotest(z,k);
                                end
                                denom=denom+histomodel(y,k);
                            end
                            score(z)=1-(numer/denom);
                        end
                        b=sort(score);
                        if b(1)==0
                            match1(temp1)=y;
                            match2(temp1)=z;
                            temp1=temp1+1;
                        else 
                            flag=1;
                            if (b(1)/b(2))>0.9
                                match1(temp1)=NaN;
                                match2(temp1)=NaN;
                                temp1=temp1+1;
                            elseif (b(1)/b(2))<=0.9
                                match1(temp1)=y;
                                match2(temp1)=z;
                                temp1=temp1+1;
                            end
                        end
                    end
                else
                    histomodel=X2;
                    histotest=X1;
                    match1(l)=0;
                    match2(l)=0;
                    counts=0;
                    temp1=1;
                    score(m)=0;
                    y=1;
                    z=1;
                    for y=1:l
                        for z=1:m
                            numer=0;
                            denom=0;
                            for k=1:125
                                if histomodel(y,k)<=histotest(z,k)
                                    numer=numer+histomodel(y,k);
                                else
                                    numer=numer+histotest(z,k);
                                end
                                denom=denom+histomodel(y,k);
                            end
                            score(z)=1-(numer/denom);
                        end
                        b=sort(score);
                        if b(1)==0
                            match1(temp1)=y;
                            match2(temp1)=z;
                            temp1=temp1+1;
                        else 
                            flag=1;
                            if (b(1)/b(2))>0.9
                                match1(temp1)=NaN;
                                match2(temp1)=NaN;
                                temp1=temp1+1;
                            elseif (b(1)/b(2))<=0.9
                                match1(temp1)=y;
                                match2(temp1)=z;
                                temp1=temp1+1;
                            end
                        end
                    end 
                end
                for t=1:min(m,l)
                    if isnan(match1(t))
                        counts=counts+1;
                    end
                    compare(j,i)=min(m,l)-counts;
                end
                compare(i,j)=compare(j,i);
                clear('temp1');
                clear('b');
                %clear('match1');
                %clear('match2');
            end
         end
     end