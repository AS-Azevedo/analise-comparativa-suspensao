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

clc;
clear;
close all;

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

% Força peso total sobre o pneu
F_static = (ms + mus) * g;

% Deflexão estática do pneu
tire_deflection_static = F_static / kt;

% Posição inicial da massa não-suspensa (relativa à pista zr=0)
zus_static = tire_deflection_static; % Neste caso, será um valor positivo

% Deflexão estática da mola da suspensão
susp_deflection_static = (ms * g) / ks;

% Posição inicial da massa suspensa
zs_static = zus_static + susp_deflection_static;

% Vetores de condição inicial para os integradores do Simulink
% [Posição, Velocidade]
x0_s = [zs_static, 0];   % Condição inicial para a massa suspensa
x0_us = [zus_static, 0]; % Condição inicial para a massa não-suspensa

disp('Condições iniciais calculadas:');
fprintf('  Posição Estática de ms (zs_static): %.4f m\n', zs_static);
fprintf('  Posição Estática de mus (zus_static): %.4f m\n', zus_static);

%% Parâmetros da Simulação

% Tempo total de simulação
T_sim = 10; % [s]

% Perfil da Pista (Lombada) - Parâmetros para o Signal Editor
road_height = 0.10; % Altura da lombada [m]
road_start_time = 2; % Início da lombada [s]
road_duration = 1; % Duração da subida/descida da lombada [s]