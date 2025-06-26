%% SCRIPT MESTRE FINAL (Abordagem de Objeto de Saída)
% -------------------------------------------------------------------------
% Descrição:
%   Versão final que captura o objeto de saída único do Simulink e o
%   processa de forma robusta, resolvendo os erros de compatibilidade.
% -------------------------------------------------------------------------

clc; 
clear; 
close all;

fprintf('====================================================\n');
fprintf('INICIANDO ANÁLISE COMPARATIVA COMPLETA\n');
fprintf('====================================================\n');

% --- Executa as simulações e coleta os dados ---
% A função auxiliar 'run_simulation_final' foi corrigida abaixo
fprintf('\n--> Simulando sistema PASSIVO...\n');
results_passive = run_simulation_final('passive_suspension', 'setup_parameters.m');
fprintf('Simulação PASSIVA concluída.\n');

fprintf('\n--> Simulando sistema SKYHOOK...\n');
results_skyhook = run_simulation_final('skyhook_suspension', 'setup_parameters.m');
fprintf('Simulação SKYHOOK concluída.\n');

fprintf('\n--> Simulando sistema PID...\n');
results_pid = run_simulation_final('pid_suspension', 'setup_parameters.m');
fprintf('Simulação PID concluída.\n');

%% --- Cálculo de KPIs e Geração de Gráficos ---
fprintf('\n--> Calculando métricas e gerando gráficos...\n');
run('setup_parameters.m');
results_passive.ms = ms; results_passive.mus = mus; results_passive.g = g;
results_skyhook.ms = ms; results_skyhook.mus = mus; results_skyhook.g = g;
results_pid.ms = ms; results_pid.mus = mus; results_pid.g = g;

kpis_passive = calculate_kpis(results_passive);
kpis_skyhook = calculate_kpis(results_skyhook);
kpis_pid = calculate_kpis(results_pid);
comfort_impr_skyhook = (1 - (kpis_skyhook.accel_rms / kpis_passive.accel_rms)) * 100;
comfort_impr_pid = (1 - (kpis_pid.accel_rms / kpis_passive.accel_rms)) * 100;

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

fig_comp = figure('Name', 'Análise Comparativa: Passivo vs. Skyhook vs. PID', 'NumberTitle', 'off', 'Position', [100, 100, 900, 700]);
subplot(2, 1, 1);
plot(results_passive.tout, results_passive.zs_ddot, 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'DisplayName', 'Passiva');
hold on;
plot(results_skyhook.tout, results_skyhook.zs_ddot, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Skyhook');
plot(results_pid.tout, results_pid.zs_ddot, 'b-', 'LineWidth', 2.0, 'DisplayName', 'PID');
hold off; title('Comparativo de Conforto (Aceleração do Chassi)'); xlabel('Tempo (s)'); ylabel('Aceleração (m/s^2)');
grid on; legend('show', 'Location', 'northeast');
subplot(2, 1, 2);
plot(results_passive.tout, results_passive.F_tire, 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'DisplayName', 'Passiva');
hold on;
plot(results_skyhook.tout, results_skyhook.F_tire, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Skyhook');
plot(results_pid.tout, results_pid.F_tire, 'b-', 'LineWidth', 2.0, 'DisplayName', 'PID');
hold off; title('Comparativo de Dirigibilidade (Força de Contato do Pneu)'); xlabel('Tempo (s)'); ylabel('Força (N)');
grid on; legend('show', 'Location', 'northeast');
sgtitle('Análise Comparativa de Desempenho dos Controladores', 'FontSize', 16, 'FontWeight', 'bold');
fprintf('Fim do script de análise.\n');
fprintf('====================================================\n');


%% --- Função Auxiliar Local (Versão Final Definitiva) ---
function results = run_simulation_final(model_name, setup_script)
    % Versão final que usa a configuração de saída correta ('Structure') para
    % trabalhar com o Bus Creator.

    fprintf('\n--> Executando %s...\n', model_name);
    run(setup_script);
    
    % Prepara o ambiente do workspace base para a simulação
    vars_to_assign = who;
    cleanup_obj = onCleanup(@() evalin('base', ['clear ' strjoin(vars_to_assign, ' ')]));
    for i = 1:length(vars_to_assign)
        assignin('base', vars_to_assign{i}, eval(vars_to_assign{i}));
    end

    current_script_path = fileparts(mfilename('fullpath'));
    project_root_path = fileparts(current_script_path);
    model_full_path = fullfile(project_root_path, '01_Modelos_Simulink', model_name);
    
    % --- MUDANÇA CRÍTICA ---
    % Executa a simulação e captura a saída no formato de ESTRUTURA,
    % que respeita os nomes de sinais do Bus Creator.
    [t, ~, y] = sim(model_full_path, 'SaveFormat', 'Structure');
    
    % Copia os resultados para um struct de saída limpo
    results = struct();
    results.tout = t; % Salva o vetor de tempo
    
    % Copia os sinais da estrutura de saída 'y' para o nosso struct 'results'
    if ~isempty(y)
        field_names = fieldnames(y);
        for i = 1:length(field_names)
            results.(field_names{i}) = y.(field_names{i});
        end
    end
    
    % Limpa o workspace base para a próxima simulação
    evalin('base', 'clear all');
end
%% --- Função Auxiliar Local: Cálculo de KPIs ---
function kpis = calculate_kpis(results)
    tout = results.tout;
    idx_start = find(tout >= 2, 1);
    
    kpis.accel_rms = rms(results.zs_ddot(idx_start:end));
    kpis.F_min = min(results.F_tire(idx_start:end));
    
    % Adiciona os parâmetros ao struct para o cálculo de variação de carga
    ms = results.ms; mus = results.mus; g = results.g;
    F_max = max(results.F_tire(idx_start:end));
    kpis.load_var = (F_max - kpis.F_min) / ((ms+mus)*g) * 100;

    if isfield(results, 'E_actuator') && ~isempty(results.E_actuator)
        kpis.energy = results.E_actuator(end);
    else
        kpis.energy = NaN;
    end
end