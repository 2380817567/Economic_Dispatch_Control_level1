clc;clear
%% 参数设置
Gen = [1 700 200 100 
       2 300 50 200
       3 200 50 300 
       4 200 50 400
       5 100 0  500] ;   %发电机组：序号 出力上限 出力下限 机组出力每兆瓦成本

N = 5;    %机组数量

L = 1000;  %负荷



%% 决策变量        sdpvar定义连续型变量    binvar定义0-1变量（只能是0或者1）
P = sdpvar(N,1);



%% 约束条件
global f1    %global是MATLAB的一个函数，用来定义全局变量

f1 = [f1,sum(P) == L];

for i=1:N
f1 = [f1,Gen(i,3) <= P(i,1) <= Gen(i,2)];
end

%% 目标函数
Cost = 0;
for i = 1:N
    Cost = Cost + Gen(i,4)*P(i,1);
end

%% 求解设置
ops = sdpsettings('solver','gurobi');
sol = solvesdp(f1,Cost,ops);    %约束，目标函数，求解设置

%% 输出变量
 Cost = double(Cost);
 P = double(P);



%  主要改动总结:ai改的东西
% 
% 移除了不必要的 global 声明。
% 明确定义并初始化了 constraints 列表用于存储所有约束。
% 修复了机组出力范围约束的表达方式，使用了正确的 YALMIP 链式不等式语法 a <= x <= b（这是 YALMIP 特有的简化写法）或者拆分为两个独立约束。
% 使用了现代 YALMIP 推荐的 optimize 函数替代了较旧的 solvesdp。
% 添加了对求解结果的状态检查 (sol.problem)。
% 使用 value 函数获取求解后的变量值和目标函数值，使意图更加明确。
% 提供了更清晰的结果打印格式。

