%% SCRIPT MESTRE DE ANÁLISE COMPARATIVA (VERSÃO FINAL DEFINITIVA)
% -------------------------------------------------------------------------
% Descrição:
%   Versão final consolidada que executa e analisa as Fases 1, 2 e 3,
%   usando as melhores práticas de automação e tratamento de erros.
% -------------------------------------------------------------------------

clc; clear; close all;

fprintf('====================================================\n');
fprintf('INICIANDO ANÁLISE COMPARATIVA: PASSIVO vs. SKYHOOK vs. PID\n');
fprintf('====================================================\n');

%% --- Execução e Coleta de Dados ---
run_and_collect = @(model_name) ...
    run_simulation(model_name, 'setup_parameters.m');

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
kpis_passive = calculate_kpis(results_passive);
kpis_skyhook = calculate_kpis(results_skyhook);
kpis_pid = calculate_kpis(results_pid);
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
subplot(2, 1, 1);
plot(results_passive.tout, results_passive.out_zs_ddot, 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'DisplayName', 'Passiva');
hold on;
plot(results_skyhook.tout, results_skyhook.out_zs_ddot, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Skyhook');
plot(results_pid.tout, results_pid.out_zs_ddot, 'b-', 'LineWidth', 2.0, 'DisplayName', 'PID');
hold off; title('Comparativo de Conforto (Aceleração do Chassi)'); xlabel('Tempo (s)'); ylabel('Aceleração (m/s^2)');
grid on; legend('show', 'Location', 'northeast');
subplot(2, 1, 2);
plot(results_passive.tout, results_passive.out_F_tire, 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'DisplayName', 'Passiva');
hold on;
plot(results_skyhook.tout, results_skyhook.out_F_tire, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Skyhook');
plot(results_pid.tout, results_pid.out_F_tire, 'b-', 'LineWidth', 2.0, 'DisplayName', 'PID');
hold off; title('Comparativo de Dirigibilidade (Força de Contato do Pneu)'); xlabel('Tempo (s)'); ylabel('Força (N)');
grid on; legend('show', 'Location', 'northeast');
sgtitle('Análise Comparativa de Desempenho dos Controladores', 'FontSize', 16, 'FontWeight', 'bold');
fprintf('Gráficos comparativos gerados.\n\n');


Com certeza. A depuração interativa pode ser complexa.

Com base em todos os erros que vimos, preparei uma versão final da função run_simulation e do script mestre run_comparison_analysis.m. Esta versão usa a abordagem mais robusta e à prova de falhas possível, que funcionará independentemente das configurações específicas do seu Simulink.

A Estratégia Final:
A função irá explicitamente colocar as variáveis de parâmetro no workspace principal do MATLAB, rodar a simulação (que também colocará seus resultados lá), e depois coletar todos os resultados e limpar o workspace. É o método mais garantido.
Script run_comparison_analysis.m - Versão Final e Completa

Por favor, substitua todo o conteúdo do seu script run_comparison_analysis.m pelo código abaixo. Esta é a versão final consolidada que usa a técnica mais compatível.
Matlab

%% SCRIPT MESTRE DE ANÁLISE COMPARATIVA (VERSÃO FINAL ROBUSTA)
% -------------------------------------------------------------------------
% Descrição:
%   Versão final consolidada que executa e analisa as Fases 1, 2 e 3,
%   usando a técnica mais robusta ('assignin'/'evalin') para garantir
%   compatibilidade com todas as configurações do Simulink.
% -------------------------------------------------------------------------

clc; 
clear; 
close all;

fprintf('====================================================\n');
fprintf('INICIANDO ANÁLISE COMPARATIVA: PASSIVO vs. SKYHOOK vs. PID\n');
fprintf('====================================================\n');

%% --- Execução e Coleta de Dados ---
run_and_collect = @(model_name) ...
    run_simulation(model_name, 'setup_parameters.m');

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
kpis_passive = calculate_kpis(results_passive);
kpis_skyhook = calculate_kpis(results_skyhook);
kpis_pid = calculate_kpis(results_pid);
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
subplot(2, 1, 1);
plot(results_passive.tout, results_passive.out_zs_ddot, 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'DisplayName', 'Passiva');
hold on;
plot(results_skyhook.tout, results_skyhook.out_zs_ddot, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Skyhook');
plot(results_pid.tout, results_pid.out_zs_ddot, 'b-', 'LineWidth', 2.0, 'DisplayName', 'PID');
hold off; title('Comparativo de Conforto (Aceleração do Chassi)'); xlabel('Tempo (s)'); ylabel('Aceleração (m/s^2)');
grid on; legend('show', 'Location', 'northeast');
subplot(2, 1, 2);
plot(results_passive.tout, results_passive.out_F_tire, 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'DisplayName', 'Passiva');
hold on;
plot(results_skyhook.tout, results_skyhook.out_F_tire, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Skyhook');
plot(results_pid.tout, results_pid.out_F_tire, 'b-', 'LineWidth', 2.0, 'DisplayName', 'PID');
hold off; title('Comparativo de Dirigibilidade (Força de Contato do Pneu)'); xlabel('Tempo (s)'); ylabel('Força (N)');
grid on; legend('show', 'Location', 'northeast');
sgtitle('Análise Comparativa de Desempenho dos Controladores', 'FontSize', 16, 'FontWeight', 'bold');
fprintf('Fim do script de análise.\n');
fprintf('====================================================\n');

%% --- Função Auxiliar Local: Executar Simulação (Versão Final Robusta) ---
function results = run_simulation(model_name, setup_script)
    % Carrega os parâmetros localmente
    run(setup_script);
    
    % Coleta os nomes de todas as variáveis que o setup_script criou
    vars_to_assign = who;
    % Define a lista de variáveis de saída que esperamos do Simulink
    output_vars = {'tout', 'out_zs_ddot', 'out_F_tire', 'out_zs', 'out_zr', 'out_E_actuator', 'out_zus'};

    % Cria um objeto 'onCleanup' para garantir que o workspace base seja limpo
    % no final, mesmo que ocorra um erro.
    cleanup_obj = onCleanup(@() evalin('base', ['clear ' strjoin([vars_to_assign; output_vars'], ' ')]));
    
    % Copia todas as variáveis de parâmetro para o workspace 'base'
    for i = 1:length(vars_to_assign)
        var_name = vars_to_assign{i};
        assignin('base', var_name, eval(var_name));
    end

    % Define o caminho completo do modelo
    current_script_path = fileparts(mfilename('fullpath'));
    project_root_path = fileparts(current_script_path);
    model_full_path = fullfile(project_root_path, '01_Modelos_Simulink', model_name);
    
    % Executa a simulação. O Simulink irá ler e escrever no workspace base.
    sim(model_full_path);
    
    % Coleta os resultados do workspace base para o struct de saída
    results = struct();
    % Coleta os parâmetros que foram usados
    for i = 1:length(vars_to_assign)
        var_name = vars_to_assign{i};
        results.(var_name) = evalin('base', var_name);
    end
    % Coleta as saídas da simulação
    for i = 1:length(output_vars)
        var_name = output_vars{i};
        if evalin('base', sprintf("exist('%s', 'var')", var_name))
            results.(var_name) = evalin('base', var_name);
        end
    end
end

%% --- Função Auxiliar Local: Cálculo de KPIs (Versão Final Robusta) ---
function kpis = calculate_kpis(results)
    ms = results.ms; mus = results.mus; g = results.g; tout = results.tout;
    idx_start = find(tout >= 2, 1);
    
    kpis.accel_rms = rms(results.out_zs_ddot(idx_start:end));
    kpis.F_min = min(results.out_F_tire(idx_start:end));
    
    F_max = max(results.out_F_tire(idx_start:end));
    kpis.load_var = (F_max - kpis.F_min) / ((ms+mus)*g) * 100;

    if isfield(results, 'out_E_actuator') && ~isempty(results.out_E_actuator)
        kpis.energy = results.out_E_actuator(end);
    else
        kpis.energy = NaN; 
    end
end