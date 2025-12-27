clear;
close all;

%% Carregar planta identificada
data = load('DATA.sid', '-mat');
tfx = data.Model{3};  % Função de transferência do eixo X

%% Parâmetros de simulação
Ts = 0.1;  % Período de amostragem (10 Hz)
t = 0:Ts:10;  % Tempo de simulação (10 segundos)

%% Entrada de teste
entrada = (t>=0)*1 + (t>=3)*1 + (t>=6)*(-2);  % Múltiplos degraus

%% 1. CONTROLADOR PID (para comparação)
PID_auto = pidtune(tfx, 'PID');
sys_pid_closed = feedback(PID_auto * tfx, 1);

% Simular resposta PID
[y_pid, t_pid] = lsim(sys_pid_closed, entrada, t);

%% 2. CONTROLADOR MPC

% Converter para espaço de estados e discretizar
sys_cont = ss(tfx);  % Contínuo
sys_disc = c2d(sys_cont, Ts);  % Discreto

% Criar controlador MPC
mpcobj = mpc(sys_disc, Ts);

% Configurar horizontes
mpcobj.PredictionHorizon = 30;  % Prediz 3 segundos à frente
mpcobj.ControlHorizon = 10;     % Otimiza próximo 1 segundo

% Configurar pesos (função de custo)
mpcobj.Weights.OutputVariables = 1.0;     % Quer seguir referência
mpcobj.Weights.ManipulatedVariables = 0.1;  % Penaliza esforço
mpcobj.Weights.ManipulatedVariablesRate = 0.5;  % Suaviza comandos

% Restrições de velocidade
mpcobj.MV.Min = -5;  % Velocidade mínima
mpcobj.MV.Max = 5;   % Velocidade máxima

% Converter para sistema em malha fechada
sys_mpc_closed = feedback(mpcobj);

% Simular resposta MPC
[y_mpc, t_mpc] = lsim(sys_mpc_closed, entrada, t);

%% 3. PLOTAR COMPARAÇÃO

figure('Position', [100 100 900 600]);

% Subplot 1: Entrada
subplot(3,1,1);
plot(t, entrada, 'k--', 'LineWidth', 2);
title('Sinal de Referência');
ylabel('Amplitude');
grid on;
legend('Referência');

% Subplot 2: Comparação de saídas
subplot(3,1,2);
plot(t, entrada, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Referência');
hold on;
plot(t_pid, y_pid, 'b', 'LineWidth', 1.5, 'DisplayName', 'PID');
plot(t_mpc, y_mpc, 'r', 'LineWidth', 1.5, 'DisplayName', 'MPC');
hold off;
title('Comparação: PID vs MPC');
ylabel('Saída');
grid on;
legend('Location', 'best');

% Subplot 3: Erro
subplot(3,1,3);
erro_pid = entrada - y_pid';
erro_mpc = entrada - y_mpc';
plot(t_pid, erro_pid, 'b', 'LineWidth', 1.5, 'DisplayName', 'Erro PID');
hold on;
plot(t_mpc, erro_mpc, 'r', 'LineWidth', 1.5, 'DisplayName', 'Erro MPC');
hold off;
title('Erro de Rastreamento');
xlabel('Tempo (s)');
ylabel('Erro');
grid on;
legend('Location', 'best');

%% 4. EXIBIR INFORMAÇÕES

fprintf('\n========== COMPARAÇÃO PID vs MPC ==========\n\n');

fprintf('CONTROLADOR PID:\n');
fprintf('  Kp = %.4f\n', PID_auto.Kp);
fprintf('  Ki = %.4f\n', PID_auto.Ki);
fprintf('  Kd = %.4f\n', PID_auto.Kd);

fprintf('\nCONTROLADOR MPC:\n');
fprintf('  Horizonte de Predição: %d passos (%.1f s)\n', ...
    mpcobj.PredictionHorizon, mpcobj.PredictionHorizon*Ts);
fprintf('  Horizonte de Controle: %d passos (%.1f s)\n', ...
    mpcobj.ControlHorizon, mpcobj.ControlHorizon*Ts);
fprintf('  Peso Saída: %.2f\n', mpcobj.Weights.OutputVariables);
fprintf('  Peso Controle: %.2f\n', mpcobj.Weights.ManipulatedVariables);
fprintf('  Peso Variação: %.2f\n', mpcobj.Weights.ManipulatedVariablesRate);

fprintf('\nDESEMPENHO:\n');
% Calcular métricas
mse_pid = mean(erro_pid.^2);
mse_mpc = mean(erro_mpc.^2);
fprintf('  MSE PID: %.6f\n', mse_pid);
fprintf('  MSE MPC: %.6f\n', mse_mpc);
fprintf('  Melhoria: %.1f%%\n', (1 - mse_mpc/mse_pid) * 100);

fprintf('\n==========================================\n');

