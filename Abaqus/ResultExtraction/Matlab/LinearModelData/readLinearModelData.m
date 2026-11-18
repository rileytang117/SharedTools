function linearModelData = readLinearModelData(dataFolder)
% 读取自由度信息、质量矩阵、线性刚度矩阵和模态数据
% dataFolder         提取结果的保存目录
% linearModelData    线性模型数据结构体，包含以下字段：
%   DofData.DofMap             自由度映射，每行为 [矩阵行号, 节点编号, 自由度编号]
%   DofData.ConstrainedDofs    约束自由度，每行为 [节点编号, 自由度编号]
%   MassMatrix                 质量矩阵，采用稀疏存储
%   LinearStiffnessMatrix      线性刚度矩阵，采用稀疏存储
%   ModalMatrix                模态矩阵，每列为一个模态
%   NaturalFrequencies         固有频率列向量，与模态矩阵的列一一对应
%   NaturalAngularFrequencies  固有圆频率列向量，为固有频率的 2*pi 倍

%% 读取自由度信息
linearModelData.DofData.DofMap = readDofMap(dataFolder);
linearModelData.DofData.ConstrainedDofs = readConstrainedDofs(dataFolder);


%% 读取质量矩阵和线性刚度矩阵
linearModelData.MassMatrix = readMassMatrix(dataFolder);
linearModelData.LinearStiffnessMatrix = readStiffnessMatrix(dataFolder);


%% 读取模态数据
linearModelData.ModalMatrix = readModalMatrix(dataFolder);
linearModelData.NaturalFrequencies = readNaturalFrequencies(dataFolder);
linearModelData.NaturalAngularFrequencies = 2 * pi * linearModelData.NaturalFrequencies;

end
