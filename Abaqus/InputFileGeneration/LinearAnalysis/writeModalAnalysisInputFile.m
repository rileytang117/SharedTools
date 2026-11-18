function writeModalAnalysisInputFile(paths, numModes)
% 根据基础模型生成模态分析的输入文件
% paths 为路径结构体，包含以下字段：
%   BaseInputFilePath    不含分析步的基础模型 .inp 路径
%   InputFilePath        生成的分析输入文件路径
% numModes    需要提取的模态数量

%% 读取基础模型并准备目标目录
baseInputText = fileread(paths.BaseInputFilePath);
inputFolder = fileparts(paths.InputFilePath);

if ~isempty(inputFolder) && ~isfolder(inputFolder)
    mkdir(inputFolder);
end

if isfile(paths.InputFilePath)
    warning('Existing input file will be overwritten:\n%s', paths.InputFilePath);
end

%% 创建输入文件
fileId = fopen(paths.InputFilePath, 'w');

if fileId == -1
    error('Unable to create input file:\n%s', paths.InputFilePath);
end

fileCleanup = onCleanup(@() fclose(fileId));

%% 写入模态分析步和节点输出
fprintf(fileId, '%s\n', baseInputText);
fprintf(fileId, '**\n** Natural frequency and mode shape extraction\n**\n');
fprintf(fileId, '*STEP, NAME=ModalAnalysis, PERTURBATION\n');
fprintf(fileId, '*FREQUENCY, EIGENSOLVER=LANCZOS, NORMALIZATION=MASS, SIM=NO\n');
fprintf(fileId, '%d,\n', numModes);
fprintf(fileId, '*OUTPUT, FIELD\n');
fprintf(fileId, '*NODE OUTPUT\n');
fprintf(fileId, 'U, UR\n');
fprintf(fileId, '*END STEP\n');

end
