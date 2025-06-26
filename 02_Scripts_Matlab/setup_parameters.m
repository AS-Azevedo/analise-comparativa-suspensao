%% SETUP_PARAMETERS - Script de Configuração para Simulação de Suspensão
% -------------------------------------------------------------------------
% Descrição:
%   Este script define todos os parâmetros necessários para a simulação
%   do modelo de 1/4 de veículo (passivo, semi-ativo e ativo).
%   Ele também calcula as condições iniciais de equilíbrio estático.
%
% Autor: Anderson Azevedo
% Data:  24/06/2025
% -------------------------------------------------------------------------

%% Parâmetros Físicos do Modelo de 1/4 de Veículo
% Estes valores representam um veículo de passageiros típico.

% Massa Suspensa (Sprung Mass) - representa 1/4 do chassi do carro
ms = 290; % [kg] 

% Massa Não-Suspensa (Unsprung Mass) - representa o conjunto roda/pneu
mus = 59; % [kg]

% Rigidez da Mola da Suspensão (Suspension Stiffness)
ks = 16000; % [N/m]

% Coeficiente de Amortecimento da Suspensão (Suspension Damping)
% Este valor será usado como base para o sistema passivo e Skyhook
cs = 1000; % [N-s/m]

% Rigidez do Pneu (Tire Stiffness) - modelado como uma mola linear
kt = 190000; % [N/m]

% Constante Gravitacional
g = 9.81; % [m/s^2]

%% [REQUISITO CRÍTICO 1] - Cálculo das Condições Iniciais de Equilíbrio Estático
% -------------------------------------------------------------------------
% Por que calcular isso?
%   Para iniciar a simulação em um estado de repouso físico, sem transientes
%   indesejados devido ao assentamento da suspensão sob a ação da gravidade.
%   As forças das molas devem equilibrar os pesos das massas. Isso garante
%   que as posições iniciais (zs e zus) e as velocidades (zero) sejam

%   fisicamente consistentes.
%
% Derivação:
%   No equilíbrio estático (velocidades e acelerações nulas), o somatório
%   de forças em cada massa é zero. Consideramos a posição da pista zr = 0.
%
%   Para a massa suspensa (ms):
%   Força da mola ks - Peso de ms = 0
%   ks * (zus_static - zs_static) - ms * g = 0  => (Eq. 1)
%
%   Para a massa não-suspensa (mus):
%   Força do pneu kt - Força da mola ks - Peso de mus = 0
%   kt * (zr - zus_static) - ks * (zus_static - zs_static) - mus * g = 0
%   Com zr = 0:
%   -kt * zus_static - ks * (zus_static - zs_static) - mus * g = 0 => (Eq. 2)
%
%   Substituindo (ms*g) de (Eq. 1) em (Eq. 2):
%   -kt * zus_static - (ms * g) - mus * g = 0
%   -kt * zus_static = (ms + mus) * g
%   zus_static = -(ms + mus) * g / kt
%
%   Agora, isolando zs_static de (Eq. 1):
%   zs_static = zus_static - (ms * g / ks)
% -------------------------------------------------------------------------

% Força peso total sobre o pneu no equilíbrio
F_static = (ms + mus) * g;

% Posição estática da massa não-suspensa (deve ser negativa)
zus_static = -F_static / kt;

% Posição estática da massa suspensa (zs > zus)
zs_static = zus_static - (ms * g) / ks;

% Vetores de condição inicial para os integradores do Simulink
x0_s = [zs_static, 0];   % [Posição, Velocidade] para ms
x0_us = [zus_static, 0]; % [Posição, Velocidade] para mus

disp('Condições iniciais CORRIGIDAS calculadas:');
fprintf('  Posição Estática de ms (zs_static): %.4f m\n', zs_static);
fprintf('  Posição Estática de mus (zus_static): %.4f m\n', zus_static);

%% Parâmetros do Controle Semi-Ativo (Skyhook)
cs_on = 2500;  % Amortecimento ALTO [N-s/m] (Pode ser o mesmo do passivo ou maior)
cs_off = 150;   % Amortecimento BAIXO [N-s/m] (Um valor pequeno, mas não zero, para representar o atrito residual)

%% Parâmetros da Simulação

% Tempo total de simulação
T_sim = 25; % [s]

% Perfil da Pista (Lombada) - Parâmetros para o Signal Editor
road_height = 0.10; % Altura da lombada [m]
road_start_time = 2; % Início da lombada [s]
road_duration = 1; % Duração da subida/descida da lombada [s]

%% Definição do Perfil da Pista (Lombada) para o Bloco 'From Workspace'
% -------------------------------------------------------------------------
% Este método é mais robusto que o Signal Editor.
% Criamos os pontos-chave da lombada e usamos interpolação linear para
% gerar o vetor de sinal completo.
% -------------------------------------------------------------------------

disp('Gerando sinal de pista para o bloco From Workspace...');

% Cria um vetor de tempo para a simulação com um passo pequeno
dt = 0.001; % Passo de tempo para a geração do sinal
time_vec = (0:dt:T_sim)'; % Vetor de tempo (coluna)

% Define os pontos-chave da lombada (tempo, altura)
road_key_points_time = [0, 2, 3, 4,  15, 16, 17, T_sim]; % Primeira lombada em t=2s, Segunda em t=15s
road_key_points_value = [0, 0, road_height, 0,  0, road_height, 0, 0];

% Gera o vetor da pista usando interpolação linear (cria o "triângulo")
road_vec = interp1(road_key_points_time, road_key_points_value, time_vec, 'linear');

% O bloco 'From Workspace' precisa de uma matriz com o tempo na primeira
% coluna e o sinal na segunda.
road_signal = [time_vec, road_vec];

fprintf('Sinal de pista "road_signal" criado com %d pontos.\n', length(time_vec));

%% Parâmetros do Controle Ativo (PID)
Kp = 80000; % Ganho Proporcional - "Força" da reação ao erro de posição
Ki = 25000; % Ganho Integral - Corrige erros de regime permanente
Kd = 12000; % Ganho Derivativo - "Amortece" a resposta, evita overshoot