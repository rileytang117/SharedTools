function runPythonExtraction(scriptName, inputFilePath, dataFolder, dofData)
% 调用 Abaqus 内置 Python 提取数据，等待结束并检查执行状态
% scriptName       Python 文件夹中的脚本文件名，例如 'exportMassMatrix.py'
% inputFilePath    Abaqus 输入文件路径，脚本直接读取该 .inp 文件或据此定位对应的结果文件
% dataFolder       提取结果的保存目录
% dofData          自由度数据结构体，不需要时可省略或传入 []，包含以下字段：
%   DofMap             自由度映射矩阵，每行为 [矩阵行号, 节点编号, 自由度编号]
%   ConstrainedDofs    约束自由度矩阵，每行为 [节点编号, 自由度编号]

%% 定位脚本并生成命令
matlabFolder = fileparts(mfilename('fullpath'));
scriptFilePath = fullfile(fileparts(matlabFolder), 'Python', scriptName);

commandParts = {'abaqus', 'python', scriptFilePath, inputFilePath, dataFolder};
quotedParts = cellfun(@quoteArgument, commandParts, 'UniformOutput', false);
commandText = strjoin(quotedParts, ' ');


%% 将自由度数据转换为输入文本
inputText = '';

if nargin >= 4 && ~isempty(dofData)
    inputStruct.DofMap = reshape(dofData.DofMap.', 1, []);
    inputStruct.ConstrainedDofs = reshape(dofData.ConstrainedDofs.', 1, []);
    inputText = jsonencode(inputStruct);
end


%% 设置进程和输入输出
textEncoding = System.Text.UTF8Encoding(false);

startInfo = System.Diagnostics.ProcessStartInfo;
startInfo.FileName = getenv('ComSpec');
startInfo.Arguments = ['/d /v:off /s /c "' commandText '"'];
startInfo.WorkingDirectory = pwd;
startInfo.UseShellExecute = false;
startInfo.CreateNoWindow = true;
startInfo.RedirectStandardInput = true;
startInfo.RedirectStandardOutput = true;
startInfo.RedirectStandardError = true;
startInfo.StandardOutputEncoding = textEncoding;
startInfo.StandardErrorEncoding = textEncoding;

environment = startInfo.EnvironmentVariables;
environment.Remove('PYTHONIOENCODING');
environment.Add('PYTHONIOENCODING', 'utf-8');


%% 启动进程并传入数据
process = System.Diagnostics.Process;
process.StartInfo = startInfo;
processCleanup = onCleanup(@() process.Dispose());
process.Start();

stdoutTask = process.StandardOutput.ReadToEndAsync();
stderrTask = process.StandardError.ReadToEndAsync();

inputWriter = System.IO.StreamWriter(process.StandardInput.BaseStream, textEncoding);
inputWriter.Write(char(inputText));
inputWriter.Close();

process.WaitForExit();


%% 检查脚本是否成功执行
stdoutText = char(stdoutTask.Result);
stderrText = char(stderrTask.Result);

if process.ExitCode ~= 0
    error('Python extraction failed (%s):\n%s\n%s', scriptName, stdoutText, stderrText);
end

end


function quotedText = quoteArgument(argumentText)
% 为命令行参数添加双引号，并处理末尾反斜杠

argumentText = regexprep(char(argumentText), '(\\+)$', '$1$1');
quotedText = ['"' argumentText '"'];

end