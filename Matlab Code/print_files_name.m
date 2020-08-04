data_set = 'D:\50_set\asc\point\';
addpath(data_set);
data_1 = (dir(fullfile(data_set,'*.asc')));
data_1 = {data_1(~[data_1.isdir]).name};
fid=fopen('filename.txt','wt');
for i=1:500
fprintf(fid,'%s\n',data_1{i});
end
fclose(fid);