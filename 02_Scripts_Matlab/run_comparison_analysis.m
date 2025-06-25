%% SCRIPT MESTRE DE ANÁLISE COMPARATIVA (Fase 1 vs. Fase 2)
% -------------------------------------------------------------------------
% Descrição:
%   Este script orquestra a execução e análise comparativa das suspensões
%   Passiva e Semi-Ativa (Skyhook).
%   1. Roda a simulação passiva e armazena seus resultados.
%   2. Roda a simulação Skyhook e armazena seus resultados.
%   3. Calcula e exibe uma tabela de KPIs comparando os dois sistemas.
%   4. Gera gráficos comparativos sobrepostos para análise visual.
%
% Autor: Anderson Azevedo
% Data:  25/06/2025
% -------------------------------------------------------------------------

clc;
clear;
close all;

fprintf('====================================================\n');
fprintf('INICIANDO ANÁLISE COMPARATIVA: PASSIVO vs. SKYHOOK\n');
fprintf('====================================================\n');

%% --- Execução e Coleta de Dados ---

% Bloco de código para simular um sistema e extrair os dados
run_and_collect = @(model_name) ...
    run_simulation(model_name, 'setup_parameters.m');

% Simulação do Sistema Passivo
fprintf('\n--> Simulando sistema PASSIVO...\n');
results_passive = run_and_collect('passive_suspension');
fprintf('Simulação PASSIVA concluída.\n');

% Simulação do Sistema Skyhook
fprintf('\n--> Simulando sistema SKYHOOK...\n');
results_skyhook = run_and_collect('skyhook_suspension');
fprintf('Simulação SKYHOOK concluída.\n');


%% --- Cálculo de KPIs Comparativos ---

fprintf('\n--> Calculando métricas de desempenho (KPIs)...\n');

% Função para calcular KPIs a partir dos resultados
calculate_kpis = @(results, ms, mus, g) ...
    struct(...
        'accel_rms', rms(results.out_zs_ddot(results.tout >= 2)),...
        'F_min', min(results.out_F_tire(results.tout >= 2)),...
        'load_var', (max(results.out_F_tire(results.tout >= 2)) - min(results.out_F_tire(results.tout >= 2))) / ((ms+mus)*g) * 100 ...
    );

kpis_passive = calculate_kpis(results_passive, results_passive.ms, results_passive.mus, results_passive.g);
kpis_skyhook = calculate_kpis(results_skyhook, results_skyhook.ms, results_skyhook.mus, results_skyhook.g);

% Cálculo da melhoria
comfort_improvement = (1 - (kpis_skyhook.accel_rms / kpis_passive.accel_rms)) * 100;


%% --- Geração da Tabela Markdown para o README ---

fprintf('\n\n--- TABELA DE RESULTADOS PARA O README.md ---\n');
fprintf('(Copie e cole esta tabela no seu arquivo README.md)\n\n');
fprintf('| Métrica (KPI) | Suspensão Passiva | Suspensão Skyhook | Melhoria |\n');
fprintf('| :--- | :--- | :--- | :--- |\n');
fprintf('| **Conforto:** Aceleração RMS do Chassi | %.4f m/s² | **%.4f m/s²** | **%.1f %%** |\n', ...
    kpis_passive.accel_rms, kpis_skyhook.accel_rms, comfort_improvement);
fprintf('| **Dirigibilidade:** Força Mínima no Pneu | %.2f N | %.2f N | - |\n', ...
    kpis_passive.F_min, kpis_skyhook.F_min);
fprintf('| **Variação de Carga no Pneu** | %.2f %% | %.2f %% | - |\n', ...
    kpis_passive.load_var, kpis_skyhook.load_var);
fprintf('\n----------------------------------------------\n\n');


%% --- Geração de Gráficos Comparativos ---

fprintf('--> Gerando gráficos comparativos...\n');

fig_comp = figure('Name', 'Análise Comparativa: Passivo vs. Skyhook', 'NumberTitle', 'off', 'Position', [100, 100, 900, 700]);

% 1. Aceleração do Chassi (Conforto)
subplot(2, 1, 1);
plot(results_passive.tout, results_passive.out_zs_ddot, 'Color', [0.6 0.6 0.6], 'LineWidth', 1, 'DisplayName', 'Passiva');
hold on;
plot(results_skyhook.tout, results_skyhook.out_zs_ddot, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Skyhook');
hold off;
title('Comparativo de Conforto (Aceleração do Chassi)');
xlabel('Tempo (s)'); ylabel('Aceleração (m/s^2)');
grid on; legend('show', 'Location', 'northeast');

% 2. Força no Pneu (Dirigibilidade)
subplot(2, 1, 2);
plot(results_passive.tout, results_passive.out_F_tire, 'Color', [0.9 0.6 0.6], 'LineWidth', 1, 'DisplayName', 'Passiva');
hold on;
plot(results_skyhook.tout, results_skyhook.out_F_tire, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Skyhook');
hold off;
title('Comparativo de Dirigibilidade (Força de Contato do Pneu)');
xlabel('Tempo (s)'); ylabel('Força (N)');
grid on; legend('show', 'Location', 'northeast');

sgtitle('Análise Comparativa de Desempenho', 'FontSize', 16, 'FontWeight', 'bold');

fprintf('Fim do script de análise.\n');
fprintf('====================================================\n');


%% --- Função Auxiliar Local (Versão Corrigida) ---
function results = run_simulation(model_name, setup_script)
    % Esta função encapsula a execução para evitar que variáveis vazem
    % entre as execuções, usando 'SrcWorkspace' para passar os parâmetros.
    
    % A linha 'clearvars' foi removida para evitar o erro de variável limpa.
    % O 'run(setup_script)' já garante a redefinição dos parâmetros.
    
    % Carrega os parâmetros no workspace LOCAL desta função
    run(setup_script);
    
    % Define os caminhos
    current_script_path = fileparts(mfilename('fullpath'));
    project_root_path = fileparts(current_script_path);
    model_full_path = fullfile(project_root_path, '01_Modelos_Simulink', model_name);

    % Executa a simulação, dizendo ao Simulink para procurar os parâmetros
    % no workspace 'current' (o desta função).
    sim_output = sim(model_full_path, 'SrcWorkspace', 'current');
    
    % Coleta os resultados
    params = struct;
    vars = who;
    for i = 1:length(vars)
        if ~ismember(vars{i}, {'params', 'sim_output', 'model_name', 'setup_script', 'current_script_path', 'project_root_path', 'model_full_path'})
            params.(vars{i}) = eval(vars{i});
        end
    end
    
    results = params; 
    results.tout = sim_output.tout;
    sim_vars = sim_output.who;
    for i = 1:length(sim_vars)
       results.(sim_vars{i}) = sim_output.(sim_vars{i}); 
    end
end