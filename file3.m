clc;clear
%% 参数设置
Gen = [1 700 200 100 100 -100  8  8  2e5
       2 300 50 200 50 -50  5  5  1e5
       3 200 50 300 50 -50  5  5  1e5
       4 200 50 400 100 -100 5  5  1e5
       5 100 0  500 100 -100 0  0  1e4] ;   %发电机组：序号 出力上限 出力下限 机组出力每兆瓦成本  上爬坡约束   下爬坡约束
                                            %第七第八列是机组的开机和停机时间，第九列是机组的启动成本
N = 5;    %机组数量
T = 24;
L = [500 400 410 380 400 490 620 880 970 1000 960 940 890 910 940 930 890 800 850 630 610 600 570 500]*1.5;  %负荷



%% 决策变量        sdpvar定义连续型变量    binvar定义0-1变量（只能是0或者1）
P = sdpvar(N,T);
u = binvar(N,T);   %机组启停变量，0表示停机，1表示开机
s = binvar(N,T);   %机组的启动变量，1表示发生了启动动作，0表示没有发生
%% 约束条件
global f1    %global是MATLAB的一个函数，用来定义全局变量

for t = 1:T
    f1 = [f1,sum(P(:,t)) == L(t)];   %T个功率平衡的约束
end

for t = 1:T
   for i=1:N
      f1=[f1,Gen(i,3)*u(i,t) <= P(i,t) <= Gen(i,2)*u(i,t)];
   end
end


   %定义爬坡约束
global f2
for t = 2:T
    for i = 1:N
    f2 = [f2,Gen(i,6) <= P(i,t)-P(i,t-1) <= Gen(i,5)];
    end
end

global f3    %最小开机时间约束 
for i = 1:N
  for t= 2:T-Gen(i,7)
    f3 = [f3,sum(u(i,t:t+Gen(i,7)-1))>=Gen(i,7)*(u(i,t)-u(i,t-1))];
  end
end

for i = 1:N
    k=0;  
  for t = 2:T-Gen(i,7)+1:T
      k=k+1;
    f3 = [f3,sum(u(i,t:t+Gen(i,7)-1-k))>=Gen(i,7)*(u(i,t)-u(i,t-1))];
  end
end

global f4
for i=1:N
    for t=2:T
        f4 = [f4,s(i,t)<=u(i,t)];
        f4 = [f4,s(i,t)<=1-u(i,t-1)];
        f4 = [f4,s(i,t)>=u(i,t)-u(i,t-1)];
    end
end 

F = f1 + f2 + f3 + f4; 

%% 目标函数
Cope = 0;
for t = 1:T
  for i = 1:N
      Cope = Cope + Gen(i,4)*P(i,t);
  end
end
Cstart = 0;
for t=1:T
    for i = 1:N
        Cstart = Cstart + Gen(i,9)*s(i,t);
    end
end

Cost = Cope + Cstart;
%% 求解设置
ops = sdpsettings('solver','gurobi');
sol = solvesdp(F,Cost,ops);    %约束，目标函数，求解设置

%% 输出变量
 Cost = double(Cost);
 P = double(P);
 u = double(u);
 s = double(s);