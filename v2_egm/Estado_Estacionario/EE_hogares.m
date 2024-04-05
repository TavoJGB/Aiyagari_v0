function K_agg = EE_hogares(r, w)
% ----------------------------------------------------------------------- %
%
% Esta función toma unos precios (r,w) como dados y devuelve:
% - variables globales: decisiones óptimas, transiciones y distribución.
% - variable devuelta: oferta agregada de capital.
%
% ----------------------------------------------------------------------- %


%% PREÁMBULO

% Cargar variables globales
global  eco n malla_a malla_z pi_z matSt pos ...    % parámetros y estados
        a_pol c_pol indL indU wgt ...               % decisiones óptimas y valor
        Q mu                                        % transiciones y distribución

% Variables a nivel de hogar
hh_z    = malla_z;              % productividad
hh_a    = malla_a';             % activos
hh_dem  = w*hh_z + (1+r)*hh_a;  % dinero en mano

% Funciones
    % consumo implicado por restricción presupuestaria y decisión de ahorro
    c_RP    = @(dem, a_sig) dem - a_sig;


%% MÉTODO DE MALLA ENDÓGENA

% Conjeturas iniciales
    % Política de ahorro (malla)
    a_sig_0 = hh_a;
    % Política de consumo (RP con a' = a)
    c_sig_0 = w*malla_z + r*a_sig_0;

% Criterios de convergencia
tst_MME = 1;
tol_MME = 1e-4;

% Bucle
while tst_MME > tol_MME
    % Consumo implicado (Ecuación de Euler)
    c_imp = (eco.beta*(1+r)).^(1/-eco.crra) * pi_z*c_sig_0;
        % la fila indica tus productividad actual
        % la columna indica tu decisión de ahorros (activos en el sig per)
    % Riqueza implicada (Restricción Presupuestaria)
    a_imp = ( c_imp + a_sig_0 - w*malla_z )/(1+r);
    % Actualizar política de ahorro (Interpolación)
        for zz=1:n.z
            a_MME(zz,:) = linInterp(hh_a, a_imp(zz,:), a_sig_0, 'capS');
        end
        % Restricción al endeudamiento
        a_MME(a_MME<eco.a_min) = eco.a_min;
        % Máximo ahorro permitido
        a_MME(a_MME>eco.a_max) = eco.a_max;
    % Actualizar política de consumo (Restricción Presupuestaria)
    c_MME = c_RP(hh_dem, a_MME);
    % Convergencia
    tst_MME = max(abs(c_MME-c_sig_0));  % distancia
    c_sig_0 = c_MME;                    % actualizar semilla
end

% Decisiones óptimas (formato vectorial)
a_pol = reshape(a_MME',n.N,1);
c_pol = reshape(c_MME',n.N,1);

% Mostrar situación
disp('Problema de los hogares resuelto.')


%% MATRIZ Q DE TRANSICIONES

% Preparativos
    % Interpolación (a_pol ya no está en la malla)
    [indL, indU, wgt] = getWeights(a_pol, malla_a);
    % Indicador: =1 en la posición de ahorro óptima
    a_mat = sparse(indL,1:n.N,wgt,n.a,n.N) + ...
            sparse(indU,1:n.N,1-wgt,n.a,n.N);
        % la fila indica ahorros en el siguiente periodo
        % la columna indica estados actuales
    % Inicializar la matriz de transiciones
    Q = [];

% Crear matriz Q
    for z_sig=1:n.z % bucle sobre futuro estado de productividad
        auxQ = a_mat .* pi_z(matSt(:,pos.z),z_sig)';
        % Añadir filas nuevas al final de Q
        Q = [Q; auxQ];
    end
    % Sobre la matriz Q:
        % - La columna indica los estados iniciales (z,a).
        % - La fila indica los estados en elsiguiente periodo (z',a').
        % - Cada celda indica la probabilidad de pasar de (z,a) a (z',a').

disp('Matriz de transición obtenida.')


%% DISTRIBUCIÓN        
% Ahora que tenemos Q, podemos obtener la distribución estacionaria

% Preparativos
    tol_mu=1e-8;    % tolerancia
    tst_mu=1;       % inicializar criterio de convergencia
    mu = ones(n.N,1) / n.N; % semilla (distribución uniforme)

% Obtener distribución estacionaria
    while tst_mu>=tol_mu
        mu_imp = Q*mu;
        tst_mu=max(abs(mu_imp-mu));
        mu = mu_imp;
    end

disp('Distribución estacionaria obtenida.')


%% VARIABLES DEVUELTAS

% Oferta agregada de capital
K_agg = sum(a_pol.*mu);