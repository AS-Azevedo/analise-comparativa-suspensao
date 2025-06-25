%% SCRIPT DE DEPURAÇÃO DA ANIMAÇÃO
% -------------------------------------------------------------------------
% Descrição:
%   Este script isola o código da animação para diagnosticar o erro
%   'Invalid or deleted object'. Ele contém mais verificações para
%   determinar qual objeto gráfico está se tornando inválido e quando.
% -------------------------------------------------------------------------

fprintf('--- INICIANDO SCRIPT DE DEPURAÇÃO DA ANIMAÇÃO ---\n');

% --- Verificação de Pré-requisitos ---
if ~exist('tout', 'var') || ~exist('out_zs', 'var')
    error('As variáveis de simulação (tout, out_zs, etc.) não foram encontradas. Por favor, execute a simulação do Simulink primeiro.');
end
fprintf('Variáveis da simulação encontradas. Preparando a animação...\n');

% --- Código da Animação (Isolado) ---

% Extrair vetores de dados
time = tout;
zs = out_zs;
zr = out_zr;
if exist('out_zus', 'var'), zus = out_zus; else, zus = zr + (-(ms+mus)*g / kt); end

% Parâmetros da animação
target_frame_rate = 250; 
simulation_time_step = time(2) - time(1);
frame_step = round((1/target_frame_rate) / simulation_time_step);
if frame_step == 0; frame_step = 1; end

% Configuração da figura da animação
fig_anim = figure('Name', '[DEBUG] Animação da Suspensão', 'NumberTitle', 'off', 'Position', [200, 200, 600, 700]);
ax_anim = axes('Parent', fig_anim, 'XLim', [-2, 2], 'YLim', [-0.5, 0.5]);
ax_anim.Color = [0.1 0.1 0.12];
ax_anim.XColor = [0.9 0.9 0.9];
ax_anim.YColor = [0.9 0.9 0.9];
grid on;
title(ax_anim, 'Animação do Modelo 1/4 de Veículo', 'Color', 'w');
xlabel(ax_anim, 'Largura (m)');
ylabel(ax_anim, 'Deslocamento Vertical (m)');

% Dimensões dos elementos
w_ms = 1.5; h_ms = 0.2;
w_mus = 0.5; h_mus = 0.1;

% Desenha o estado inicial e armazena os "handles"
fprintf('Desenhando estado inicial dos objetos gráficos...\n');
chassis_y = zs(1) + h_mus / 2;
h_chassis = rectangle(ax_anim, 'Position', [-w_ms/2, chassis_y, w_ms, h_ms], 'FaceColor', [0.2, 0.6, 1], 'EdgeColor', 'w', 'LineWidth', 1.5);

wheel_y = zus(1) - h_mus / 2;
h_wheel = rectangle(ax_anim, 'Position', [-w_mus/2, wheel_y, w_mus, h_mus], 'FaceColor', [0.5, 0.5, 0.5], 'EdgeColor', 'w', 'LineWidth', 1.5);

h_spring = plot(ax_anim, [0, 0], [zus(1), zs(1)], 'y-', 'LineWidth', 4);
h_road = plot(ax_anim, ax_anim.XLim, [zr(1), zr(1)], 'w-', 'LineWidth', 2);
h_time_text = text(ax_anim, ax_anim.XLim(1)*0.9, ax_anim.YLim(2)*0.9, sprintf('Tempo: %.2f s', time(1)), 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
fprintf('Objetos criados. Iniciando loop da animação...\n');

% Loop da Animação com Diagnóstico Extra
for k = 1:frame_step:length(time)
    
    % --- Verificações de Diagnóstico Detalhado ---
    if ~isvalid(fig_anim)
        fprintf('ERRO no passo k=%d: A FIGURA PRINCIPAL (fig_anim) se tornou inválida ANTES da atualização.\n', k);
        break;
    end
    if ~isvalid(h_chassis)
        fprintf('ERRO no passo k=%d: O RETÂNGULO DO CHASSI (h_chassis) se tornou inválido ANTES da atualização.\n', k);
        break;
    end
    
    % Se tudo está bem, imprime uma mensagem de status
    % fprintf('Passo k=%d: Objetos válidos. Atualizando...\n', k); % Descomente para MUITO texto
    
    % Atualiza a posição dos objetos gráficos
    set(h_chassis, 'Position', [-w_ms/2, zs(k) + h_mus/2, w_ms, h_ms]);
    set(h_wheel, 'Position', [-w_ms/2, zus(k) - h_mus/2, w_mus, h_mus]);
    set(h_spring, 'YData', [zus(k), zus(k)]);
    set(h_road, 'YData', [zr(k), zr(k)]);
    set(h_time_text, 'String', sprintf('Tempo: %.2f s', time(k)));
    
    % Força o MATLAB a desenhar o quadro atual
    drawnow;
end

fprintf('--- FIM DO SCRIPT DE DEPURAÇÃO ---\n');