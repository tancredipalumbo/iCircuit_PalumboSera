%---------------------------------------------------------------------
% mainInteractiveTest
%---------------------------------------------------------------------
% Main script for testing autoCircuits interactive solution framework
%---------------------------------------------------------------------

try


% Clean up
clearvars;

% Enable saving/loading individual workspaces at each iteration
mustSaveDebugInfo = 0;

% Enable saving/loading problem statement
mustSaveInitialDebugInfo = 0;
mustLoadInitialDebugInfo = 0;

% Flag for pausing between individual iterations
mustPause = 0;

% Testing mode (choose one)
% testingMode = 'manual';
% testingMode = 'manual';
testingMode = 'interactive';

% Parameters for manual testing
if strcmp(testingMode,'manual')
    
    
    
    % Esempio 7-repeated div
    % allTemplates = {'Superposition', 'GeneralTransients_SymbolicMethod'};
    %allTemplates = {'SimplifiedNodalAnalysis'};
    allTemplates = {'KirchhoffLaws'};
    
    n1=0;
    nIter = length(allTemplates);
elseif strcmp(testingMode,'random')
    n1=0;
    nIter = 5;
end


%% Initialization and control parameters (this will need to be parameterized)

% ----- The case below is for DC Req only -----

% Parameters for multiple circuit generation
nCircuits = 1; % THIS IS UNUSED IN INTERACTIVE MODE: REMOVE

% Name of output LaTeX and pdf files (no extension)
Preferences = get_G_Preferences;
LaTeXfile = [Preferences.filename '_LaTeX'];
filename = Preferences.filename;

% Basic parameters (defaults)
generalOptions = getDefaultGeneralOptions;
graphOptions = getDefaultGraphOptions;
circuitOptions = getDefaultCircuitOptions;
solutionOptions = getDefaultSolutionOptions;
bodeOptions = getDefaultBodeOptions;
spiceOptions = getDefaultSpiceOptions;

% Modify options to customize current test
circuitOptions.language = 'EN';
circuitOptions.type = 'numeric';
%circuitOptions.type = 'symbolic';
% circuitOptions.numberType = 'real';
circuitOptions.numberType = 'integer';
circuitOptions.outputFormat = 'HTML'; % This MUST be HTML (unused)

%--------- !!! This will need to be generalized !!! ----------
%
% Omit the keyword "step" so that the circuit problem generation can be
% performed with standard autoCircuits functions of type "fun_*.m". These
% will generate the circuit and its data, the problem statement, and the
% result computed via automated MNA.
solutionOptions.type = 'result';

generalOptions.difficulty = 'hard';

% Requested analysis type
switch testingMode
    case 'interactive'
        chapter{1}='DC_Analysis';
        chapter{2}='DC_Req';
        chapter{3}='DC_Thevenin';
        chapter{4}='DC_Norton';
        chapter{5}='Kirchhoff_Laws';
        chapter{6}='AC_Zeq';
        chapter{7}='AC_Analysis';
        chapter{8}='AC_Thevenin';
        chapter{9}='AC_Norton';
        chapter{10}='DC_MNA';
        chapter{11}='LTI_MNA';
        chapter{12}='DC_TwoPort';
        % Open dialog for method selection
        [ii,tf] = listdlg('ListString',chapter ,...
            'PromptString','Select method:',...
            'SelectionMode','single',...
            'ListSize',[300,200],...
            'InitialValue',1,...
            'OKString','Choose',...
            'CancelString','Abort');
        
        % Exit immediately if User aborted operation
        if ~tf
            return;
        end
end
generalOptions.chapter = chapter{ii};
% generalOptions.chapter = 'DC_Analysis';

[analysisType,analysisModifier] = assignAnalysis(generalOptions.chapter);


% Initialize the generator of circuit element names and node labels
getNewElementSubscript('init');
getNewNodeLabel('init');

% Uncomment to solve netlist hard-defined in decodeSpiceOptions
% spiceOptions.netlist = 'debugMe';


%% Create circuit problem based on control options

% Use standard option decoding from main autoCircuits handlers
% NB: the following cases are taken from autoCirDriver almost without
% differences
if ~isempty(spiceOptions.netlist)
    % Get here if a SPICE netlist is non-empty, meaning that we are
    % serving the autoCircuits SPICE service. Construct the circuit
    % structure starting from the netlist
    [G,circuitOptions,autoCirFun,funType,analysisType,analysisModifier,outSpiceError,funArgs] = ...
        decodeSpiceOptions(graphOptions,circuitOptions,spiceOptions);
else
    % Get here if the standard autoCircuits service is being executed
    [generalOptions,circuitOptions,graphOptions,bodeOptions,autoCirFun,funType] = ...
        adjustCirOptions(generalOptions,circuitOptions,graphOptions,bodeOptions);
end

% Generate circuits, problem statements and their solution.
% NB: The following cases are taken from autoCirDriver almost without
% differences (eliminated multiple circuit generation via nCircuits).
if strcmpi(funType,'ERROR')
    error('Problems in decoding circuit specs.');
elseif strcmp(funType,'Bode')
    [G,header,solution] = autoCirFun(bodeOptions,circuitOptions);
elseif strcmp(funType,'SPICE')
    % Note: use NaN as last argument to force circuit singularity check
    [G,header,solution] = autoCirFun(G,circuitOptions,solutionOptions,NaN,funArgs{:});
elseif strcmp(funType,'SPICE_MNA')
    [G,header,solution] = autoCirFun(G,circuitOptions,solutionOptions);
else
    graphOptions.n=4;
    graphOptions.b=6;
    circuitOptions.nOutputs=1;
    circuitOptions.maxSources=0;
    circuitOptions.maxDynamic=0;
    circuitOptions.maxControlledSources = 0;
    circuitOptions.maxOpAmps = 0;
    circuitOptions.maxIdealTransformers = 0;
    circuitOptions.maxInductorCouplings = 0;
    circuitOptions.language = 'IT';
    % circuitOptions.type = 'symbolic';
    [G,header,solution] = ...
        autoCirFun(graphOptions,circuitOptions,solutionOptions);
end


% TO DEBUG MNA METHODS ONLY
if iscell(G) && length(G) == 2
    G = G{1};
    htmp = header{2}{1};
    htmp = htmp(1:strfind(htmp,'<p class=')-1);
    header = header{1};
    solution = [htmp;solution{2}(:)];
end


if mustSaveInitialDebugInfo
    save tmp_debug.mat
end
if mustLoadInitialDebugInfo
    load tmp_debug.mat
end

%save graph
% load graph
% [G,header,solution,isSingular] = solve_DC(G,circuitOptions,solutionOptions,0);
% n1 = 0;
%load graph2

%% ----------------- IMPORTANT! ADDED by SGT ----------------

% Lock voltage and current labels, so that any future processing will not
% rename variables requested on output due to
% renumbering/suppression/addition of elements
G = lockVoltageCurrentLabels(G);



% Add drawing information to circuit
[status,Gdraw,filename] = addGraphDrawingData(G,graphOptions,filename);
if status
    % Stop here and issue error
    error('Problems occurred during BLAG execution.');
end

%% Syntesize SVG code for current circuit: store in cell array of strings

% Direct export to cell array of strings
G_SVG = writeCircuit2HTML(Gdraw,header,solution);


%% Assemble main data structure for circuit solution tree

% Initialize circuit solution tree
cirSolTree = initCirSolTree(Gdraw,header,solution,analysisType,analysisModifier);
cirSolTree.nodes.data{cirSolTree.nodes.root}.G_SVG = G_SVG;
if isfield(cirSolTree.nodes,'active') && ~isempty(cirSolTree.nodes.active)
    cirSolTree.nodes.status{cirSolTree.nodes.active(1)} = 'active';
end

% Insert generated circuit in data structure
% cirSolTree.nodes.data{cirSolTree.nodes.root}.G = Gdraw;
% cirSolTree.nodes.data{cirSolTree.nodes.root}.header = header;
% cirSolTree.nodes.data{cirSolTree.nodes.root}.solution = solution;
%
% cirSolTree.nodes.data{cirSolTree.nodes.root}.analysisType = analysisType;
% cirSolTree.nodes.data{cirSolTree.nodes.root}.analysisModifier = analysisModifier;
% cirSolTree.nodes.data{cirSolTree.nodes.root}.G_SVG = G_SVG{1};


if mustSaveDebugInfo
    save debugInfo_000.mat %#ok<UNRCH>
    iDebug = 0;
end


%% Main loop for adding templates/content until completion

% Find the current active node and corresponding outgoing undefined edge
[nodeActive,edgeActive] = findActiveNodeAndEdge(cirSolTree);

% Find all methods that are applicable to current circuit
% !!! Modified by SGT on October 25, 2024 with more output arguments !!!
[Methods,analysisType,analysisModifier] = getMethods(G, ...
    analysisType, ...
    analysisModifier);

% Populate undefined div with decision buttons corresponding to methods
cirSolTree = writeCirSolButtons(cirSolTree,Methods,cirSolTree.edges.id{edgeActive});

% Write HTML code to output file and preview
writeTestSolTreeLayout_HTML(cirSolTree,1);


cirSolTree.nodes.data{nodeActive}.G=G;
cirSolTree.nodes.data{nodeActive}.analysisType= analysisType ;
cirSolTree.nodes.data{nodeActive}.analysisModifier= analysisModifier;

while ~isempty(nodeActive)
    
    % Retrieve ID of edge that will be replaced by method template
    edgeID = cirSolTree.edges.id{edgeActive};
    
    % Retrieve curent circuit and associated analysis to be carried out
    if length(cirSolTree.nodes.data) < nodeActive || ...
            ~isfield(cirSolTree.nodes.data{nodeActive},'G')
        
        cirSolTree.nodes.data{nodeActive}.G = [];
        
        
        
    end
    
    % Find all methods that are applicable to current circuit
    Methods = getMethods(cirSolTree.nodes.data{nodeActive}.G, ...
        cirSolTree.nodes.data{nodeActive}.analysisType, ...
        cirSolTree.nodes.data{nodeActive}.analysisModifier);
    
    % Present methods to the User
    iOK = find(Methods.priority > 0);
    iKO = find(Methods.priority <= 0);
    okMethods = Methods.name(iOK);
    
    % Exit immediately if there are no available methods for this circuit
    if isempty(iOK)
        break;
    end
    
    % Determine which template to use depending on testing mode
    switch testingMode
        case 'interactive'
            
            % Open dialog for method selection
            [ii,tf] = listdlg('ListString', okMethods,...
                'PromptString','Select method:',...
                'SelectionMode','single',...
                'ListSize',[300,200],...
                'InitialValue',1,...
                'OKString','Choose',...
                'CancelString','Abort');
            
            % Exit immediately if User aborted operation
            if ~tf
                break;
            end
            
            % Get here if user made a selection
            selectedMethod = okMethods{ii};
            
        case {'manual','random'}
            
            % Manual testing: templates are defined a priori (see top of
            % script)
            n1=n1+1;
            if n1 > nIter
                break
            else
                if strcmp(testingMode,'manual')
                    selectedMethod = allTemplates{n1};
                else
                    ii = randi(length(okMethods));
                    selectedMethod = okMethods{ii};
                end
            end
    end
    
    % Apply current method to G in order to perform
    % analysisType/analysisModifier pair. This call must insert method
    % template, perform all calculations on G, and store all node+edge data
    % fields, including graph drawing information
    cirSolTree = applyMethod(cirSolTree,selectedMethod,edgeID);
    
    % Find the current active node and corresponding outgoing undefined edge
    [nodeActive,edgeActive] = findActiveNodeAndEdge(cirSolTree);
    
    % Check for completion of circuit analysis. Otherwise, populate
    % undefined DIV selected for processing with decision buttons
    % corresponding to enabled methods (visible only in the interactive
    % case, or in case circuit solution is not complete after the last
    % manual/random step!)
    if isempty(nodeActive) && isempty(edgeActive)
        cirSolTree = finalizeSolStepAnalysis(cirSolTree);
        
    else
        
        
        % Find all methods that are applicable to current circuit
        Methods = getMethods(cirSolTree.nodes.data{nodeActive}.G, ...
            cirSolTree.nodes.data{nodeActive}.analysisType, ...
            cirSolTree.nodes.data{nodeActive}.analysisModifier);
        
        % Present methods to the User
        iOK = find(Methods.priority > 0);
        iKO = find(Methods.priority <= 0);
        okMethods = Methods.name(iOK);
        cirSolTree = writeCirSolButtons(cirSolTree,Methods,cirSolTree.edges.id{edgeActive});
    end
    
    
    % Write HTML code to output file and preview
    writeTestSolTreeLayout_HTML(cirSolTree,1);
    
    
    % Write debug info
    if mustSaveDebugInfo
        iDebug = iDebug + 1; %#ok<UNRCH>
        iDebugStr = sprintf('%03d',iDebug);
        save(['debugInfo_' iDebugStr '.mat']);
    end
    
    % Pause if required
    if mustPause
        % cirSolTree.nodes.active
        pause
    end
    
    
    
end



catch ME
    rethrow(ME);
    keyboard
end



