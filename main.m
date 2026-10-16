clear; clc; close all;

%% Fase 1: Importação e Exploração dos Dados
fprintf('\n[Passo 1/5] A executar: DataImportExploration.m\n');
run('DataImportExploration.m');

%% Fase 2: Limpeza e Pré-processamento
fprintf('\n[Passo 2/5] A executar: DataCleaningPreProcessing.m\n');
run('DataCleaningPreProcessing.m');

%% Fase 3: EDA
fprintf('\n[Passo 3/5] A executar: ExploratoryDataAnalysis.m\n');
run('ExploratoryDataAnalysis.m');

%% Fase 4 : Seleção de Atributos
fprintf('\n[Passo 4/5] A executar: FeatureSelection.m\n');
run('FeatureSelection.m');

%% Fase 5 : Engenharia de Atributos
fprintf('\n[Passo 5/5] A executar FeatureEngineering.m\n');
run('FeatureEngineering.m');

fprintf('\nExecução concluída.\n');