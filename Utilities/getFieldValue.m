function value = getFieldValue(inputStruct, fieldName, defaultValue)
% 读取结构体字段，字段不存在或为空时返回默认值
% 未提供第三个输入时，默认值为 []

if isfield(inputStruct, fieldName) && ~isempty(inputStruct.(fieldName))
    value = inputStruct.(fieldName);
else
    if nargin < 3
        defaultValue = [];
    end
    value = defaultValue;
end

end