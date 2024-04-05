% ----------------------------------------------------------------------- %
%
%	Introducción a la modelización macroeconómica de las desigualdades:
%   EL MODELO DE AIYAGARI
%   v1: - Agentes heterogéneos (choques idiosincráticos de productividad).
%       - Método: maximización simple en malla, sin interpolación.
%
% ----------------------------------------------------------------------- %


%% PREVIA

% Limpiar espacio de trabajo
clear all
close all
clc
tic

% Añadir carpeta de funciones
addpath Funciones
addpath Estado_Estacionario

% Crear variables globales
global  eco n malla_a malla_z pi_z matSt pos ind    % parámetros y estados

% Parámetros
    % Economía
    eco.crra    = 2.0;      % sustitución intertemporal / aversión al riesgo
    eco.beta    = 0.93;     % factor de descuento
    eco.delta   = 0.12;     % depreciación
    eco.alpha   = 0.36;     % participación del capital
    eco.a_min   = 0.00;     % restricción al endeudamiento
    rho_z       = 0.90;     % persistencia del choque idiosincrático
    sigma_z     = 0.20;     % volatilidad del choque idiosincrático
    % Solución numérica
    n.z         = 10;       % número de nodos en la malla de productividad
    n.a         = 500;      % número de nodos en la malla de ahorros
    a_max       = 50;       % máxima riqueza permitida

% Número total de estados
n.N = n.z*n.a;

% Malla de ahorros
malla_a         = linspace(eco.a_min,a_max, n.a)';


%% PRODUCTIVIDAD
% Aproximación del proceso idiosincrático de productividad
% log(z_t) = rho*log(z_t-1)+sigma*epsilon_t
    
% Malla de productividad:                       malla_z
% Probabilidades de transición entre estados:   pi_z
%   pi_z(i, j) contiene la probabilidad de transición de malla_z(i) a malla_z(j)
% Distribución estacionaria de productividad:   mu_z

% Discretizando un AR(1): método de Tauchen
[log_z,pi_z] = tauchen(n.z,0,rho_z,sigma_z,3);
malla_z = exp(log_z);

% Distribución estacionaria de productividad
mu_z = ones(n.z,1)/n.z;
tst_z = 1;
tol_z = 1e-8;
while (tst_z>tol_z)
    mu_z2 = pi_z'*mu_z;
    tst_z = max(abs(mu_z2-mu_z));
    mu_z = mu_z2;
end

% Empleo agregado
% (podemos calcularlo ya, gracias a que la oferta de empleo es inelástica)
L_agg = malla_z'*mu_z;

% Nos deshacemos de variables auxiliares
clear a_max log_z mu_z2 rho_z sigma_z tol_z tst_z


%% MATRIZ DE ESTADOS
% Esta matriz indica el nivel de productividad y activos de cada hogar en
% esta economía

% Posición de cada variable de estado
pos.z = 1;  % productividad en la primera columna
pos.a = 2;  % ahorros en la segunda columna

% Matriz
matSt(:,pos.z) = kron((1:n.z)', ones(n.a,1));
matSt(:,pos.a) = kron(ones(n.z,1), (1:n.a)');

% Índices (para clasificar hogares en grupos relevantes)
ind.z_min = (matSt(:,pos.z)==1);
ind.z_med = (matSt(:,pos.z)==round(n.z/2));
ind.z_max = (matSt(:,pos.z)==n.z);
    % verificación: todos los hogares en z_min tienen productividad baja
    % matSt(ind.z_min,:)


%% ESTADO ESTACIONARIO
% Bucle sobre el tipo de interés (r)

% Preparación
r_0     = 0.03;     % semilla inicial
tst_r   = 1;        % criterio de convergencia
tol_r   = 1e-6;     % tolerancia para la convergencia
peso_r  = 0.8;      % peso de la semilla inicial en la actualización
iter    = 0;        % contador de iteraciones

% Bucle
while (tst_r>tol_r)
    % Número de iteración
    iter = iter+1;
    % Salario implicado (por las condiciones de primer orden de la empresa)
    w_0 = (1-eco.alpha)*((eco.alpha/(r_0+eco.delta))^eco.alpha)^(1/(1-eco.alpha));
    % Problema de los hogares
    %   EE_hogares afecta a las variables globales
    %   - decisiones óptimas de consumo y ahorro.
    %   - matriz Q de transición entre estados.
    %   - distribución mu de estado estacionario.
    %   Además, EE_hogares devuelve la oferta agregada de capital, K1
    K_agg = EE_hogares(r_0,w_0);
    % Tipo de interés implicado (por el problema de la empresa)
    r_1 = eco.alpha*max(0.001,K_agg)^(eco.alpha-1)*L_agg^(1-eco.alpha)-eco.delta;
    % Convergencia
        % Criterio
        tst_r=abs(r_1-r_0);
        % Mostrar situación
        fprintf('#%d | r_0: %.4f, r_1: %.4f | Brecha: %.5f\n\n',iter,r_0,r_1,tst_r)
        % Actualizar semilla
        r_0 = peso_r*r_0 + (1-peso_r)*r_1;
end


%% ESTADÍSTICAS
EE_sumario(r_0, w_0, K_agg, L_agg)


%% FIGURAS
EE_figs

toc