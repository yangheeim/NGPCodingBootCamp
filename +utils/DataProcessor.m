classdef DataProcessor
    properties
        ctData      % Cortical Thickness Data
        demogData   % Demographic Data
        mergedData  % Merged Data
    end
    
    methods
        function obj = DataProcessor(ctFile, demogFile)
            % Constructor to load the data
            obj.ctData = readtable(ctFile);
            obj.demogData = readtable(demogFile);
        end
        
        function obj = wrangleData(obj)
            % Merge tables based on 'src_subject_id' and 'eventname'
            obj.mergedData = join(obj.ctData, obj.demogData, 'Keys', {'src_subject_id', 'eventname'});

            % Rename columns
            obj.mergedData.Properties.VariableNames{'src_subject_id'} = 'subjID';
            obj.mergedData.Properties.VariableNames{'interview_age'} = 'age';
            obj.mergedData.Properties.VariableNames{'site_id_l'} = 'site';
            obj.mergedData.Properties.VariableNames{'demo_sex_v2'} = 'sex';

            % Convert age from months to years
            obj.mergedData.age = obj.mergedData.age / 12;

            % Convert sex codes to characters
            obj.mergedData.sex = categorical(obj.mergedData.sex);

            % Check unique values in merged_df.sex
            unique_sex_values = unique(obj.mergedData.sex);

            % Rename the categories based on the unique values
            if all(ismember(unique_sex_values, {'1', '2'}))
                obj.mergedData.sex = renamecats(obj.mergedData.sex, {'1', '2'}, {'M', 'F'});
            elseif all(ismember(unique_sex_values, {'1', '2', '3'}))
                obj.mergedData.sex = renamecats(obj.mergedData.sex, {'1', '2', '3'}, {'M', 'F', 'I'});
            else
                warning('merged_df.sex contains values other than 1, 2, 3.');
            end

            % Display a summary of the data
            summary(obj.mergedData);
        end
        
        function model = performRegression(obj, variable)
            % Select relevant columns and remove rows with missing data
            select_df = rmmissing(obj.mergedData(:, {'subjID', 'eventname', 'age', 'sex', 'site', variable}));

            % Fit the linear regression model
            lm_formula = sprintf('%s ~ age + sex + site', variable);
            model = fitlm(select_df, lm_formula);

            % Display the model summary
            disp(model);
        end
        
        function plotRegression(obj, model, variable)
            % Plotting with scatter and regression line
            select_df = rmmissing(obj.mergedData(:, {'age', variable, 'sex', 'site'}));
            figure;
            gscatter(select_df.age, select_df.(variable), select_df.sex, 'rb', 'xo');
            hold on;
            x = linspace(min(select_df.age), max(select_df.age), 100);
            yfit = predict(model, table(x', select_df.sex(1:100), select_df.site(1:100), 'VariableNames', {'age', 'sex', 'site'}));
            plot(x, yfit, '-k');
            xlabel('Age (years)');
            ylabel(variable);
            legend('M', 'F');
            title(variable);
            grid on;
            hold off;
        end
        
        function loopRegression(obj, variables)
            % Loop through multiple variables, perform regression, and plot
            for i = 1:length(variables)
                variable = variables{i};
                
                % Perform regression
                model = obj.performRegression(variable);
                
                % Plot the results
                obj.plotRegression(model, variable);
                
                % Uncomment the following lines if you want to save the plot
                % filename = fullfile('/Users/username/Desktop/', [variable, '.png']);
                % saveas(gcf, filename);
            end
        end
    end
end
