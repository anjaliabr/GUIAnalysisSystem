classdef GUIAnalysis < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        INPUT1EditFieldLabel         matlab.ui.control.Label
        INPUT1EditField              matlab.ui.control.EditField
        InterpolationMethodsListBoxLabel  matlab.ui.control.Label
        InterpolationMethodsListBox  matlab.ui.control.ListBox
        RegressionOrderSliderLabel   matlab.ui.control.Label
        RegressionOrderSlider        matlab.ui.control.Slider
        EnableDataSaveCheckBox       matlab.ui.control.CheckBox
        CalculateDataButton          matlab.ui.control.Button
        GUIAnalysisSystemLabel       matlab.ui.control.Label
        INPUT2EditFieldLabel         matlab.ui.control.Label
        INPUT2EditField              matlab.ui.control.EditField
        UIAxes                       matlab.ui.control.UIAxes
    end

    
    methods (Access = private)
        
        % interpolation function
        function yTestInt= interpolation(app,x,y,xTest)
            %% different methods to use for interpolation
            switch app.InterpolationMethodsListBox.Value
                    case 'Linear'
                        yTestInt = interp1(x,y,xTest,'linear');
                    case 'Nearest'
                        yTestInt = interp1(x,y,xTest,'nearest');
                    case 'Pchip'
                        yTestInt = interp1(x,y,xTest,'pchip');
            end
        end
        
        % regression order function
        function [RegCoeffs yTestReg] = regression(app,x,y,n,xTest)
           RegCoeffs = polyfit(x,y,n); %% to determine the coefficients of the best polynomial
           yTestReg = polyval(RegCoeffs,xTest); 
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: CalculateDataButton
        function CalculateDataButtonPushed(app, event)
            %% Variables
            % input 1, input 2 - input vector pair that is converted from
            %                    string to double
            % x - value of input1 and an independent vector
            % y - value of input2 and a dependent vector
            % xTest - vector that consists of the smallest and largest
            %         values of x evenly spaced by 100 points
            % yTestInt - output vector corresponding to the value of xTest
            %            and the types of interpolation method
            % n - value of slider 
            % regCoeffs - vector of regression analysis performed on xTest
            % yTestReg - ouput vector when the regCoeffs is evaluated at
            %            data values of xTest
            
            % Input data vector pair
            input1 = str2double(split(app.INPUT1EditField.Value,{' ',','}));
            input2 = str2double(split(app.INPUT2EditField.Value,{' ',','}));
            
            % Arranging the input vectors in x and y
            x = zeros(1);
            y = zeros(1);
            for i = 1:length(input1)
                x(i) = input1(i);  %independent vector
            end
            for j = 1:length(input2)
                y(j) = input2(j); %dependent vector
            end
            
            xTest = linspace(min(x),max(x),100);
            
            %% Interpolation 
            yTestInt = interpolation(app,x,y,xTest);
            
            % setting the limits of the slider from 0 to N-1, where N is
            % the number of elements in x
            app.RegressionOrderSlider.Limits = [0 length(input1)-1];
            n = round(app.RegressionOrderSlider.Value);
          
            %% Regression
            [regCoeffs yTestReg] = regression(app,x,y,n,xTest);
            
            %% Data Plots
            % plotting the input data pair with red circles 
            % plotting xTest and yTestInt with blue dashes (Interpolation Method)
            % plotting xTest and yTestReg with green dots (Regression Analysis)
            plot(app.UIAxes,x,y,'ro',xTest,yTestInt,'b-',xTest,yTestReg,'g.', 'LineWidth', 1.5);
            legend(app.UIAxes,'Input Data', 'Interpolation', 'Regression','Location','southeast');
            
            % if the enable data save check box is true, then save the
            % variables to the workspace
            if app.EnableDataSaveCheckBox.Value
                assignin('base','x',x);
                assignin('base','y',y);
                assignin('base','xTest',xTest);
                assignin('base','yTestInt',yTestInt);
                assignin('base','regCoeffs',regCoeffs);
                assignin('base','yTestReg',yTestReg);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 730 486];
            app.UIFigure.Name = 'MATLAB App';

            % Create INPUT1EditFieldLabel
            app.INPUT1EditFieldLabel = uilabel(app.UIFigure);
            app.INPUT1EditFieldLabel.HorizontalAlignment = 'center';
            app.INPUT1EditFieldLabel.FontSize = 14;
            app.INPUT1EditFieldLabel.FontWeight = 'bold';
            app.INPUT1EditFieldLabel.Position = [130 411 60 22];
            app.INPUT1EditFieldLabel.Text = 'INPUT 1';

            % Create INPUT1EditField
            app.INPUT1EditField = uieditfield(app.UIFigure, 'text');
            app.INPUT1EditField.Position = [68 380 183 22];

            % Create InterpolationMethodsListBoxLabel
            app.InterpolationMethodsListBoxLabel = uilabel(app.UIFigure);
            app.InterpolationMethodsListBoxLabel.HorizontalAlignment = 'center';
            app.InterpolationMethodsListBoxLabel.FontSize = 14;
            app.InterpolationMethodsListBoxLabel.FontWeight = 'bold';
            app.InterpolationMethodsListBoxLabel.Position = [83 254 153 22];
            app.InterpolationMethodsListBoxLabel.Text = 'Interpolation Methods';

            % Create InterpolationMethodsListBox
            app.InterpolationMethodsListBox = uilistbox(app.UIFigure);
            app.InterpolationMethodsListBox.Items = {'Linear', 'Nearest', 'Pchip', ''};
            app.InterpolationMethodsListBox.FontSize = 14;
            app.InterpolationMethodsListBox.FontWeight = 'bold';
            app.InterpolationMethodsListBox.Position = [68 173 181 74];
            app.InterpolationMethodsListBox.Value = 'Linear';

            % Create RegressionOrderSliderLabel
            app.RegressionOrderSliderLabel = uilabel(app.UIFigure);
            app.RegressionOrderSliderLabel.HorizontalAlignment = 'center';
            app.RegressionOrderSliderLabel.FontSize = 14;
            app.RegressionOrderSliderLabel.FontWeight = 'bold';
            app.RegressionOrderSliderLabel.Position = [98 132 123 22];
            app.RegressionOrderSliderLabel.Text = 'Regression Order';

            % Create RegressionOrderSlider
            app.RegressionOrderSlider = uislider(app.UIFigure);
            app.RegressionOrderSlider.MinorTicks = [];
            app.RegressionOrderSlider.Position = [62 120 189 3];

            % Create EnableDataSaveCheckBox
            app.EnableDataSaveCheckBox = uicheckbox(app.UIFigure);
            app.EnableDataSaveCheckBox.Text = 'Enable Data Save';
            app.EnableDataSaveCheckBox.FontSize = 14;
            app.EnableDataSaveCheckBox.FontWeight = 'bold';
            app.EnableDataSaveCheckBox.Position = [90 40 172 22];

            % Create CalculateDataButton
            app.CalculateDataButton = uibutton(app.UIFigure, 'push');
            app.CalculateDataButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateDataButtonPushed, true);
            app.CalculateDataButton.FontSize = 14;
            app.CalculateDataButton.FontWeight = 'bold';
            app.CalculateDataButton.Position = [390 28 272 46];
            app.CalculateDataButton.Text = 'Calculate Data';

            % Create GUIAnalysisSystemLabel
            app.GUIAnalysisSystemLabel = uilabel(app.UIFigure);
            app.GUIAnalysisSystemLabel.HorizontalAlignment = 'center';
            app.GUIAnalysisSystemLabel.FontSize = 18;
            app.GUIAnalysisSystemLabel.FontWeight = 'bold';
            app.GUIAnalysisSystemLabel.Position = [378 416 295 46];
            app.GUIAnalysisSystemLabel.Text = 'GUI Analysis System';

            % Create INPUT2EditFieldLabel
            app.INPUT2EditFieldLabel = uilabel(app.UIFigure);
            app.INPUT2EditFieldLabel.HorizontalAlignment = 'center';
            app.INPUT2EditFieldLabel.FontSize = 14;
            app.INPUT2EditFieldLabel.FontWeight = 'bold';
            app.INPUT2EditFieldLabel.Position = [130 336 60 22];
            app.INPUT2EditFieldLabel.Text = 'INPUT 2';

            % Create INPUT2EditField
            app.INPUT2EditField = uieditfield(app.UIFigure, 'text');
            app.INPUT2EditField.Position = [68 309 181 20];

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            xlabel(app.UIAxes, 'INPUT 1')
            ylabel(app.UIAxes, 'INPUT 2')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.PlotBoxAspectRatio = [1.39033457249071 1 1];
            app.UIAxes.Position = [285 92 423 325];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GUIAnalysis

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end