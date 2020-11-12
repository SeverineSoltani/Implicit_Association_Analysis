function Scenario_vs_IAT(expVersion,isSmile,scenario,folder1,folder2)
    clc;

    subjects = [];
    dStart = [];
    D2Smile = [];
    D2Symbol = [];
    cond = [];
    d1Scenario = [];
    d2Scenario = [];
    folderpath = [folder1,folder2]; % full file paths containing the data
    addpath(folder1,folder2);
    folder = expVersion;

    %4 motorist, 5 lost, 6 dating
    path = fullfile(char(folderpath(folder)), '**');
    filelist   = dir(path);
    name       = {filelist.name};
    name       = name(~strncmp(name, '.', 1));

    scenarioNames = ["Stranded Motorist" ,"Feeling Lost", "Dating App"];
    versions = ["Exp. Version 1: ", "Exp. Version 2: "];
    taskCond = ["(Check Mark/'X')", "(Smileys)";  "(Words)", "(Smileys)"];

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

        %% Filtering to IAT only
        
        onlyTaskA = data.Task == 1; % first IAT
        onlyTrialType3 = data.Trial_Type == 3; % main exp
        noCatchQ = data.Catch_Trial == 0; % no catch trials
        mask = onlyTaskA & onlyTrialType3 & noCatchQ;
        dataIAT_A = data(mask,:);

        onlyTaskC = data.Task == 3; % second IAT
        noCatchQ = data.Catch_Trial == 0; % no catch trials
        mask = onlyTaskC & onlyTrialType3 & noCatchQ;
        dataIAT_C = data(mask,:);

        %% Preprocessing IAT data

        if condGroup == 0 % smiley first
            congruent = dataIAT_A(1:60,:).Response_Time...
                (dataIAT_A(1:60,:).WasCorrect == 1);
            incongruent = dataIAT_A(61:120,:).Response_Time...
                (dataIAT_A(61:120,:).WasCorrect == 1);
        elseif condGroup == 1 % symbol first
            congruent = dataIAT_A(1:60,:).Response_Time...
                (dataIAT_A(1:60,:).WasCorrect == 1);
            incongruent = dataIAT_A(61:120,:).Response_Time...
                (dataIAT_A(61:120,:).WasCorrect == 1);
        elseif condGroup == 2 % smiley first
            incongruent = dataIAT_A(1:60,:).Response_Time...
                (dataIAT_A(1:60,:).WasCorrect == 1);
            congruent = dataIAT_A(61:120,:).Response_Time...
                (dataIAT_A(61:120,:).WasCorrect == 1);
        else % symbol first
            incongruent = dataIAT_A(1:60,:).Response_Time...
                (dataIAT_A(1:60,:).WasCorrect == 1);
            congruent = dataIAT_A(61:120,:).Response_Time...
                (dataIAT_A(61:120,:).WasCorrect == 1);
        end

        %% Check for a significant difference in congruent and incongruent RT
        
        h = ttest2(incongruent,congruent,'Alpha',0.1);

        if h == 1
            
            %% Get second IAT data
            if condGroup == 0 % smileys
                congruentSecondSmile = dataIAT_C(1:60,:).Response_Time...
                    (dataIAT_C(1:60,:).WasCorrect == 1);
                incongruentSecondSmile = dataIAT_C(61:120,:).Response_Time...
                    (dataIAT_C(61:120,:).WasCorrect == 1);
                congruentSecondSymbol = dataIAT_C(121:180,:).Response_Time...
                    (dataIAT_C(121:180,:).WasCorrect == 1);
                incongruentSecondSymbol = dataIAT_C(181:240,:).Response_Time...
                    (dataIAT_C(181:240,:).WasCorrect == 1);
                
            elseif condGroup == 1 % symbols 
                congruentSecondSymbol = dataIAT_C(1:60,:).Response_Time...
                    (dataIAT_C(1:60,:).WasCorrect == 1);
                incongruentSecondSymbol = dataIAT_C(61:120,:).Response_Time...
                    (dataIAT_C(61:120,:).WasCorrect == 1);
                congruentSecondSmile = dataIAT_C(121:180,:).Response_Time...
                    (dataIAT_C(121:180,:).WasCorrect == 1);
                incongruentSecondSmile = dataIAT_C(181:240,:).Response_Time...
                    (dataIAT_C(181:240,:).WasCorrect == 1);
                
            elseif condGroup == 2 % smileys 
                incongruentSecondSmile = dataIAT_C(1:60,:).Response_Time...
                    (dataIAT_C(1:60,:).WasCorrect == 1);
                congruentSecondSmile = dataIAT_C(61:120,:).Response_Time...
                    (dataIAT_C(61:120,:).WasCorrect == 1);
                incongruentSecondSymbol = dataIAT_C(121:180,:).Response_Time...
                    (dataIAT_C(121:180,:).WasCorrect == 1);
                congruentSecondSymbol = dataIAT_C(181:240,:).Response_Time...
                    (dataIAT_C(181:240,:).WasCorrect == 1);
                
            else % symbols
                incongruentSecondSymbol = dataIAT_C(1:60,:).Response_Time...
                    (dataIAT_C(1:60,:).WasCorrect == 1);
                congruentSecondSymbol = dataIAT_C(61:120,:).Response_Time...
                    (dataIAT_C(61:120,:).WasCorrect == 1);
                incongruentSecondSmile = dataIAT_C(121:180,:).Response_Time...
                    (dataIAT_C(121:180,:).WasCorrect == 1);
                congruentSecondSmile = dataIAT_C(181:240,:).Response_Time...
                    (dataIAT_C(181:240,:).WasCorrect == 1);
            end

            meanCongruentSmile = mean(congruentSecondSmile);
            meanIncongruentSmile = mean(incongruentSecondSmile);
            meanCongruentSymbol = mean(congruentSecondSymbol);
            meanIncongruentSymbol = mean(incongruentSecondSymbol);

            stdev_smile = std([congruentSecondSmile;incongruentSecondSmile]);
            stdev_symbol = std([congruentSecondSymbol;incongruentSecondSymbol]);

            d2Smile = (meanIncongruentSmile - meanCongruentSmile)/stdev_smile;
            d2Symbol = (meanIncongruentSymbol - meanCongruentSymbol)/stdev_symbol;

            meanCongruent = mean(congruent);
            meanIncongruent = mean(incongruent);

            stdev = std([congruent;incongruent]);

            d_120 =  (meanIncongruent - meanCongruent)/stdev;

            newName = regexp(name(i),'\d*', 'match');
            subjects = [subjects;string(newName)];
            dStart = [dStart; d_120];
            D2Smile = [D2Smile;d2Smile];
            D2Symbol = [D2Symbol;d2Symbol];
            cond = [cond;condGroup];


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

            %% Scenario D Scores
            
            d1Scenario = [d1Scenario;(meanRatingWhiteA - meanRatingBlackA)/...
            std([dataScenarioA(whiteFacesA,:).Response;...
            dataScenarioA(blackFacesA,:).Response])];
            d2Scenario = [d2Scenario;(meanRatingWhiteC - meanRatingBlackC)/...
            std([dataScenarioC(whiteFacesC,:).Response;...
            dataScenarioC(blackFacesC,:).Response])];
        end
    end
    
    %% Construct table(s)
    
    T = table(cond, subjects,dStart,D2Smile,D2Symbol,d1Scenario,d2Scenario);
    T.subjects = str2double(T.subjects);

    TSigPos = T(T.dStart > 0, :);
    TSigNeg = T(T.dStart < 0, :);

    %% Table with significantly positive/negative starting IAT D Scores
    TSigSmilePos = TSigPos(TSigPos.cond == 0 |TSigPos.cond == 2, :);
    TSigSmileNeg = TSigNeg(TSigNeg.cond == 0 |TSigNeg.cond == 2, :);
    TSigSymbolPos = TSigPos(TSigPos.cond == 1 |TSigPos.cond == 3, :);
    TSigSymbolNeg = TSigNeg(TSigNeg.cond == 1 |TSigNeg.cond == 3, :);

    %% Plot first scenario D Score vs first IAT D Score

    figure(1);
    if isSmile == 1
        groupPos = TSigSmilePos.dStart;
        groupNeg = TSigSmileNeg.dStart;
        y = [TSigSmilePos.d1Scenario; TSigSmileNeg.d1Scenario];
    else
        groupPos = TSigSymbolPos.dStart;
        groupNeg = TSigSymbolNeg.dStart;
        y = [TSigSymbolPos.d1Scenario; TSigSymbolNeg.d1Scenario];
    end
    x = [groupPos;groupNeg];
    scatter(x,y, 15, 'filled');
    hold on;
    
    idxValid = ~isnan(y); % filter out subjects with 0 stdev
    Fit = polyfit(x(idxValid),y(idxValid),1);
    plot(x(idxValid),polyval(Fit,x(idxValid)));
    y1 = linspace(-2,3,100);
    plot(y1,y1, '--k')
    yline(0,'--','y = 0');

    [r,p]=corrcoef(x,y,'Rows','complete');
    text(-1.75,1.25,{'r = '+string(r(1,2)),'p = '+string(p(1,2))});
    text(1.6,1.5,'y = x')

    xlim([-2 2])
    ylim([-2 2])

    xlabel('D Score Pre-Individuation');
    ylabel('Scenario D Score Pre-Individuation');
    title({versions(expVersion) + scenarioNames(scenario - 3)...
        + ' Scenario D Score Before' 'Individuation vs D Score Before Individuation '...
        + taskCond(expVersion, isSmile + 1)});

end