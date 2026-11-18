function naturalFrequencies = readNaturalFrequencies(dataFolder)
% 读取固有频率并整理为列向量
% dataFolder            提取结果的保存目录
% naturalFrequencies    按模态顺序排列的固有频率列向量，模型时间单位为秒时频率单位为 Hz

naturalFrequencies = readmatrix(fullfile(dataFolder, 'NaturalFrequencies.txt'));
naturalFrequencies = naturalFrequencies(:);

end
