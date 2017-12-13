-module(processes).

-export([max/1, maxUpToN/1]).

%% max(N) 
%% maxUpToN(N)


%%   Create N processes then destroy them
%%   See how much time this takes
%% 


%% NOTE:
%%     -- erl +P 10000000  % i.e. 10,000,000
%%     -- 1,000,000 μSec = 1 second
%%     -- Processes = 16,777,216 maximum allowed! 
%% 
%% 
%% 2> processes:max(2000000).
%% Maximum allowed processes:16777216
%% Process 2000000. Time= 4.38 / 8.92, Ratio= 0.49. Total CPUtime & WallTime= 8.76 / 17.85 seconds, Ratio= 0.49.
%% ok
%% 3> 
%% 3> processes:maxUpToN(11).
%% Maximum allowed processes:16777216
%% 
%%   Processes | (CPU ÷ Wall) μSec |   =    | Total (CPU ÷ Wall) Sec |   =    
%% ------------+-------------------+--------+------------------------+------- 
%%     1000000 |    4.11 ÷   8.83  |   0.47 |      4.11 ÷    8.83    |   0.47 
%%     2000000 |    4.51 ÷   8.97  |   0.50 |      9.03 ÷   17.94    |   0.50 
%%     3000000 |    4.66 ÷   9.19  |   0.51 |     13.97 ÷   27.57    |   0.51 
%%     4000000 |    4.89 ÷   9.56  |   0.51 |     19.57 ÷   38.25    |   0.51 
%%     5000000 |    5.00 ÷   9.80  |   0.51 |     24.99 ÷   49.00    |   0.51 
%%     6000000 |    5.08 ÷   9.87  |   0.51 |     30.49 ÷   59.20    |   0.52 
%%     7000000 |    5.23 ÷  10.09  |   0.52 |     36.59 ÷   70.64    |   0.52 
%%     8000000 |    5.41 ÷  10.34  |   0.52 |     43.26 ÷   82.75    |   0.52 
%%     9000000 |    5.28 ÷  10.27  |   0.51 |     47.53 ÷   92.44    |   0.51 
%%    10000000 |    5.47 ÷  10.50  |   0.52 |     54.74 ÷  104.99    |   0.52 
%%    11000000 |    5.45 ÷  10.51  |   0.52 |     59.90 ÷  115.65    |   0.52 
%% ok
%% 4>
%%

maxUpToN(N) ->
    Max = erlang:system_info(process_limit),
    io:format("Maximum allowed processes:~p~n~n",[Max]),
    io:format("  Processes | (CPU ÷ Wall) μSec |   =    | Total (CPU ÷ Wall) Sec |   =    ~n", []),
    io:format("------------+-------------------+--------+------------------------+------- ~n", []),
    forPrt(1,N).

prt1(N) -> {NN, U1, U2, R12, U3, U4, R34} = maxTime(N * 1000000),
           io:format("  ~9w |  ~6.2f ÷ ~6.2f  | ~6.2f |    ~6.2f ÷ ~7.2f    | ~6.2g ~n", [NN, U1, U2, R12,U3, U4, R34]).

max(N) ->
    Max = erlang:system_info(process_limit),
    io:format("Maximum allowed processes:~p~n",[Max]),
    {NN, U1, U2, R12, U3, U4, R34} = maxTime(N),
    io:format("Process ~p. Time= ~p / ~p, Ratio= ~p. Total CPUtime & WallTime= ~p / ~p seconds, Ratio= ~p.~n",
                      [NN, U1, U2, R12, U3, U4, R34]).

maxTime(N) ->
    statistics(runtime),
    statistics(wall_clock),
    L = for(1, N, fun() -> spawn(fun() -> wait() end) end),
    {_, Time1} = statistics(runtime),
    {_, Time2} = statistics(wall_clock),
    lists:foreach(fun(Pid) -> Pid ! die end, L),
    U1 =  round2(Time1 * 1000 / N),
    U2 =  round2(Time2 * 1000 / N),
    U3 =  round2(Time1 / 1000),      
    U4 =  round2(Time2 / 1000),
    R12 = round2(U1 / U2),
    R34 = round2(U3 / U4),
    {N, U1, U2, R12, U3, U4, R34}.

wait() ->
    receive
    die -> void
    end.

%
% Utility func's
%
for(N, N, F) -> [F()];
for(I, N, F) -> [F()|for(I+1, N, F)].

forPrt(N,N) -> prt1(N);
forPrt(I,N) -> prt1(I), forPrt(I+1,N).

round2(N) -> round(N * 100) / 100.


