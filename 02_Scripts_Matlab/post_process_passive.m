%% SCRIPT DE PÓS-PROCESSAMENTO E ANIMAÇÃO - SUSPENSÃO PASSIVA (VERSÃO FINAL)
% -------------------------------------------------------------------------
% Descrição:
%   Este script visualiza os resultados da simulação da suspensão passiva.
%   - Gera um conjunto de gráficos estáticos para análise de desempenho.
%   - Cria uma animação robusta do modelo de 1/4 de veículo.
%   - Otimizado para tema escuro e com controle de velocidade da animação.
%
% Autor: [Seu Nome]
% Data:  25/06/2025
%
% Pré-requisito:
%   A simulação 'passive_suspension.slx' deve ter sido executada, e as
%   variáveis de saída (tout, out_zs, out_F_tire, etc.) devem estar no
%   workspace do MATLAB.
% -------------------------------------------------------------------------

clc;
close all;

fprintf('====================================================\n');
fprintf('Iniciando Pós-Processamento da Suspensão Passiva\n');
fprintf('====================================================\n');

% --- Verificação de Pré-requisitos ---
if ~exist('tout', 'var') || ~exist('out_zs_ddot', 'var')
    error('Variáveis de simulação não encontradas. Por favor, execute a simulação do Simulink primeiro.');
end

%% PARTE 1: Gráficos Estáticos Profissionais (Otimizado para Tema Escuro)

figure('Name', 'Resultados da Suspensão Passiva', 'NumberTitle', 'off', 'Position', [100, 100, 900, 700]);

% 1. Aceleração do Chassi (Conforto)
subplot(2, 2, 1);
plot(tout, out_zs_ddot, 'b-', 'LineWidth', 1.5);
title('Conforto: Aceleração do Chassi (m_s)');
xlabel('Tempo (s)');
ylabel('Aceleração (m/s^2)');
grid on;
legend('a_{ms}');

% 2. Força no Pneu (Dirigibilidade)
subplot(2, 2, 2);
plot(tout, out_F_tire, 'r-', 'LineWidth', 1.5);
title('Dirigibilidade: Força de Contato do Pneu');
xlabel('Tempo (s)');
ylabel('Força (N)');
grid on;
legend('F_{pneu}');

% 3. Deslocamento das Massas
subplot(2, 2, 3);
plot(tout, out_zs, 'b-', 'LineWidth', 1.5);
hold on;
plot(tout, out_zr, 'c--', 'LineWidth', 1); % Cor de alto contraste
hold off;
title('Deslocamento Vertical das Massas');
xlabel('Tempo (s)');
ylabel('Posição (m)');
grid on;
legend('Chassi (z_s)', 'Pista (z_r)');

% 4. Posição da Pista (Referência)
subplot(2, 2, 4);
plot(tout, out_zr, 'c-', 'LineWidth', 1.5); % Cor de alto contraste
title('Entrada: Perfil da Pista');
xlabel('Tempo (s)');
ylabel('Posição (m)');
grid on;
legend('Pista (z_r)');

sgtitle('Análise de Desempenho da Suspensão Passiva', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('Gráficos estáticos gerados com sucesso.\n');

%% PARTE 2: Animação do Modelo de 1/4 de Veículo (Versão Final Robusta)

% --- Controles da Animação ---
enable_animation = true; % Mude para 'false' para pular a animação
animation_delay = 0.01;  % Atraso entre quadros (aumente para mais lento)

if ~enable_animation
    fprintf('Animação desabilitada. Fim do script.\n');
    return;
end

fprintf('Preparando a animação...\n');

% Extrair vetores de dados
time = tout;
zs = out_zs;
zr = out_zr;
if exist('out_zus', 'var'), zus = out_zus; else, zus = zr + (-(ms+mus)*g / kt); end

target_frame_rate = 250; 
simulation_time_step = time(2) - time(1);
frame_step = round((1/target_frame_rate) / simulation_time_step);
if frame_step == 0; frame_step = 1; end

% Configuração da figura da animação
fig_anim = figure('Name', 'Animação da Suspensão', 'NumberTitle', 'off', 'Position', [200, 200, 600, 700]);
ax_anim = axes('Parent', fig_anim, 'XLim', [-2, 2], 'YLim', [-0.5, 0.5]);
hold(ax_anim, 'on'); % Comando CRÍTICO para não apagar os objetos
ax_anim.Color = [0.1 0.1 0.12];
ax_anim.XColor = [0.9 0.9 0.9];
ax_anim.YColor = [0.9 0.9 0.9];
grid on;
title(ax_anim, 'Animação do Modelo 1/4 de Veículo', 'Color', 'w');
xlabel(ax_anim, 'Largura (m)');
ylabel(ax_anim, 'Deslocamento Vertical (m)');

w_ms = 1.5; h_ms = 0.2;
w_mus = 0.5; h_mus = 0.1;

% Desenha o estado inicial com patch() para robustez
chassis_y_base = zs(1) + h_mus / 2;
chassis_verts_x = [-w_ms/2, w_ms/2, w_ms/2, -w_ms/2];
chassis_verts_y = [chassis_y_base, chassis_y_base, chassis_y_base + h_ms, chassis_y_base + h_ms];
h_chassis = patch(ax_anim, chassis_verts_x, chassis_verts_y, [0.2, 0.6, 1], 'EdgeColor', 'w', 'LineWidth', 1.5);

wheel_y_base = zus(1) - h_mus / 2;
wheel_verts_x = [-w_mus/2, w_mus/2, w_mus/2, -w_mus/2];
wheel_verts_y = [wheel_y_base, wheel_y_base, wheel_y_base + h_mus, wheel_y_base + h_mus];
h_wheel = patch(ax_anim, wheel_verts_x, wheel_verts_y, [0.5, 0.5, 0.5], 'EdgeColor', 'w', 'LineWidth', 1.5);

h_spring = plot(ax_anim, [0, 0], [zus(1), zs(1)], 'y-', 'LineWidth', 4);
h_road = plot(ax_anim, ax_anim.XLim, [zr(1), zr(1)], 'w-', 'LineWidth', 2);
h_time_text = text(ax_anim, ax_anim.XLim(1)*0.9, ax_anim.YLim(2)*0.9, sprintf('Tempo: %.2f s', time(1)), 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');

fprintf('Objetos criados com patch(). Iniciando loop da animação...\n');

% Loop da Animação
for k = 1:frame_step:length(time)
    if ~isvalid(fig_anim), fprintf('Janela da animação fechada.\n'); break; end
    
    % Posições atuais
    current_zs = zs(k);
    current_zus = zus(k);
    current_zr = zr(k);
    
    % Atualiza as coordenadas Y dos patches
    new_chassis_y = [current_zs + h_mus/2, current_zs + h_mus/2, current_zs + h_mus/2 + h_ms, current_zs + h_mus/2 + h_ms];
    set(h_chassis, 'YData', new_chassis_y);
    
    new_wheel_y = [current_zus - h_mus/2, current_zus - h_mus/2, current_zus - h_mus/2 + h_mus, current_zus - h_mus/2 + h_mus];
    set(h_wheel, 'YData', new_wheel_y);
    
    % Atualiza outros objetos
    set(h_spring, 'YData', [current_zus, current_zs]);
    set(h_road, 'YData', [current_zr, current_zr]);
    set(h_time_text, 'String', sprintf('Tempo: %.2f s', time(k)));
    
    drawnow;
    pause(animation_delay); % Controle de velocidade
end

fprintf('Animação concluída.\n');
fprintf('====================================================\n');