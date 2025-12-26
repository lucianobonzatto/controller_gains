function PID_tuning_interactive()
% Carregar dados
t_in_data = 0:0.01:10;
step_data = 2 * ones(size(t_in_data));
ramp_data = t_in_data;
seno_data = sin(2*pi*0.5*t_in_data);
step2_data = (t_in_data>=0)*1 + (t_in_data>=3)*1 + (t_in_data>=6)*(-2);

% Carregar arquivo SID
data = load('DATA.sid', '-mat');
tfx = data.Model{3};

% Escolher entrada
in_data = step2_data;

% Valores iniciais dos ganhos
Kp_init = 1;
Ki_init = 0.1;
Kd_init = 0.01;

% Criar figura com sliders
fig = uifigure('Name', 'PID Tuning Interativo', 'Position', [100 100 800 600]);

% Criar painel para sliders
panel = uipanel(fig, 'Position', [10 10 200 580]);

% Slider Kp
lbl_kp = uilabel(panel, 'Position', [10 520 180 22], 'Text', 'Kp = 1.00');
slider_kp = uislider(panel, 'Position', [10 500 180 3], ...
    'Limits', [0 20], 'Value', Kp_init, ...
    'ValueChangedFcn', @(src, event) updatePlot());

% Slider Ki
lbl_ki = uilabel(panel, 'Position', [10 420 180 22], 'Text', 'Ki = 0.10');
slider_ki = uislider(panel, 'Position', [10 400 180 3], ...
    'Limits', [0 5], 'Value', Ki_init, ...
    'ValueChangedFcn', @(src, event) updatePlot());

% Slider Kd
lbl_kd = uilabel(panel, 'Position', [10 320 180 22], 'Text', 'Kd = 0.01');
slider_kd = uislider(panel, 'Position', [10 300 180 3], ...
    'Limits', [0 2], 'Value', Kd_init, ...
    'ValueChangedFcn', @(src, event) updatePlot());

% Labels para informações do sistema
lbl_info = uilabel(panel, 'Position', [10 200 180 80], ...
    'Text', 'Ajuste os ganhos...', 'WordWrap', 'on');

% Criar eixo para o gráfico
ax = uiaxes(fig, 'Position', [230 50 550 500]);

% Plotar inicial
updatePlot();

    function updatePlot()
        % Obter valores dos sliders
        Kp = slider_kp.Value;
        Ki = slider_ki.Value;
        Kd = slider_kd.Value;
        
        % Atualizar labels
        lbl_kp.Text = sprintf('Kp = %.2f', Kp);
        lbl_ki.Text = sprintf('Ki = %.2f', Ki);
        lbl_kd.Text = sprintf('Kd = %.3f', Kd);
        
        % Criar PID e sistema em malha fechada
        PID = pid(Kp, Ki, Kd);
        sys_closed = feedback(PID * tfx, 1);
        
        % Simular resposta
        [out_data, t_out_data] = lsim(sys_closed, in_data, t_in_data);
        
        % Calcular informações
        try
            info = stepinfo(sys_closed);
            info_text = sprintf('Rise Time: %.2fs\nSettle Time: %.2fs\nOvershoot: %.1f%%', ...
                info.RiseTime, info.SettlingTime, info.Overshoot);
        catch
            info_text = 'Sistema instável';
        end
        lbl_info.Text = info_text;
        
        % Plotar
        cla(ax);
        plot(ax, t_in_data, in_data, 'b--', 'LineWidth', 1.5, 'DisplayName', 'Entrada');
        hold(ax, 'on');
        plot(ax, t_out_data, out_data, 'r', 'LineWidth', 1.5, 'DisplayName', 'Saída');
        hold(ax, 'off');
        title(ax, 'Resposta do Sistema em Malha Fechada - Eixo X');
        xlabel(ax, 'Tempo (s)');
        ylabel(ax, 'Amplitude');
        legend(ax, 'show', 'Location', 'best');
        grid(ax, 'on');
        
        % Exibir ganhos no console
        fprintf('Kp = %.2f, Ki = %.2f, Kd = %.3f\n', Kp, Ki, Kd);
    end
end
