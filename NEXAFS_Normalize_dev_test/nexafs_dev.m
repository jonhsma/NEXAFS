%% Initialization
set(0,'DefaultFigureWindowStyle','Docked')
addpath('../')


%% Read the file
dir_fileName = 'data/direct_43284.txt';
Data_dir = ReadBL11File(dir_fileName);

fileList=ls('data/CH*');
nFile = size(fileList,1);

for jj=(nFile):-1:1
	Data_spec(jj) = ReadBL11File(['data/' fileList(jj,:)]);
end

NEXAFS_TEY_Normalize(Data_dir,Data_spec)
