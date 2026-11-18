function writeMassMatrixExportInputFile(paths)
% 根据基础模型生成质量矩阵导出作业的输入文件
% paths 为路径结构体，包含以下字段：
%   BaseInputFilePath    不含分析步的基础模型 .inp 路径
%   InputFilePath        生成的分析输入文件路径

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

%% 写入质量矩阵导出分析步
fprintf(fileId, '%s\n', baseInputText);
fprintf(fileId, '**\n** Consistent mass matrix export\n**\n');
fprintf(fileId, '*STEP, NAME=MassMatrixExport\n');
fprintf(fileId, '*MATRIX GENERATE, MASS=CONSISTENT\n');
fprintf(fileId, '*MATRIX OUTPUT, MASS, FORMAT=MATRIX INPUT\n');
fprintf(fileId, '*END STEP\n');

end
