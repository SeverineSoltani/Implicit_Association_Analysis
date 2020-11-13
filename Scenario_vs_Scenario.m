function Scenario_vs_Scenario(expVersion,scenario,folder1,folder2)
    clc;

    subjects = [];
    cond = [];
    d1Scenario = [];
    d2Scenario = [];
    folderpath = [folder1,folder2]; % full file paths containing the data
    addpath(folder1,folder2);
    folder = expVersion;

    % 4 motorist, 5 lost, 6 dating
    path = fullfile(char(folderpath(folder)), '**');
    filelist = dir(path);
    name = {filelist.name};
    name = name(~strncmp(name, '.', 1));

    scenarioNames = ["Stranded Motorist," ,"Feeling Lost,", "Dating App,"];
    versions = ["Exp. Version 1: ", "Exp. Version 2: "];

    for i = 1:length(name)

        %% Get condition group
        
        opts = detectImportOptions(name{i},'NumHeaderLines',0); 
        opts.VariableNamesLine = 1; 
        opts.DataLines = [2 2]; % where data is
        condGroup = readtable(name{i},opts).Cond_Group(1);

        %% Get all the data
        
        opts = detectImportOptions(name{i},'NumHeaderLines',3); % ignore first 3 lines
        opts.VariableNamesLine = 4; % row number which has variable names
        opts.DataLine = 5;
        data = readtable(name{i},opts);

        %% Filtering to Scenarios Only

        onlyTaskA = data.Task == 1; % first scenario task
        onlyTrialTypeScenario = data.Trial_Type == scenario; % one scenario only
        mask = onlyTaskA & onlyTrialTypeScenario;
        dataScenarioA = data(mask,:);

        onlyTaskC = data.Task == 3; % second scenario task
        mask = onlyTaskC & onlyTrialTypeScenario;
        dataScenarioC = data(mask,:);

        %% Filtering out too long response times

        avgA = mean(dataScenarioA.Response_Time);
        stdevA = std(dataScenarioA.Response_Time);
        within2StdevA = (dataScenarioA.Response_Time <= avgA + 2*stdevA)...
            & (dataScenarioA.Response_Time >= avgA - 2*stdevA);
        dataScenarioA = dataScenarioA(within2StdevA,:);

        avgC = mean(dataScenarioC.Response_Time);
        stdevC = std(dataScenarioC.Response_Time);
        within2StdevC = (dataScenarioC.Response_Time <= avgC + 2*stdevC)...
            & (dataScenarioC.Response_Time >= avgC - 2*stdevC);
        dataScenarioC = dataScenarioC(within2StdevC,:);

        %% Filtering stimuli by race

        blackFacesA = dataScenarioA.Race == 1;
        whiteFacesA = dataScenarioA.Race == 0;
        blackFacesC = dataScenarioC.Race == 1;
        whiteFacesC = dataScenarioC.Race == 0;

        %% Mean by condition

        meanRatingBlackA = mean(dataScenarioA(blackFacesA,:).Response);
        meanRatingWhiteA = mean(dataScenarioA(whiteFacesA,:).Response);

        meanRatingBlackC = mean(dataScenarioC(blackFacesC,:).Response);
        meanRatingWhiteC = mean(dataScenarioC(whiteFacesC,:).Response);

        %% Check for a significant difference in ratings for Black and White faces
        [h,p] = ttest2(dataScenarioA(blackFacesA,:).Response,...
            dataScenarioA(whiteFacesA,:).Response,'alpha', 0.1);
            
        if h == 1
            
            %% Scenario D Scores

            d1Scenario = [d1Scenario;(meanRatingWhiteA - meanRatingBlackA)/...
            std([dataScenarioA(whiteFacesA,:).Response;...
            dataScenarioA(blackFacesA,:).Response])];
        
            d2Scenario = [d2Scenario;(meanRatingWhiteC - meanRatingBlackC)/...
            std([dataScenarioC(whiteFacesC,:).Response;...
            dataScenarioC(blackFacesC,:).Response])];
        
            newName = regexp(name(i),'\d*', 'match');
            subjects = [subjects;string(newName)];
            cond = [cond;condGroup];
            
        end
    end
    
    %% Remove participants with 0 standard deviation in responses
    
    rmvNan = ~isnan(d1Scenario) & ~isnan(d2Scenario);
    d1Scenario = d1Scenario(rmvNan);
    d2Scenario = d2Scenario(rmvNan);

    %% Plot first scenario D Score vs first IAT D Score

    figure(1);
    scatter(d1Scenario,d2Scenario,15,'filled');
    hold on;
    
    Fit = polyfit(d1Scenario,d2Scenario,1);
    plot(d1Scenario,polyval(Fit,d1Scenario));
    y1 = linspace(-2,3,100);
    plot(y1,y1, '--k')
    yline(0,'--','y = 0');

    [r,p]=corrcoef(d1Scenario,d2Scenario,'Rows','complete');
    text(-1.75,1.25,{'r = '+string(r(1,2)),'p = '+string(p(1,2))});
    text(1.6,1.5,'y = x')

    xlim([-2 2])
    ylim([-2 2])

    xlabel('D Score Pre-Individuation');
    ylabel('Scenario D Score Pre-Individuation');
    title({versions(expVersion) + scenarioNames(scenario - 3)...
        + ' Scenario D Score After' 'Individuation vs Scenario D Score Before Individuation'});
  
end