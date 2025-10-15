clc; clear;

% 参数设置
Gen = [1 2 1 700 0 200 -200 0 10 5;
       2 6 1 400 0 200 -200 0 11 6;
       3 1 1 200 0 55 -55 0 14 7;
       4 2 1 60 0 25 -25 0 20 8;
       5 6 1 30 0 10 -10  0 -25 9;];
       
% 其余参数设置...

% 计算 GSF 矩阵
% 使用修正的 GSF 计算方法

% 定义决策变量
G=sdpvar(NG,T);
R=sdpvar(NG,T);

% 构建约束
constraints = [];

% 功率平衡约束
for t = 1:T
    constraints = [constraints, sum(G(:, t)) == TotalLoad(t)];
end

% 线路潮流约束
% 使用修正的线路潮流约束表达式

% 发电机约束
% 使用更清晰的约束表达式

% 爬坡约束
for t = 2:T
    for i = 1:NG
        constraints = [constraints, 
            -Gen(i, 7) <= G(i, t) - G(i, t-1) <= Gen(i, 6)];
    end
end

% 备用约束
for t = 1:T
    constraints = [constraints, sum(R(:, t)) >= rate * TotalLoad(t)];
end

% 目标函数
Cost = 0;
for t = 1:T
    for i = 1:NG
        Cost = Cost + Gen(i, 9) * G(i, t) + Gen(i, 10) * R(i, t);
    end
end

% 求解
ops = sdpsettings('solver', 'gurobi', 'verbose', 1);
sol = optimize(constraints, Cost, ops);

% 检查求解状态
if sol.problem == 0
    disp('求解成功');
    G = value(G);
    R = value(R);
    Cost = value(Cost);
else
    disp('求解失败');
    disp(sol.info);
end






