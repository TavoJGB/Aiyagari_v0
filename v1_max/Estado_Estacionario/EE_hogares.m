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
        a_pol c_pol vv ...                          % decisiones óptimas y valor
        Q mu                                        % transiciones y distribución

% Variables a nivel de hogar
hh_z    = malla_z(matSt(:,pos.z));  % productividad
hh_a    = malla_a(matSt(:,pos.a));  % activos
hh_dem  = w*hh_z + (1+r)*hh_a;      % dinero en mano

% Variables para solución numérica
c_min   = 1e-2;     % consumo mínimo permitido
castigo = -1e6;     % castigo de utilidad para consumo inferior al mínimo

% Funciones
    % utilidad
    util    = @(c) (c.^(1-eco.crra)-1) / (1-eco.crra);
    % consumo implicado por restricción presupuestaria y decisión de ahorro
    c_imp   = @(dem, a_sig) dem - a_sig;


%% ITERACIÓN DE VALOR

% Semilla para la función de valor
if isempty(vv) % Si estamos en la primera iteración, crear semilla
   vv = util(w*hh_z + r*hh_a)/(1-eco.beta);
end % posteriormente, utilizar vv obtenido en iteración previa

% Criterios de convergencia
tst_IV = 1;
tol_IV = 1e-4;

% Solución para la función de valor
while tst_IV > tol_IV
    % vv esperado en el próximo periodo
    vv_esp = pi_z(matSt(:,pos.z),:) * reshape(vv, n.a, n.z)';
        % la fila indica tus estados actuales
        % la columna hace que vv_esp sea función de tu decisión de ahorros
    % Optimización:
        % Restricción presupuestaria
        c_aux = c_imp(hh_dem,malla_a'); % consumo implicado por decisión de ahorros
        % Cada fila es una ecuación de Bellman (función de a' únicamente)
        v_aux = util(max(c_aux,c_min)) + eco.beta*vv_esp;
        % No podemos permitir valores de consumo negativos o cercanos a 0
        ind_c_neg = (c_aux<c_min);
        v_aux(ind_c_neg) = castigo;
        % Problema de maximizacióm
        [vv_imp, ia_pol] = max(v_aux,[],2);
    % Convergencia
        tst_IV = max(abs(vv_imp-vv)); % distancia
        vv = vv_imp;                  % actualizar semilla
end

% Decisiones óptimas
a_pol = malla_a(ia_pol);
c_pol = c_imp(hh_dem,a_pol);

% Mostrar situación
disp('Problema de los hogares resuelto.')


%% MATRIZ Q DE TRANSICIONES

% Preparativos
    a_mat = sparse(ia_pol,1:n.N,1,n.a,n.N); % Indicador: =1 en la posición de ahorro óptima
        % la fila indica ahorros en el siguiente periodo
        % la columna indica estados actuales
    Q = []; % Inicializar la matriz de transiciones

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