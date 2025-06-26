%% SCRIPT DE PLOTAGEM COMPARATIVA FINAL
% -------------------------------------------------------------------------
% Descrição:
%   Este script carrega os resultados das simulações salvos em arquivos .mat
%   e gera os gráficos e KPIs comparativos.
% -------------------------------------------------------------------------

clc; 
clear; 
close all;

fprintf('====================================================\n');
fprintf('CARREGANDO E PLOTANDO RESULTADOS COMPARATIVOS\n');
fprintf('====================================================\n');

% --- Carrega os dados salvos ---
load('passive_results.mat');
% Renomeia as variáveis para evitar conflitos
results_passive.tout = tout;
results_passive.zs_ddot = out_zs_ddot;
results_passive.F_tire = out_F_tire;

load('skyhook_results.mat');
results_skyhook.tout = tout;
results_skyhook.zs_ddot = out_zs_ddot;
results_skyhook.F_tire = out_F_tire;

load('pid_results.mat');
results_pid.tout = tout;
results_pid.zs_ddot = out_zs_ddot;
results_pid.F_tire = out_F_tire;
if exist('out_E_actuator', 'var'), results_pid.E_actuator = out_E_actuator; end


% --- Cálculo de KPIs e Geração de Gráficos ---
run('02_Scripts_Matlab/setup_parameters.m');
results_passive.ms = ms; results_passive.mus = mus; results_passive.g = g;
results_skyhook.ms = ms; results_skyhook.mus = mus; results_skyhook.g = g;
results_pid.ms = ms; results_pid.mus = mus; results_pid.g = g;

kpis_passive = calculate_kpis(results_passive);
kpis_skyhook = calculate_kpis(results_skyhook);
kpis_pid = calculate_kpis(results_pid);
comfort_impr_skyhook = (1 - (kpis_skyhook.accel_rms / kpis_passive.accel_rms)) * 100;
comfort_impr_pid = (1 - (kpis_pid.accel_rms / kpis_passive.accel_rms)) * 100;

fprintf('\n\n--- TABELA DE RESULTADOS PARA O README.md ---\n');
fprintf('| Métrica (KPI) | Suspensão Passiva | Suspensão Skyhook | Suspensão Ativa (PID) |\n');
fprintf('| :--- | :--- | :--- | :--- |\n');
fprintf('| **Conforto:** Aceleração RMS (m/s²) | %.4f | **%.4f** (%.1f%%) | **%.4f** (%.1f%%) |\n',kpis_passive.accel_rms, kpis_skyhook.accel_rms, comfort_impr_skyhook, kpis_pid.accel_rms, comfort_impr_pid);
fprintf('| **Dirigibilidade:** Força Mínima no Pneu (N) | %.2f | %.2f | **%.2f** |\n',kpis_passive.F_min, kpis_skyhook.F_min, kpis_pid.F_min);
fprintf('| **Custo Energético:** Energia Total (J) | N/A | N/A | **%.2f** |\n',kpis_pid.energy);
fprintf('\n----------------------------------------------\n\n');

fig_comp = figure('Name', 'Análise Comparativa: Passivo vs. Skyhook vs. PID', 'NumberTitle', 'off', 'Position', [100, 100, 900, 700]);
subplot(2, 1, 1);
plot(results_passive.tout, results_passive.zs_ddot, 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'DisplayName', 'Passiva');
hold on;
plot(results_skyhook.tout, results_skyhook.zs_ddot, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Skyhook');
plot(results_pid.tout, results_pid.zs_ddot, 'b-', 'LineWidth', 2.0, 'DisplayName', 'PID');
hold off; title('Comparativo de Conforto (Aceleração do Chassi)'); xlabel('Tempo (s)'); ylabel('Aceleração (m/s^2)'); grid on; legend('show');
subplot(2, 1, 2);
plot(results_passive.tout, results_passive.F_tire, 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'DisplayName', 'Passiva');
hold on;
plot(results_skyhook.tout, results_skyhook.F_tire, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Skyhook');
plot(results_pid.tout, results_pid.F_tire, 'b-', 'LineWidth', 2.0, 'DisplayName', 'PID');
hold off; title('Comparativo de Dirigibilidade (Força de Contato do Pneu)'); xlabel('Tempo (s)'); ylabel('Força (N)'); grid on; legend('show');
sgtitle('Análise Comparativa de Desempenho dos Controladores', 'FontSize', 16, 'FontWeight', 'bold');
fprintf('Fim do script de análise.\n');

%% --- Função Auxiliar Local: Cálculo de KPIs ---
function kpis = calculate_kpis(results, ms, mus, g)
    tout = results.tout;
    idx_start = find(tout >= 2, 1);
    
    kpis.accel_rms = rms(results.zs_ddot(idx_start:end));
    kpis.F_min = min(results.F_tire(idx_start:end));
    
    if isfield(results, 'E_actuator') && ~isempty(results.E_actuator)
        kpis.energy = results.E_actuator(end);
    else
        kpis.energy = NaN;
    end
end