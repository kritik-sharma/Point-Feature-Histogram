% using sir+mine logic for same

clear all;clc;close all;

data_set = 'D:\50_set\pfh\asc\';
addpath(data_set);
data_1 = (dir(fullfile(data_set,'*.asc')));
data_1 = {data_1(~[data_1.isdir]).name};
data_set2 = 'D:\50_set\asc\point\';
addpath(data_set2);
data_2 = (dir(fullfile(data_set2,'*.asc')));
data_2 = {data_2(~[data_2.isdir]).name};
tcount=0;
icperror=0;
pfherror=0;
timetemp=0;
Timebyus(500)=0;
Timebyicp(500,2)=0;
Eicpnpfh(500)=0;
Eicp(500)=0;
for j = 1:length(dir(fullfile(data_set,'*.asc')))
	if (j+5)>length(dir(fullfile(data_set,'*.asc')))
		top=length(dir(fullfile(data_set,'*.asc')));
	else
		top=j+5;
	end
	for alpha = j+1:top
    	a = char(data_1(j));
    	b = char(data_1(alpha));
    	temp1=a(4:9);
    	temp2=b(4:9);
    	if temp1==temp2
	    	samp1=a(4:16);
    		samp2=b(4:16);
	    	q = load(data_1{alpha});
	    	p = load(data_1{j});
	    	tic;
	    	[Idx,D] = knnsearch(q,p,'K',2,'Distance','Euclidean');
	    	timetemp=toc;
	    	[mp,np]=size(p);
	    	[mq,nq]=size(q);
	    	for i=1:mp
	    		if D(i,1)/D(i,2)>0.9
	    			Idx(i,1)=0;
	    		end
            end
	    	q=load(samp2);
	    	p=load(samp1);
			[mp,np]=size(p);
			[mq,nq]=size(q);
			pos=1;
			for i=1:mp
				if Idx(i,1)~=0
					ip(pos,:)=p(i,:);
					iq(pos,:)=q(Idx(i),:);
					match(pos)=i;
					pos=pos+1;
				end
			end
			X1=ip';
			X2=iq';
			[s1,s2]=size(p);
			% inilers percentage
			p = 0.25;
			% noise
			sigma = 1;
			% set RANSAC options
			options.epsilon = 1e-6;
			options.P_inlier = 1-1e-4;
			options.sigma = sigma;
			options.est_fun = @estimate_affine;
			options.man_fun = @error_affine;
			options.mode = 'MSAC';
			options.Ps = [];
			options.notify_iters = [];
			options.min_iters = 1000;
			options.fix_seed = false;
			options.reestimate = true;
			options.stabilize = false;
			X = [X1; X2];
			% run RANSAC
			[results, options] = RANSAC(X, options);
			pp_idx=results.CS;
			[size1,size2]=size(pp_idx);
			ip=ip';iq=iq';
			Np=sum(pp_idx);
			weights(1:Np) = 1;
			pos=1;
			for i=1:size2
				if pp_idx(i)==1
					iiq(:,pos)=iq(:,i);
					q_idx(pos)=pos;
					pos=pos+1;
				end
			end
			p_idx = true(1, Np);
			[TR, TT, p_idx,q_idx,newER, new1t] = icp(iiq(:,q_idx),ip(:,pp_idx));
			q=load(samp2);
	    	p=load(samp1);
			p=p';q=q';
			p=TR*p+TT;
			[newTR, newTT, p_idx,q_idx,newER, newt] = icp(q,p);
			q=load(samp2);
	    	p=load(samp1);
			%p-qICpbegin
			[TR,TT,p_idx,q_idx,ERicp,t]=icp(q',p',20);
			%p-qIcpend
			filename=[a,'-',b]
			t1=samp2([1:5]);
			t2=samp1([1:5]);
			tcount=tcount+1;
			Eicp(tcount,1)=ERicp(11);
            Eicp(tcount,2)=ERicp(21);
			Eicpnpfh(tcount,2)=newER(11);
            Timebyus(tcount)=timetemp+newt(11)+new1t(11)+results.time;
            Timebyicp(tcount,1)=t(11);
            Timebyicp(tcount,2)=t(21);
			clear('samp2','IdxCb1','DCb1','TR','TT','p_idx','q_idx','q','weights','Np','b','D','iiq','pp_idx','ERicp','filename','Idx','ip','iq','match','mp','mq','newER','newt','newTR','newTT','np','Np','nq','pos','R','T','t');
		end
 	end
 end
save('sirlogicfordiff');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% using sir+mine logic for different

clear all;clc;close all;
% for different 

data_set = 'D:\50_set\pfh\asc\';
addpath(data_set);
data_1 = (dir(fullfile(data_set,'*001.asc')));
data_1 = {data_1(~[data_1.isdir]).name};
data_set2 = 'D:\50_set\asc\point\';
addpath(data_set2);
data_2 = (dir(fullfile(data_set2,'*001.asc')));
data_2 = {data_2(~[data_2.isdir]).name};
tcount=0;
icperror=0;
pfherror=0;
timetemp=0;
Timebyus(500)=0;
Timebyicp(500,2)=0;
Eicpnpfh(500)=0;
Eicp(500)=0;
for j = 1:length(dir(fullfile(data_set,'*001.asc')))
    if (j+10)>length(dir(fullfile(data_set,'*001.asc')))
    	top=10;
    	bottom=1;
    else
    	top=j+10;
    	bottom=j+1;
    end
    for alpha = bottom:top
    	a = char(data_1(j));
    	b = char(data_1(alpha));
    	temp1=a(4:9);
    	temp2=b(4:9);
    	samp1=a(4:16);
		samp2=b(4:16);
    	q = load(data_1{alpha});
    	p = load(data_1{j});
    	tic;
    	[Idx,D] = knnsearch(q,p,'K',2,'Distance','Euclidean');
    	timetemp=toc;
    	[mp,np]=size(p);
    	[mq,nq]=size(q);
    	for i=1:mp
    		if D(i,1)/D(i,2)>0.9
    			Idx(i,1)=0;
    		end
    	end
    	q=load(samp2);
    	p=load(samp1);
		[mp,np]=size(p);
		[mq,nq]=size(q);
		T = zeros(3,1);
		R = eye(3,3);
		TT = zeros(3,1,1);
		TR = repmat(eye(3,3), [1,1,1]);
		pos=1;
		for i=1:mp
			if Idx(i,1)~=0
				ip(pos,:)=p(i,:);
				iq(pos,:)=q(Idx(i),:);
				match(pos)=i;
				pos=pos+1;
			end
		end
		X1=ip';
		X2=iq';
		[s1,s2]=size(p);
		% inilers percentage
		p = 0.25;
		% noise
		sigma = 1;
		% set RANSAC options
		options.epsilon = 1e-6;
		options.P_inlier = 1-1e-4;
		options.sigma = sigma;
		options.est_fun = @estimate_affine;
		options.man_fun = @error_affine;
		options.mode = 'MSAC';
		options.Ps = [];
		options.notify_iters = [];
		options.min_iters = 1000;
		options.fix_seed = false;
		options.reestimate = true;
		options.stabilize = false;
		X = [X1; X2];
		% run RANSAC
		[results, options] = RANSAC(X, options);
		pp_idx=results.CS;
		[size1,size2]=size(pp_idx);
		ip=ip';iq=iq';
		Np=sum(pp_idx);
		weights(1:Np) = 1;
		pos=1;
		for i=1:size2
			if pp_idx(i)==1
				iiq(:,pos)=iq(:,i);
				q_idx(pos)=pos;
				pos=pos+1;
			else
			end
		end
		p_idx = true(1, Np);
		[TR, TT, p_idx,q_idx,newER, new1t] = icp(iiq(:,q_idx),ip(:,pp_idx));
		q=load(samp2);
	    p=load(samp1);
		p=p';q=q';
		p=TR*p+TT;
		[newTR, newTT, p_idx,q_idx,newER, newt] = icp(q,p);
		q=load(samp2);
    	p=load(samp1);
		%p-qICpbegin
		[TR,TT,p_idx,q_idx,ERicp,t]=icp(q',p',20);
		%p-qIcpend
		filename=[a,'-',b]
		t1=samp2([1:5]);
		t2=samp1([1:5]);
		tcount=tcount+1;
		Eicp(tcount,1)=ERicp(11);
        Eicp(tcount,2)=ERicp(21);
		Eicpnpfh(tcount,2)=newER(11);
        Timebyus(tcount)=timetemp+newt(11)+new1t(11)+results.time;
        Timebyicp(tcount,1)=t(11);
        Timebyicp(tcount,2)=t(21);
		clear('samp2','IdxCb1','DCb1','TR','TT','p_idx','q_idx','q','weights','Np','b','D','iiq','pp_idx','ERicp','filename','Idx','ip','iq','match','mp','mq','newER','newt','newTR','newTT','np','Np','nq','pos','R','T','t');
 	end
 end
save('sirlogicfordiff');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% using sir+mine logic for same
clear all;clc;close all;

data_set = 'D:\50_set\pfh\asc\';
addpath(data_set);
data_1 = (dir(fullfile(data_set,'*.asc')));
data_1 = {data_1(~[data_1.isdir]).name};
data_set2 = 'D:\50_set\asc\point\';
addpath(data_set2);
data_2 = (dir(fullfile(data_set2,'*.asc')));
data_2 = {data_2(~[data_2.isdir]).name};
tcount=0;
icperror=0;
pfherror=0;
timetemp=0;
Timebyus(500)=0;
Timebyicp(500,2)=0;
Eicpnpfh(500)=0;
Eicp(500)=0;
for j = 1:length(dir(fullfile(data_set,'*.asc')))
	if (j+5)>length(dir(fullfile(data_set,'*.asc')))
		top=length(dir(fullfile(data_set,'*.asc')));
	else
		top=j+5;
	end
	for alpha = j+1:top
    	a = char(data_1(j));
    	b = char(data_1(alpha));
    	temp1=a(4:9);
    	temp2=b(4:9);
    	if temp1==temp2
	    	samp1=a(4:16);
    		samp2=b(4:16);
	    	q = load(data_1{alpha});
	    	p = load(data_1{j});
	    	tic;
	    	[Idx,D] = knnsearch(q,p,'K',2,'Distance','Euclidean');
	    	timetemp=toc;
	    	[mp,np]=size(p);
	    	[mq,nq]=size(q);
	    	for i=1:mp
	    		if D(i,1)/D(i,2)>0.9
	    			Idx(i,1)=0;
	    		end
            end
	    	q=load(samp2);
	    	p=load(samp1);
			[mp,np]=size(p);
			[mq,nq]=size(q);
			pos=1;
			for i=1:mp
				if Idx(i,1)~=0
					ip(pos,:)=p(i,:);
					iq(pos,:)=q(Idx(i),:);
					match(pos)=i;
					pos=pos+1;
				end
			end
			X1=ip';
			X2=iq';
			[s1,s2]=size(p);
			% inilers percentage
			p = 0.25;
			% noise
			sigma = 1;
			% set RANSAC options
			options.epsilon = 1e-6;
			options.P_inlier = 1-1e-4;
			options.sigma = sigma;
			options.est_fun = @estimate_affine;
			options.man_fun = @error_affine;
			options.mode = 'MSAC';
			options.Ps = [];
			options.notify_iters = [];
			options.min_iters = 1000;
			options.fix_seed = false;
			options.reestimate = true;
			options.stabilize = false;
			X = [X1; X2];
			% run RANSAC
			[results, options] = RANSAC(X, options);
			pp_idx=results.CS;
			[size1,size2]=size(pp_idx);
	%		pos=1;
	%		for i=1:size2
	%			if index(i)==1
	%				iip(pos,:)=ip(i,:);
	%				iiq(pos,:)=iq(i,:);
	%				match(pos)=i;
	%				pos=pos+1;
	%			end
	%		end
			ip=ip';iq=iq';
	%		p_idx = true(1, Np);
			Np=sum(pp_idx);
			weights(1:Np) = 1;
			pos=1;
			for i=1:size2
				if pp_idx(i)==1
					iiq(:,pos)=iq(:,i);
					q_idx(pos)=pos;
					pos=pos+1;
				else
				end
			end
			p_idx = true(1, Np);
			[TR, TT, p_idx,q_idx,newER, new1t] = icp(iiq(:,q_idx),ip(:,pp_idx));
			q=load(samp2);
	    	p=load(samp1);
			p=p';q=q';
			p=TR*p+TT;
			[newTR, newTT, p_idx,q_idx,newER, newt] = icp(q,p);
			q=load(samp2);
	    	p=load(samp1);
			%p-qICpbegin
			[TR,TT,p_idx,q_idx,ERicp,t]=icp(q',p',20);
			%p-qIcpend
			filename=[a,'-',b]
			t1=samp2([1:5]);
			t2=samp1([1:5]);
			tcount=tcount+1;
			Eicp(tcount,1)=ERicp(11);
            Eicp(tcount,2)=ERicp(21);
			Eicpnpfh(tcount,2)=newER(11);
            Timebyus(tcount)=timetemp+newt(11)+new1t(11)+results.time;
            Timebyicp(tcount,1)=t(11);
            Timebyicp(tcount,2)=t(21);
			clear('samp2','IdxCb1','DCb1','TR','TT','p_idx','q_idx','q','weights','Np','b','D','iiq','pp_idx','ERicp','filename','Idx','ip','iq','match','mp','mq','newER','newt','newTR','newTT','np','Np','nq','pos','R','T','t');
		end
 	end
 end
save('sirminelogicforsame');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% using sir+mine logic for different
clear all;clc;close all;
% for different 

data_set = 'D:\50_set\pfh\asc\';
addpath(data_set);
data_1 = (dir(fullfile(data_set,'*001.asc')));
data_1 = {data_1(~[data_1.isdir]).name};
data_set2 = 'D:\50_set\asc\point\';
addpath(data_set2);
data_2 = (dir(fullfile(data_set2,'*001.asc')));
data_2 = {data_2(~[data_2.isdir]).name};
tcount=0;
icperror=0;
pfherror=0;
timetemp=0;
Timebyus(500)=0;
Timebyicp(500,2)=0;
Eicpnpfh(500)=0;
Eicp(500)=0;
for j = 1:length(dir(fullfile(data_set,'*001.asc')))
    if (j+10)>length(dir(fullfile(data_set,'*001.asc')))
    	top=10;
    	bottom=1;
    else
    	top=j+10;
    	bottom=j+1;
    end
    for alpha = bottom:top
    	a = char(data_1(j));
    	b = char(data_1(alpha));
    	temp1=a(4:9);
    	temp2=b(4:9);
    	samp1=a(4:16);
		samp2=b(4:16);
    	q = load(data_1{alpha});
    	p = load(data_1{j});
    	tic;
    	[Idx,D] = knnsearch(q,p,'K',2,'Distance','Euclidean');
    	timetemp=toc;
    	[mp,np]=size(p);
    	[mq,nq]=size(q);
    	for i=1:mp
    		if D(i,1)/D(i,2)>0.9
    			Idx(i,1)=0;
    		end
        end
    	q=load(samp2);
    	p=load(samp1);
		[mp,np]=size(p);
		[mq,nq]=size(q);
		T = zeros(3,1);
		R = eye(3,3);
		TT = zeros(3,1,1);
		TR = repmat(eye(3,3), [1,1,1]);
		pos=1;
		for i=1:mp
			if Idx(i,1)~=0
				ip(pos,:)=p(i,:);
				iq(pos,:)=q(Idx(i),:);
				match(pos)=i;
				pos=pos+1;
			end
		end
		X1=ip';
		X2=iq';
		[s1,s2]=size(p);
		% inilers percentage
		p = 0.25;
		% noise
		sigma = 1;
		% set RANSAC options
		options.epsilon = 1e-6;
		options.P_inlier = 1-1e-4;
		options.sigma = sigma;
		options.est_fun = @estimate_affine;
		options.man_fun = @error_affine;
		options.mode = 'MSAC';
		options.Ps = [];
		options.notify_iters = [];
		options.min_iters = 1000;
		options.fix_seed = false;
		options.reestimate = true;
		options.stabilize = false;
		X = [X1; X2];
		% run RANSAC
		[results, options] = RANSAC(X, options);
		pp_idx=results.CS;
		[size1,size2]=size(pp_idx);
		ip=ip';iq=iq';
		Np=sum(pp_idx);
		weights(1:Np) = 1;
		pos=1;
		for i=1:size2
			if pp_idx(i)==1
				iiq(:,pos)=iq(:,i);
				q_idx(pos)=pos;
				pos=pos+1;
			else
			end
		end
		p_idx = true(1, Np);
		[TR, TT, p_idx,q_idx,newER, new1t] = icp(iiq(:,q_idx),ip(:,pp_idx));
		q=load(samp2);
    	p=load(samp1);
		p=p';q=q';
		p=TR*p+TT;
		[newTR, newTT, p_idx,q_idx,newER, newt] = icp(q,p);
		q=load(samp2);
    	p=load(samp1);
		%p-qICpbegin
		[TR,TT,p_idx,q_idx,ERicp,t]=icp(q',p',20);
		%p-qIcpend
		filename=[a,'-',b]
		t1=samp2([1:5]);
		t2=samp1([1:5]);
		tcount=tcount+1;
		Eicp(tcount,1)=ERicp(11);
        Eicp(tcount,2)=ERicp(21);
		Eicpnpfh(tcount,2)=newER(11);
        Timebyus(tcount)=timetemp+newt(11)+new1t(11)+results.time;
        Timebyicp(tcount,1)=t(11);
        Timebyicp(tcount,2)=t(21);
		clear('samp2','IdxCb1','DCb1','TR','TT','p_idx','q_idx','q','weights','Np','b','D','iiq','pp_idx','ERicp','filename','Idx','ip','iq','match','mp','mq','newER','newt','newTR','newTT','np','Np','nq','pos','R','T','t');
 	end
 end
save('sirminelogicfordiff');