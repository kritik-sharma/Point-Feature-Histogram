p=load('04201d001.asc');
q=load('04202d001.asc');
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
q=load('04202d001.asc');
q(:,2)=q(:,2)+100;
plot3(p(:,1),p(:,2),p(:,3),'LineStyle','none','Marker','.');
hold on
plot3(q(:,1),q(:,2),q(:,3),'LineStyle','none','Marker','.');
[m,n]=size(check);
for i=1:m
plot3([p(check(i,2),1); q(check(i,3),1)], [p(check(i,2),2); q(check(i,3),2)], [p(check(i,2),3); q(check(i,3),3)]);
end