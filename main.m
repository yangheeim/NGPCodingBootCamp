clear;
clc;

% Create an instance of the DataProcessor class
processor = utils.DataProcessor('data/ABCD_CT_lab.csv', 'data/ABCD_demog_lab.csv');

% 2) Wrangle Data
processor = processor.wrangleData();

% 3) Linear Regression
variable = 'meanlh';
model = processor.performRegression(variable);

% 4) Plot regression
processor.plotRegression(model, variable);

% 5) Loop through multiple ROIs and plot
variables = {'superiorfrontallh', 'superiorparietallh', 'superiortemporallh', 'insulalh'};
processor.loopRegression(variables);
