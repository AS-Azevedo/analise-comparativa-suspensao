%% SCRIPT MESTRE DE ANÁLISE COMPARATIVA (Fases 1, 2 e 3)
% -------------------------------------------------------------------------
% Descrição:
%   Este script orquestra a execução e análise comparativa das suspensões
%   Passiva, Semi-Ativa (Skyhook) e Ativa (PID).
%
% Autor: [Seu Nome]
% Data: 25/06/2025
% -------------------------------------------------------------------------

clc; 
clear; 
close all;

fprintf('====================================================\n');
fprintf('INICIANDO ANÁLISE COMPARATIVA: PASSIVO vs. SKYHOOK vs. PID\n');
fprintf('====================================================\n');

%% --- Execução e Coleta de Dados ---

% Função anônima para simplificar a chamada da simulação
run_and_collect = @(model_name) ...
    run_simulation(model_name, 'setup_parameters.m');

% Executa as 3 simulações em sequência e armazena os resultados
fprintf('\n--> Simulando sistema PASSIVO...\n');
results_passive = run_and_collect('passive_suspension');
fprintf('Simulação PASSIVA concluída.\n');

fprintf('\n--> Simulando sistema SKYHOOK...\n');
results_skyhook = run_and_collect('skyhook_suspension');
fprintf('Simulação SKYHOOK concluída.\n');

fprintf('\n--> Simulando sistema PID...\n');
results_pid = run_and_collect('pid_suspension');
fprintf('Simulação PID concluída.\n');


%% --- Cálculo de KPIs Comparativos ---

fprintf('\n--> Calculando métricas de desempenho (KPIs)...\n');

% Chama a função auxiliar para calcular os KPIs para cada resultado
kpis_passive = calculate_kpis(results_passive);
kpis_skyhook = calculate_kpis(results_skyhook);
kpis_pid = calculate_kpis(results_pid);

% Cálculo das melhorias em relação ao sistema passivo
comfort_impr_skyhook = (1 - (kpis_skyhook.accel_rms / kpis_passive.accel_rms)) * 100;
comfort_impr_pid = (1 - (kpis_pid.accel_rms / kpis_passive.accel_rms)) * 100;


%% --- Geração da Tabela Markdown para o README ---

fprintf('\n\n--- TABELA DE RESULTADOS PARA O README.md ---\n');
fprintf('(Copie e cole esta tabela no seu arquivo README.md)\n\n');
fprintf('| Métrica (KPI) | Suspensão Passiva | Suspensão Skyhook | Suspensão Ativa (PID) |\n');
fprintf('| :--- | :--- | :--- | :--- |\n');
fprintf('| **Conforto:** Aceleração RMS (m/s²) | %.4f | **%.4f** (%.1f%%) | **%.4f** (%.1f%%) |\n', ...
    kpis_passive.accel_rms, kpis_skyhook.accel_rms, comfort_impr_skyhook, kpis_pid.accel_rms, comfort_impr_pid);
fprintf('| **Dirigibilidade:** Força Mínima no Pneu (N) | %.2f | %.2f | **%.2f** |\n', ...
    kpis_passive.F_min, kpis_skyhook.F_min, kpis_pid.F_min);
fprintf('| **Custo Energético:** Energia Total (J) | N/A | N/A | **%.2f** |\n', ...
    kpis_pid.energy);
fprintf('\n----------------------------------------------\n\n');


%% --- Geração de Gráficos Comparativos ---

fprintf('--> Gerando gráficos comparativos...\n');

fig_comp = figure('Name', 'Análise Comparativa: Passivo vs. Skyhook vs. PID', 'NumberTitle', 'off', 'Position', [100, 100, 900, 700]);

% 1. Aceleração do Chassi (Conforto)
subplot(2, 1, 1);
plot(results_passive.tout, results_passive.out_zs_ddot, 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'DisplayName', 'Passiva');
hold on;
plot(results_skyhook.tout, results_skyhook.out_zs_ddot, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Skyhook');
plot(results_pid.tout, results_pid.out_zs_ddot, 'b-', 'LineWidth', 2.0, 'DisplayName', 'PID'); % PID com mais destaque
hold off;
title('Comparativo de Conforto (Aceleração do Chassi)');
xlabel('Tempo (s)'); ylabel('Aceleração (m/s^2)');
grid on; legend('show', 'Location', 'northeast');

% 2. Força no Pneu (Dirigibilidade)
subplot(2, 1, 2);
plot(results_passive.tout, results_passive.out_F_tire, 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'DisplayName', 'Passiva');
hold on;
plot(results_skyhook.tout, results_skyhook.out_F_tire, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Skyhook');
plot(results_pid.tout, results_pid.out_F_tire, 'b-', 'LineWidth', 2.0, 'DisplayName', 'PID'); % PID com mais destaque
hold off;
title('Comparativo de Dirigibilidade (Força de Contato do Pneu)');
xlabel('Tempo (s)'); ylabel('Força (N)');
grid on; legend('show', 'Location', 'northeast');

sgtitle('Análise Comparativa de Desempenho dos Controladores', 'FontSize', 16, 'FontWeight', 'bold');
fprintf('Gráficos comparativos gerados. Dashboard do PID será gerado a seguir.\n\n');

%% --- Animação do Sistema PID ---
% (A animação usará os resultados da simulação PID)

fprintf('--> Gerando dashboard dinâmico para o sistema PID...\n');
enable_animation = true;
if ~enable_animation, fprintf('Animação desabilitada.\n'); return; end

time = results_pid.tout; zs = results_pid.out_zs; zr = results_pid.out_zr;
if isfield(results_pid, 'out_zus'), zus = results_pid.out_zus; else, zus = zr + (-(results_pid.ms+results_pid.mus)*results_pid.g / results_pid.kt); end

fig_dashboard = figure('Name', 'Dashboard Dinâmico da Suspensão Ativa (PID)', 'NumberTitle', 'off', 'Position', [50, 50, 1200, 700]);
ax_anim = subplot(2, 2, [1, 3]); title(ax_anim, 'Animação do Modelo 1/4 de Veículo (PID)', 'Color', 'w');
ax_accel = subplot(2, 2, 2); title(ax_accel, 'Conforto: Aceleração do Chassi');
ax_force = subplot(2, 2, 4); title(ax_force, 'Dirigibilidade: Força de Contato do Pneu');

hold(ax_anim, 'on'); ax_anim.Color = [0.1 0.1 0.12]; ax_anim.XColor = [0.9 0.9 0.9]; ax_anim.YColor = [0.9 0.9 0.9]; grid on;
set(ax_anim, 'XLim', [-2, 2], 'YLim', [-0.5, 0.5]); xlabel(ax_anim, 'Largura (m)'); ylabel(ax_anim, 'Deslocamento Vertical (m)');
w_ms = 1.5; h_ms = 0.2; w_mus = 0.5; h_mus = 0.1;
chassis_verts_x = [-w_ms/2, w_ms/2, w_ms/2, -w_ms/2]; chassis_y_base = zs(1) + h_mus / 2; chassis_verts_y = [chassis_y_base, chassis_y_base, chassis_y_base + h_ms, chassis_y_base + h_ms];
h_chassis = patch(ax_anim, chassis_verts_x, chassis_verts_y, [0.2, 0.6, 1], 'EdgeColor', 'w', 'LineWidth', 1.5);
wheel_y_base = zus(1) - h_mus / 2; wheel_verts_x = [-w_mus/2, w_mus/2, w_mus/2, -w_mus/2]; wheel_verts_y = [wheel_y_base, wheel_y_base, wheel_y_base + h_mus, wheel_y_base + h_mus];
h_wheel = patch(ax_anim, wheel_verts_x, wheel_verts_y, [0.5, 0.5, 0.5], 'EdgeColor', 'w', 'LineWidth', 1.5);
h_spring = plot(ax_anim, [0, 0], [zus(1), zs(1)], 'y-', 'LineWidth', 4); h_road = plot(ax_anim, ax_anim.XLim, [zr(1), zr(1)], 'w-', 'LineWidth', 2);
h_time_text = text(ax_anim, ax_anim.XLim(1)*0.9, ax_anim.YLim(2)*0.9, sprintf('Tempo: %.2f s', time(1)), 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');

hold(ax_accel, 'on'); grid(ax_accel, 'on'); plot(ax_accel, time, results_pid.out_zs_ddot, 'b-', 'LineWidth', 1.5);
y_lim_accel = get(ax_accel, 'YLim'); h_marker_accel = plot(ax_accel, [time(1) time(1)], y_lim_accel, 'Color', [1 1 0.2], 'LineWidth', 1);
xlabel(ax_accel, 'Tempo (s)'); ylabel(ax_accel, 'Aceleração (m/s^2)');
hold(ax_force, 'on'); grid(ax_force, 'on'); plot(ax_force, time, results_pid.out_F_tire, 'r-', 'LineWidth', 1.5);
y_lim_force = get(ax_force, 'YLim'); h_marker_force = plot(ax_force, [time(1) time(1)], y_lim_force, 'Color', [1 1 0.2], 'LineWidth', 1);
xlabel(ax_force, 'Tempo (s)'); ylabel(ax_force, 'Força (N)');

desired_total_duration = 20;
frame_step = round((1/60) / (time(2)-time(1))); if frame_step == 0, frame_step = 1; end
T_simulation_end = time(end);

fprintf('Iniciando loop da animação (duração alvo: %.1f s)...\n', desired_total_duration);
animation_start_time = tic;
for k = 1:frame_step:length(time)
    if ~isvalid(fig_dashboard), fprintf('Janela fechada.\n'); break; end
    current_sim_time = time(k);
    set(h_chassis, 'YData', [zs(k) + h_mus/2, zs(k) + h_mus/2, zs(k) + h_mus/2 + h_ms, zs(k) + h_mus/2 + h_ms]);
    set(h_wheel, 'YData', [zus(k) - h_mus/2, zus(k) - h_mus/2, zus(k) - h_mus/2 + h_mus, zus(k) - h_mus/2 + h_mus]);
    set(h_spring, 'YData', [zus(k), zs(k)]); set(h_road, 'YData', [zr(k), zr(k)]); set(h_time_text, 'String', sprintf('Tempo: %.2f s', current_sim_time));
    set(h_marker_accel, 'XData', [current_sim_time, current_sim_time]);
    set(h_marker_force, 'XData', [current_sim_time, current_sim_time]);
    drawnow;
    target_wall_time = (current_sim_time / T_simulation_end) * desired_total_duration;
    while toc(animation_start_time) < target_wall_time, pause(0.001); end
end
fprintf('Animação concluída.\n');
fprintf('====================================================\n');
fprintf('Fim do Fluxo de Trabalho.\n');
fprintf('====================================================\n');

%% --- Função Auxiliar Local: Executar Simulação ---
function results = run_simulation(model_name, setup_script)
    run(setup_script);
    current_script_path = fileparts(mfilename('fullpath'));
    project_root_path = fileparts(current_script_path);
    model_full_path = fullfile(project_root_path, '01_Modelos_Simulink', model_name);
    sim_output = sim(model_full_path, 'SrcWorkspace', 'current');
    
    params = struct; vars = who;
    for i = 1:length(vars)
        if ~ismember(vars{i}, {'params', 'sim_output', 'model_name', 'setup_script', 'current_script_path', 'project_root_path', 'model_full_path'})
            params.(vars{i}) = eval(vars{i});
        end
    end
    results = params; results.tout = sim_output.tout;
    sim_vars = sim_output.who;
    for i = 1:length(sim_vars), results.(sim_vars{i}) = sim_output.(sim_vars{i}); end
end

%% --- Função Auxiliar Local: Cálculo de KPIs ---
function kpis = calculate_kpis(results)
    ms = results.ms; mus = results.mus; g = results.g; tout = results.tout;
    idx_start = find(tout >= 2, 1);
    kpis.accel_rms = rms(results.out_zs_ddot(idx_start:end));
    kpis.F_min = min(results.out_F_tire(idx_start:end));
    F_max = max(results.out_F_tire(idx_start:end));
    kpis.load_var = (F_max - kpis.F_min) / ((ms+mus)*g) * 100;
    if isfield(results, 'out_E_actuator'), kpis.energy = sum(abs(results.out_E_actuator(end))); else, kpis.energy = NaN; end
end