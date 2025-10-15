clc;clear
%% 参数设置
Gen = [1 700 200 100 100 -100
       2 300 50 200 50 -50
       3 200 50 300 50 -50
       4 200 50 400 100 -100
       5 100 0  500 100 -100] ;   %发电机组：序号 出力上限 出力下限 机组出力每兆瓦成本  上爬坡约束   下爬坡约束

N = 5;    %机组数量
T = 24;
L = [500 400 410 380 400 490 620 880 970 1000 960 940 890 910 940 930 890 800 850 630 610 600 570 500];  %负荷



%% 决策变量        sdpvar定义连续型变量    binvar定义0-1变量（只能是0或者1）
P = sdpvar(N,T);
%% 约束条件
global f1    %global是MATLAB的一个函数，用来定义全局变量

for t = 1:T
    f1 = [f1,sum(P(:,t)) == L(t)];   %T个功率平衡的约束
end

for t = 1:T
   for i=1:N
      f1=[f1,Gen(i,3) <= P(i,t) <= Gen(i,2)];
   end
end


   %定义爬坡约束
global f2
for t = 2:T
    for i = 1:N
    f2 = [f2,Gen(i,6) <= P(i,t)-P(i,t-1) <= Gen(i,5)];
    end
end

F = f1 + f2;

%% 目标函数
Cost = 0;
for t = 1:T
  for i = 1:N
      Cost = Cost + Gen(i,4)*P(i,t);
  end
end

%% 求解设置
ops = sdpsettings('solver','gurobi');
sol = solvesdp(F,Cost,ops);    %约束，目标函数，求解设置

%% 输出变量
 Cost = double(Cost);
 P = double(P);