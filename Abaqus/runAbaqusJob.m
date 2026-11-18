function runAbaqusJob(inputFilePath, settings)
% 根据输入文件提交 Abaqus 作业，等待结束并检查是否成功完成
% inputFilePath 为 .inp 文件的绝对路径或相对于当前 MATLAB 工作目录的路径
% settings 可包含以下字段，未提供或为空时使用默认值：
%   NumCores      使用的计算核心数，默认 1
%   OldJobPath    重启动分析所依赖的旧作业绝对路径，不含扩展名，默认 []

numCores = getFieldValue(settings, 'NumCores', 1);
oldJobPath = getFieldValue(settings, 'OldJobPath');

if ~isfile(inputFilePath)
    error('Input file not found:\n%s', inputFilePath);
end

%% 确定作业名称和工作目录
[jobFolder, jobName, inputExtension] = fileparts(inputFilePath);

if isempty(jobFolder)
    jobFolder = pwd;
end

%% 生成命令并提交作业
oldJobOption = '';

if ~isempty(oldJobPath)
    oldJobOption = sprintf(' oldjob="%s"', oldJobPath);
end

commandText = sprintf('call abaqus job="%s" input="%s%s"%s cpus=%d output_precision=full interactive', jobName, jobName, inputExtension, oldJobOption, numCores);
commandText = sprintf('cd /d "%s" && %s', jobFolder, commandText);

jobTimer = tic;
[exitStatus, commandOutput] = system(commandText);
elapsedSeconds = toc(jobTimer);

%% 检查作业是否成功完成
completionMessage = sprintf('Abaqus JOB %s COMPLETED', jobName);

if exitStatus ~= 0 || ~contains(commandOutput, completionMessage, 'IgnoreCase', true)
    error('Abaqus job completion could not be confirmed:\n%s\n%s', fullfile(jobFolder, jobName), commandOutput);
end

fprintf('Abaqus job completed: %s (elapsed time: %.2f s)\n', jobName, elapsedSeconds);

end