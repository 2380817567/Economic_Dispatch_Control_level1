%% 逼养的ai还是聪明啊，我照着视频敲了半天结果也不对，这ai怎么就这么猛啊？


% 清除工作空间和命令窗口
clc;
clear;

%% 参数设置
% 发电机组数据: [序号, 出力上限(Pmax), 出力下限(Pmin), 成本($/MW)]
Gen = [1, 700, 200, 100; 
       2, 300, 50,  200;
       3, 200, 50,  300; 
       4, 200, 50,  400;
       5, 100, 0,   500]; 

N = size(Gen, 1);  % 机组数量 (从数据自动获取)
L = 1000;          % 总负荷需求 (MW)

%% 定义决策变量
% P(i): 第i台机组的出力
P = sdpvar(N, 1);

%% 构建约束条件
% 初始化约束列表
constraints = [];

% 1. 功率平衡约束 (总出力等于负荷)
constraints = [constraints, sum(P) == L];

% 2. 各机组出力上下限约束
for i = 1:N
    constraints = [constraints, Gen(i, 3) <= P(i) <= Gen(i, 2)];
    % 错误修正：原来的 Gen(i,3)<=P(i,1)<=Gen(i,2) 改为两个独立的约束
    % 或者写成两行: constraints = [constraints, Gen(i, 3) <= P(i)];
    %                constraints = [constraints, P(i) <= Gen(i, 2)];
end

%% 定义目标函数 (最小化总成本)
Cost = 0;
for i = 1:N
    Cost = Cost + Gen(i, 4) * P(i);
end

%% 求解优化问题
% 设置求解器选项 (假设 Gurobi 已正确安装并与 YALMIP 关联)
ops = sdpsettings('solver', 'gurobi'); 
% ops = sdpsettings('verbose', 1); % 如果需要查看求解过程信息可以取消注释

% 执行求解
sol = optimize(constraints, Cost, ops); % 推荐使用 optimize 替代旧的 solvesdp

% 检查求解状态
if sol.problem ~= 0
    disp('求解失败！');
    fprintf('求解器返回的问题标识: %d\n', sol.problem);
else
    disp('求解成功！');

    %% 输出结果
    final_cost = value(Cost);
    optimal_P = value(P);

    fprintf('最低总成本: %.2f $\n', final_cost);
    fprintf('各机组最优出力:\n');
    for i = 1:N
        fprintf('  机组 %d: %.2f MW\n', Gen(i,1), optimal_P(i));
    end
end