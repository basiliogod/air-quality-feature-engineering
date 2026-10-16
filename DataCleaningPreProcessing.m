%% Data Cleaning and Preprocessing

fprintf('\n--- A Iniciar Limpeza e Pré-processamento ---\n');

%% 1. Tratamento do Alvo CO(GT) e Descarte de NMHC_GT_
% Guardar cópia do estado antes das transformações para comparação
data_before = data;

% Descartar a feature NMHC_GT_ (>90% de valores em falta)
data.NMHC_GT_ = [];

% Remover amostras onde o alvo é NaN
idxValidTarget = ~isnan(data.(targetName));
data = data(idxValidTarget, :);

fprintf('Amostras restantes após remoção de NaNs no alvo: %d\n', height(data));

%% 2. Imputação dos Atributos de Entrada (Features)
% Lista das variáveis de entrada numéricas restantes
featureNames = data.Properties.VariableNames(3:end);
featureNames = featureNames(~strcmp(featureNames, targetName));

data(:, featureNames) = fillmissing(data(:, featureNames), 'linear');

data(:, featureNames) = fillmissing(data(:, featureNames), 'nearest');

%% 3. Deteção e Tratamento de Outliers
% Aplicar clipping entre o percentil 1% e 99% para mitigar picos anómalos
data_clipped = data;

for i = 1:length(featureNames)
    f = featureNames{i};
    pLow = prctile(data_clipped.(f), 1);
    pHigh = prctile(data_clipped.(f), 99);
    
    data_clipped.(f) = max(min(data_clipped.(f), pHigh), pLow);
end

%% 4. Normalização (Min-Max [0, 1])
data_normalized = data_clipped;

% Guardar mínimos e máximos
normParams = struct();

for i = 1:length(featureNames)
    f = featureNames{i};
    fMin = min(data_clipped.(f));
    fMax = max(data_clipped.(f));
    normParams.(f).min = fMin;
    normParams.(f).max = fMax;
    
    data_normalized.(f) = (data_clipped.(f) - fMin) / (fMax - fMin);
end

%% 5. Geração de Gráficos Antes vs Depois
% Efeito do Pré-processamento no sensor PT08.S1
figure('Color', 'w');
subplot(2, 1, 1);
plot(data_before.PT08_S1_CO_, 'Color', [0.8 0.2 0.2]);
title('PT08.S1(CO) Original');
grid on;

subplot(2, 1, 2);
plot(data_clipped.PT08_S1_CO_, 'Color', [0.1 0.6 0.2]);
title('PT08.S1(CO) Limpo');
ylabel('Resposta do Sensor');
xlabel('Índice da Amostra');
grid on;
saveas(gcf, 'images/antes_depois_limpeza.png');

% Boxplots Antes vs Depois da Normalização nas Features
figure('Color', 'w');
subplot(1, 2, 1);
boxplot(data_clipped{:, featureNames(1:4)}, 'Labels', strrep(featureNames(1:4), '_', ' '));
title('Antes da Normalização');
ylabel('Magnitude Original');
xtickangle(30);
grid on;

subplot(1, 2, 2);
boxplot(data_normalized{:, featureNames(1:4)}, 'Labels', strrep(featureNames(1:4), '_', ' '));
title('Depois da Normalização [0, 1]');
ylabel('Escala Normalizada');
xtickangle(30);
grid on;
saveas(gcf, 'images/antes_depois_normalizacao.png');

%% 6. Resumo Numérico Antes vs Depois
fprintf('\n--- Resumo Estatístico de PT08_S1_CO_ Antes vs Depois ---\n');
fprintf('Antes  -> Média: %.2f | Std: %.2f | Min: %.2f | Max: %.2f\n', mean(data_before.PT08_S1_CO_, 'omitnan'), std(data_before.PT08_S1_CO_, 'omitnan'), min(data_before.PT08_S1_CO_, [], 'omitnan'), max(data_before.PT08_S1_CO_, [], 'omitnan'));
fprintf('Depois -> Média: %.2f | Std: %.2f | Min: %.2f | Max: %.2f\n', mean(data_clipped.PT08_S1_CO_), std(data_clipped.PT08_S1_CO_), min(data_clipped.PT08_S1_CO_), max(data_clipped.PT08_S1_CO_));

% Manter data_clean no workspace para as fases seguintes
data_clean = data_normalized;