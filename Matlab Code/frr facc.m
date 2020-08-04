max=39;
min=2;
opt=1;
while min<=max
	frej(opt)=0;
	facc(opt)=0;
	for i=1:270
			if dscore(i)<min
				facc(opt)=facc(opt)+1;
			end
	end
	for i=1:30
			if sscore(i)>min
				frej(opt)=frej(opt)+1;
			end
	end
	opt=opt+1;
	min=min+0.0001;
end
frej=((frej*100)/(30));
facc=((facc*100)/(270)); 