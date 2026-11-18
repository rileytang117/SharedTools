function runLinearAnalysisJobs(paths, settings)
% 生成线性分析输入文件，依次运行模态分析、质量矩阵导出和线性刚度矩阵导出作业
% paths 为路径结构体，包含以下字段：
%   BaseInputFilePath                             不含分析步的基础模型 .inp 路径
%   ModalAnalysis.InputFilePath                   模态分析作业的 .inp 路径
%   MassMatrixExport.InputFilePath                质量矩阵导出作业的 .inp 路径
%   LinearStiffnessMatrixExport.InputFilePath     线性刚度矩阵导出作业的 .inp 路径
% settings 可包含以下字段，未提供或为空的字段使用默认值：
%   NumModes    提取的模态数量，默认 10
%   NumCores    每个作业使用的计算核心数，默认 1

numModes = getFieldValue(settings, 'NumModes', 10);
jobSettings.NumCores = getFieldValue(settings, 'NumCores', 1);

inputFilePaths.BaseInputFilePath = paths.BaseInputFilePath;


%% 模态分析
inputFilePaths.InputFilePath = paths.ModalAnalysis.InputFilePath;
writeModalAnalysisInputFile(inputFilePaths, numModes);

fprintf('\nRunning modal analysis (%d modes)...\n', numModes);
runAbaqusJob(inputFilePaths.InputFilePath, jobSettings);


%% 质量矩阵导出
inputFilePaths.InputFilePath = paths.MassMatrixExport.InputFilePath;
writeMassMatrixExportInputFile(inputFilePaths);

fprintf('\nComputing mass matrix...\n');
runAbaqusJob(inputFilePaths.InputFilePath, jobSettings);


%% 线性刚度矩阵导出
inputFilePaths.InputFilePath = paths.LinearStiffnessMatrixExport.InputFilePath;
writeStiffnessMatrixExportInputFile(inputFilePaths);

fprintf('\nComputing linear stiffness matrix...\n');
runAbaqusJob(inputFilePaths.InputFilePath, jobSettings);


end