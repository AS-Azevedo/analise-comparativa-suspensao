%% SCRIPT MESTRE - SIMULAÇÃO E ANÁLISE DA SUSPENSÃO PASSIVA (V. FINAL-PRO)
% -------------------------------------------------------------------------
% Descrição:
%   Versão final da Fase 1. Usa a técnica de "marcador de tempo" para uma
%   animação fluida e com duração controlada e precisa.
% -------------------------------------------------------------------------

clc; clear; close all;

fprintf('====================================================\n');
fprintf('Iniciando Fluxo de Trabalho da Suspensão Passiva\n');
fprintf('====================================================\n');

%% ETAPA 1: CONFIGURAÇÃO DOS PARÂMETROS
fprintf('--> Etapa 1: Carregando parâmetros...\n');
run('setup_parameters.m');
fprintf('Parâmetros carregados com sucesso.\n\n');

%% ETAPA 2: EXECUÇÃO DA SIMULAÇÃO
fprintf('--> Etapa 2: Executando a simulação do Simulink...\n');
model_name = 'passive_suspension';
current_script_path = fileparts(mfilename('fullpath'));
project_root_path = fileparts(current_script_path);
model_full_path = fullfile(project_root_path, '01_Modelos_Simulink', model_name);
sim_output = sim(model_full_path, 'StopTime', num2str(T_sim));
fprintf('Extraindo dados da simulação...\n');
tout = sim_output.tout; out_zs_ddot = sim_output.out_zs_ddot; out_F_tire = sim_output.out_F_tire;
out_zs = sim_output.out_zs; out_zr = sim_output.out_zr;
if ismember('out_zus', sim_output.who), out_zus = sim_output.out_zus; end
fprintf('Simulação e extração concluídas com sucesso.\n\n');

%% ETAPA 2.5: CÁLCULO DE MÉTRICAS DE DESEMPENHO (KPIs)
fprintf('--> Etapa 2.5: Calculando métricas de desempenho...\n');
idx_start = find(tout >= 2, 1);
accel_rms = rms(out_zs_ddot(idx_start:end));
F_static = (ms + mus) * g; F_min = min(out_F_tire(idx_start:end)); F_max = max(out_F_tire(idx_start:end));
tire_load_variation = (F_max - F_min) / F_static * 100;
fprintf('----------------------------------------------------\n');
fprintf('Métricas de Desempenho da Suspensão Passiva:\n');
fprintf('  - Conforto (Aceleração RMS): %.4f m/s^2\n', accel_rms);
fprintf('  - Dirigibilidade (Força Mínima no Pneu): %.2f N\n', F_min);
fprintf('  - Variação Dinâmica da Carga no Pneu: %.2f %%\n', tire_load_variation);
fprintf('----------------------------------------------------\n\n');

%% ETAPA 3: DASHBOARD DINÂMICO INTEGRADO
fprintf('--> Etapa 3: Gerando dashboard dinâmico...\n');
enable_animation = true;
if ~enable_animation, fprintf('Animação desabilitada.\n'); return; end

time = tout; zs = out_zs; zr = out_zr;
if exist('out_zus', 'var'), zus = out_zus; else, zus = zr + (-(ms+mus)*g / kt); end

fig_dashboard = figure('Name', 'Dashboard Dinâmico da Suspensão Passiva', 'NumberTitle', 'off', 'Position', [50, 50, 1200, 700]);
ax_anim = subplot(2, 2, [1, 3]); title(ax_anim, 'Animação do Modelo 1/4 de Veículo', 'Color', 'w');
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

% >>>>> INÍCIO DA MUDANÇA: Técnica do Marcador de Tempo <<<<<
hold(ax_accel, 'on'); grid(ax_accel, 'on');
plot(ax_accel, time, out_zs_ddot, 'b-', 'LineWidth', 1.5); % Desenha a linha completa
y_lim_accel = get(ax_accel, 'YLim');
h_marker_accel = plot(ax_accel, [time(1) time(1)], y_lim_accel, 'Color', [1 1 0.2], 'LineWidth', 1); % Marcador vertical
xlabel(ax_accel, 'Tempo (s)'); ylabel(ax_accel, 'Aceleração (m/s^2)');

hold(ax_force, 'on'); grid(ax_force, 'on');
plot(ax_force, time, out_F_tire, 'r-', 'LineWidth', 1.5); % Desenha a linha completa
y_lim_force = get(ax_force, 'YLim');
h_marker_force = plot(ax_force, [time(1) time(1)], y_lim_force, 'Color', [1 1 0.2], 'LineWidth', 1); % Marcador vertical
xlabel(ax_force, 'Tempo (s)'); ylabel(ax_force, 'Força (N)');
% >>>>> FIM DA MUDANÇA <<<<<

desired_total_duration = 20;
frame_step = round((1/60) / (time(2)-time(1))); if frame_step == 0, frame_step = 1; end
num_frames_to_display = floor(length(time) / frame_step);
time_per_frame = desired_total_duration / num_frames_to_display;

fprintf('Iniciando loop da animação (duração alvo: %.1f s)...\n', desired_total_duration);
for k = 1:frame_step:length(time)
    frame_start_time = tic;
    if ~isvalid(fig_dashboard), fprintf('Janela fechada.\n'); break; end
    
    current_time = time(k); current_zs = zs(k); current_zus = zus(k); current_zr = zr(k);
    
    new_chassis_y = [current_zs + h_mus/2, current_zs + h_mus/2, current_zs + h_mus/2 + h_ms, current_zs + h_mus/2 + h_ms];
    set(h_chassis, 'YData', new_chassis_y);
    new_wheel_y = [current_zus - h_mus/2, current_zus - h_mus/2, current_zus - h_mus/2 + h_mus, current_zus - h_mus/2 + h_mus];
    set(h_wheel, 'YData', new_wheel_y);
    set(h_spring, 'YData', [current_zus, current_zs]); set(h_road, 'YData', [current_zr, current_zr]); set(h_time_text, 'String', sprintf('Tempo: %.2f s', current_time));
    
    % >>>>> INÍCIO DA MUDANÇA: Atualizando os marcadores <<<<<
    set(h_marker_accel, 'XData', [current_time, current_time]);
    set(h_marker_force, 'XData', [current_time, current_time]);
    % >>>>> FIM DA MUDANÇA <<<<<
    
    drawnow;
    
    elapsed_time = toc(frame_start_time);
    pause_duration = time_per_frame - elapsed_time;
    if pause_duration > 0, pause(pause_duration); end
end
fprintf('Animação concluída.\n');
fprintf('====================================================\n');
fprintf('Fim do Fluxo de Trabalho.\n');
fprintf('====================================================\n');