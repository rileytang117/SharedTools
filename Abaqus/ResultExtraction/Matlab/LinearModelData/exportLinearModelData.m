function exportLinearModelData(paths)
% 调用 Python 脚本导出自由度信息、质量矩阵、线性刚度矩阵和模态数据
% paths 为路径结构体，包含以下字段：
%   BaseInputFilePath                             基础模型的 .inp 路径，用于提取自由度信息
%   MassMatrixExport.InputFilePath                质量矩阵导出作业的 .inp 路径
%   LinearStiffnessMatrixExport.InputFilePath     线性刚度矩阵导出作业的 .inp 路径
%   ModalAnalysis.InputFilePath                   模态分析作业的 .inp 路径
%   DataFolder                                    所有提取结果的保存目录

dataFolder = paths.DataFolder;

%% 导出自由度信息
runPythonExtraction('exportDofMap.py', paths.BaseInputFilePath, dataFolder);
runPythonExtraction('exportConstrainedDofs.py', paths.BaseInputFilePath, dataFolder);

dofData.DofMap = readDofMap(dataFolder);
dofData.ConstrainedDofs = readConstrainedDofs(dataFolder);


%% 导出质量矩阵和线性刚度矩阵
runPythonExtraction('exportMassMatrix.py', paths.MassMatrixExport.InputFilePath, dataFolder, dofData);
runPythonExtraction('exportStiffnessMatrix.py', paths.LinearStiffnessMatrixExport.InputFilePath, dataFolder, dofData);


%% 导出模态矩阵和固有频率
runPythonExtraction('exportModalMatrix.py', paths.ModalAnalysis.InputFilePath, dataFolder, dofData);
runPythonExtraction('exportNaturalFrequencies.py', paths.ModalAnalysis.InputFilePath, dataFolder);

end