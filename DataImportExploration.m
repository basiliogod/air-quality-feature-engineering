%% 1. Data Import and Exploration
fprintf('\n--- A Iniciar Importação e Exploração ---\n');

filename = 'AirQualityUCI.xlsx';
raw_data = readtable(filename);

% Remover colunas/linhas totalmente vazias
data = raw_data(:, 1:15);

% Obter nomes das variáveis numéricas (excluindo Date e Time)
numVarNames = data.Properties.VariableNames(3:end);

% Substituir -200 por NaN para cálculos corretos
for i = 1:length(numVarNames)
    var = numVarNames{i};
    data.(var)(data.(var) == -200) = NaN;
end

%% 2. Métricas Globais do Dataset
[nObservations, nVariables] = size(data);
totalMissing = sum(sum(isnan(data{:, numVarNames})));

fprintf('Dimensões: %d observações, %d variáveis\n', nObservations, nVariables);
fprintf('Total de valores em falta identificados (-200 -> NaN): %d\n', totalMissing);

%% 3. Tabela-Resumo Estatística
targetName = 'CO_GT_'; 

statsTable = table();

for i = 1:length(numVarNames)
    var = numVarNames{i};
    vData = data.(var);

    nValid = sum(~isnan(vData));
    nNan = sum(isnan(vData));
    pctNan = (nNan / length(vData)) * 100;

    mu = mean(vData, 'omitnan');
    sig = std(vData, 'omitnan');
    med = median(vData, 'omitnan');
    valMin = min(vData, [], 'omitnan');
    valMax = max(vData, [], 'omitnan');
    sk = skewness(vData, 0);

    % Correlação linear de Pearson com a variável-alvo CO(GT)
    corrTarget = corr(data.(var), data.(targetName), 'Rows', 'complete');

    row = table({var}, nValid, nNan, pctNan, valMin, valMax, mu, med, sig, sk, corrTarget,'VariableNames', {'Feature', 'Valid_N', 'Missing_N', 'Missing_Pct','Min', 'Max', 'Mean', 'Median', 'Std', 'Skewness', 'Corr_CO'});
    statsTable = [statsTable; row];
end

disp(statsTable);

%% 4. Distribuição do Alvo: CO(GT)
figure('Color', 'w');
subplot(1, 2, 1);
histogram(data.(targetName), 30, 'FaceColor', [0.2 0.4 0.7], 'EdgeColor', 'k');
xlabel('Concentração de CO(GT) [mg/m^3]');
ylabel('Frequência');
title('Distribuição de CO(GT)');
grid on;

subplot(1, 2, 2);
boxplot(data.(targetName), 'Labels', {'CO(GT)'});
ylabel('Concentração [mg/m^3]');
title('Boxplot de CO(GT) (Deteção de Outliers)');
grid on;
saveas(gcf, 'images/distribuicao_target.png');

%% 5. Gráfico de Correlação das Features com CO(GT)
featuresOnly = statsTable(~strcmp(statsTable.Feature, targetName), :);
cleanLabels = strrep(featuresOnly.Feature, '_', ' ');

figure('Color', 'w');
bar(categorical(cleanLabels), featuresOnly.Corr_CO, 'FaceColor', [0.3 0.6 0.5]);
ylabel('Coeficiente de Correlação de Pearson');
title('Correlação com CO(GT)');
xtickangle(45);
grid on;
saveas(gcf, 'images/correlacao_features_target.png');