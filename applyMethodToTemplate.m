function template = applyMethodToTemplate(template,method)
%
% template = applyMethodToTemplate(template,method)
%
% Applies method to template. It is assumed that
%
% - template is compatible to method
% - circuit graph and data is available for template root node (1)
%
% This function completes all steps locally in template, by filling all
% data fields of template.edges and template.nodes.


% ---------  DEBUG DEBUG DEBUG ---------
% Empty implementation, insert just dummy fillers for all data elements, so
% that debugging can continue with no errors. These lines must be deleted.
%
% % These will be printed in HTML out
% for ii = 2:template.n
%     template.nodes.data{ii}.G = [];
%     template.nodes.data{ii}.header = {[method ': header, template node: ' int2str(ii)]};
%     template.nodes.data{ii}.solution = {[method ': solution, template node: ' int2str(ii)]};
%     template.nodes.data{ii}.analysisType = template.nodes.data{1}.analysisType;
%     template.nodes.data{ii}.analysisModifier = template.nodes.data{1}.analysisModifier;
%     template.nodes.data{ii}.G_SVG = {[method ': SVG body, template node: ' int2str(ii)]};
% end
% % These will be overwritten
% for ii = 1:template.b
%     template.edges.data{ii}.G_step = [];
%     template.edges.data{ii}.header_step = {[method ': header, template edge: ' int2str(ii)]};
%     template.edges.data{ii}.solution_step = {[method ': solution, template edge: ' int2str(ii)]};
%     template.edges.data{ii}.G_step_SVG = {[method ': SVG edge, template edge: ' int2str(ii)]};
% end
% ---------  DEBUG DEBUG DEBUG ---------

try


% Extract current circuit (located in the root node of the template)
currentG = template.nodes.data{template.nodes.root}.G;

% Clear all flags related to previous steps (this releases those methods
% that were blocked but there is no reason to apply them again)
currentG = clearAllPreviousStepFlags(currentG,method);

% Set runtime control parameter for computing solution and not checking
% applicability of the method (assumed to have been checked already)
solutionOptions.process='solveOnly';

% Extract analysisType and analysisModifier
analysisModifier = upper(template.nodes.data{template.nodes.root}.analysisModifier);
analysisType = upper(template.nodes.data{template.nodes.root}.analysisType);

% Retrieve the function associated to desired method
[~,methodFun] = getMethodSpec(method);

% Apply solver function to input circuit (input/output arguments are
% standardized for all methods)
[~, G_, header_, solution_, results]= methodFun(currentG, solutionOptions);

%% Assign results to template (and possibly correct template)

% Operations to be performed on template depend on the method. In
% particular, various methods are grouped based on template compatibility
% (all reduction methods share the same template, so that results will go
% in the same template positions).

switch method
    
    case {'CircuitReduction'}

        % Initialize with empty data (circuits/header/solution) all
        % template edges...
        for ii = 1:template.b
            template.edges.data{ii}.G_step = [];
            template.edges.data{ii}.header_step = {};
            template.edges.data{ii}.solution_step = {};
            template.edges.data{ii}.G_step_SVG = {};
        end
        % ... and nodes ...
        for ii = 2:template.n
            template.nodes.data{ii}.G = [];
            template.nodes.data{ii}.header = {};
            template.nodes.data{ii}.solution = {};
            template.nodes.data{ii}.G_SVG = {};
        end
        
        % Get here when circuit reduction (splitting phase) has been applied.
        % Must assign to individual template nodes the two circuits.
        
        % For this method, there are several subcircuits:
        % the first G_{1} is not processed and will wait for the equivalent to be ready;
        % the second G_{2} will be the starting point for the next task, which will
        % consist of equivalent circuit determination.
        % the third G_{3} is the original circuit with annotation on the
        % splitting. The latter goes to the edge of the template.
                    
        template.edges.data{1}.G_step = G_{3} ;
        template.edges.data{1}.header_step = header_{3};
        template.edges.data{1}.solution_step = solution_{3};
        template.edges.data{1}.G_step_SVG = generate_G_SVG(G_{3},header_{3},solution_{3});
        
        % Loop over the individual circuits obtained after splitting.
        % Solution is of course empty for these circuits.
        
        % ... One-port that remains unchanged
        template.nodes.data{2}.G = G_{1};
        template.nodes.data{2}.header = header_{1};
        template.nodes.data{2}.solution = {};
        template.nodes.data{2}.G_SVG = generate_G_SVG(...
            G_{1},...
            template.nodes.data{2}.header,...
            template.nodes.data{2}.solution);
        template.nodes.data{2}.analysisType = analysisType;
        template.nodes.data{2}.analysisModifier = analysisModifier;

        % ... One-port that will be replaced by its equivalent
        
        % Define analysis to be performed based on the structure of output
        % fields in subcircuit. These fields must be inserted by
        % CircuitReduction method!
        switch G_{2}.output{1}.type
            case 'thevenin'
                newAnalysisModifier = 'THEVENIN';
            case 'norton'
                newAnalysisModifier = 'NORTON';
            otherwise
                error('Unsupported output format for circuit reduction.')
        end
        
        template.nodes.data{3}.G = G_{2};
        template.nodes.data{3}.header = ...
            writeProblemStatement(analysisType,...
            newAnalysisModifier,...
            G_{2});
        template.nodes.data{3}.solution = {};
        template.nodes.data{3}.G_SVG = generate_G_SVG(...
            G_{2},...
            template.nodes.data{3}.header,...
            template.nodes.data{3}.solution);
        template.nodes.data{3}.analysisType = analysisType;
        template.nodes.data{3}.analysisModifier = newAnalysisModifier;
        
        % Copy unmodified circuit to sink node of template, but set its flag
        % for suppressing circuit drawing. Also, copy main analysis info
        template.nodes.data{5}.G = G_{1};
        template.nodes.data{5}.G.circuitOptions.noCircuitDrawing = true;
        template.nodes.data{5}.analysisType = analysisType;
        template.nodes.data{5}.analysisModifier = analysisModifier;
    
    case {'Superposition'}

        % Get here when superposition (splitting phase) has been applied.
        % Must assign to individual template nodes the various circuits.
        % Circuits as obtained by switching off sources (without any
        % topological modification are assigned to the first splitting
        % edges of the template.
        
        % Loop over the edges/circuits from splitting (note that
        % compatibility of template size is ensured by calling unit
        % applyMethod). Note that first template node (root=1) is the
        % original circuit. Circuits from splitting are numbered from 2
        % to nSources+1. Template edges that host the circuits in G_ are
        % numbered from 1 to nSources (length of G_).
        [jj_v,jj_i] = findActiveSources(currentG);
        nSources = length([jj_v,jj_i]);
        for ii = 1:nSources
            
            template.edges.data{ii}.G_step = G_{ii} ;
            template.edges.data{ii}.header_step = header_{ii};
            template.edges.data{ii}.solution_step = solution_{ii};
            template.edges.data{ii}.G_step_SVG = generate_G_SVG(G_{ii},header_{ii},solution_{ii});
        
        end
        
        % Loop over the individual circuits obtained after splitting.
        % Copy all circuits obtained by simplifying topology (available as
        % elements nSources+1:2*nSources in G_) with corresponding header
        % and copy them to the completed nodes of the template. Note that
        % the header is computed on the fly by writing the problem
        % statement associated to current analysis type and modifier, but
        % applied to each individual circuit (so that labels in the
        % statement are generated properly, with all sub and superscripts).
        % Solution is of course empty for these circuits.
        for ii = 1:nSources

            % Initialize qualifier string that will be typeset with problem
            % statements of each individual circuits, for clarity...
            if strcmp(G_{ii+nSources}.circuitOptions.language, 'EN')
                qualifier = [' (superposition circuit n.' int2str(ii) ')' ];
            else
                qualifier = [' (sovrapposizione degli effetti, circuito n.' int2str(ii) ')'];
            end
            template.nodes.data{ii+1}.G = G_{ii+nSources};
            template.nodes.data{ii+1}.header = ...
                writeProblemStatement(analysisType,...
                analysisModifier,...
                G_{ii+nSources},qualifier);
            template.nodes.data{ii+1}.solution = {};
            template.nodes.data{ii+1}.G_SVG = generate_G_SVG(...
                G_{ii+nSources},...
                template.nodes.data{ii+1}.header,...
                template.nodes.data{ii+1}.solution);
            template.nodes.data{ii+1}.analysisType = analysisType;
            template.nodes.data{ii+1}.analysisModifier = analysisModifier;
            
        end
        
        % Fill with empty data (circuits/header/solution) the other
        % template edges...
        for ii = nSources+1:3*nSources
            template.edges.data{ii}.G_step = [];
            template.edges.data{ii}.header_step = {};
            template.edges.data{ii}.solution_step = {};
            template.edges.data{ii}.G_step_SVG = {};
        end
        % ... and nodes ...
        for ii = nSources+2:2*nSources+2
            template.nodes.data{ii}.G = [];
            template.nodes.data{ii}.header = {};
            template.nodes.data{ii}.solution = {};
            template.nodes.data{ii}.G_SVG = {};
        end
       
        % Copy original circuit to sink node of template, but set its flag
        % for suppressing circuit drawing
        template.nodes.data{2*nSources+2}.G = currentG;
        template.nodes.data{2*nSources+2}.G.circuitOptions.noCircuitDrawing = true;
        
    case {'TheveninEquivalent_TwoStep','NortonEquivalent_TwoStep'}

        % Get here when Thevenin/Norton (2-step, splitting phase) has been applied.
        % Must assign to individual template nodes the various circuits.
        % Circuits for equivalent resistance (conductance) and open-circuit
        % voltage (short-circuit current) calculations (without any
        % topological modification) are assigned to the first splitting
        % edges of the template.
        
        nCircuits = 2;
        
        % Loop over the edges/circuits from splitting (note that
        % compatibility of template size is ensured by calling unit
        % applyMethod). Note that first template node (root=1) is the
        % original circuit. Circuits from splitting are numbered as 2 and
        % 3. Template edges that host the circuits in G_ are
        % numbered as 1 and 2 (length of G_).
        for ii = 1:nCircuits
            
            template.edges.data{ii}.G_step = G_{ii} ;
            template.edges.data{ii}.header_step = header_{ii};
            template.edges.data{ii}.solution_step = solution_{ii};
            template.edges.data{ii}.G_step_SVG = generate_G_SVG(G_{ii},header_{ii},solution_{ii});
        
        end
        
        % Loop over the individual circuits obtained after splitting.
        % Copy all circuits obtained by simplifying topology (available as
        % elements 1+1 : 1+nCircuits in G_) with corresponding header
        % and copy them to the completed nodes of the template. Note that
        % the header is computed on the fly by writing the problem
        % statement associated to current analysis type and modifier, but
        % applied to each individual circuit (so that labels in the
        % statement are generated properly, with all sub and superscripts).
        % Solution is of course empty for these circuits.
        
        % Initialize qualifier string that will be typeset with problem
        % statements of each individual circuits, for clarity...
        if isfield(G_{1},'domain') && strcmpi(G_{1}.domain,'phasor')
            if strcmp(method,'TheveninEquivalent_TwoStep')
                if strcmp(G_{1}.circuitOptions.language, 'EN')
                    qualifier = {' (equivalent impedance)',...
                        ' (open-circuit voltage)'};
                else
                    qualifier = {' (impedenza equivalente)',...
                        ' (tensione a vuoto)'};
                end
                newAnalysisModifier = {'ZEQ','SOLVE'};
            else
                if strcmp(G_{1}.circuitOptions.language, 'EN')
                    qualifier = {' (equivalent admittance)',...
                        ' (short-circuit current)'};
                else
                    qualifier = {' (ammettenza equivalente)',...
                        ' (corrente di corto-circuito)'};
                end
                newAnalysisModifier = {'YEQ','SOLVE'};
            end
        else
            if strcmp(method,'TheveninEquivalent_TwoStep')
                if strcmp(G_{1}.circuitOptions.language, 'EN')
                    qualifier = {' (equivalent resistance)',...
                        ' (open-circuit voltage)'};
                else
                    qualifier = {' (resistenza equivalente)',...
                        ' (tensione a vuoto)'};
                end
                newAnalysisModifier = {'REQ','SOLVE'};
            else
                if strcmp(G_{1}.circuitOptions.language, 'EN')
                    qualifier = {' (equivalent conductance)',...
                        ' (short-circuit current)'};
                else
                    qualifier = {' (conduttanza equivalente)',...
                        ' (corrente di corto-circuito)'};
                end
                newAnalysisModifier = {'GEQ','SOLVE'};
            end
        end
        
        for ii = 1:nCircuits
            template.nodes.data{ii+1}.G = G_{ii+nCircuits};
            template.nodes.data{ii+1}.header = ...
                writeProblemStatement(analysisType,...
                newAnalysisModifier{ii},...
                G_{ii+nCircuits},qualifier{ii});
            template.nodes.data{ii+1}.solution = {};
            template.nodes.data{ii+1}.G_SVG = generate_G_SVG(...
                G_{ii+nCircuits},...
                template.nodes.data{ii+1}.header,...
                template.nodes.data{ii+1}.solution);
            template.nodes.data{ii+1}.analysisType = analysisType;
            template.nodes.data{ii+1}.analysisModifier = newAnalysisModifier{ii};
            
        end
        
        % Fill with empty data (circuits/header/solution) the other
        % template edges...
        for ii = nCircuits+1:3*nCircuits
            template.edges.data{ii}.G_step = [];
            template.edges.data{ii}.header_step = {};
            template.edges.data{ii}.solution_step = {};
            template.edges.data{ii}.G_step_SVG = {};
        end
        % ... and nodes ...
        for ii = nCircuits+2:2*nCircuits+2
            template.nodes.data{ii}.G = [];
            template.nodes.data{ii}.header = {};
            template.nodes.data{ii}.solution = {};
            template.nodes.data{ii}.G_SVG = {};
        end
       
        % Copy original circuit to sink node of template, but set its flag
        % for suppressing circuit drawing
        template.nodes.data{2*nCircuits+2}.G = currentG;
        template.nodes.data{2*nCircuits+2}.G.circuitOptions.noCircuitDrawing = true;
        
    
    case {'TheveninEquivalent_OneStep',...
            'NortonEquivalent_OneStep',...
            'EquivalentResistance_TestSource',...
            'EquivalentConductance_TestSource'}

        % Get here when Thevenin/Norton (1-step, problem setup) or
        % equivalent resistance/conductance by port excitation has been
        % applied. 
        % Must assign to individual template nodes the various circuits.
        % There is only one circuit to be assigned to the solution step of
        % this method, the same circuit will be copied to the next problem
        % statememt.
            
        template.edges.data{1}.G_step = G_{1} ;
        template.edges.data{1}.header_step = header_{1};
        template.edges.data{1}.solution_step = solution_{1};
        template.edges.data{1}.G_step_SVG = generate_G_SVG(G_{1},header_{1},solution_{1});
        
        % Copy new circuit to be solved for symbolic characteristic
        % equation to the next active node of template, and properly set
        % its analysis type/modifier.
        
        newAnalysisModifier = 'SOLVE';
               
        template.nodes.data{2}.G = colorCircuitElements(G_{1},[],1);
        template.nodes.data{2}.header = ...
            writeProblemStatement(analysisType,...
            newAnalysisModifier,...
            G_{1});
        template.nodes.data{2}.solution = {};
        template.nodes.data{2}.G_SVG = generate_G_SVG(...
            G_{1},...
            template.nodes.data{2}.header,...
            template.nodes.data{2}.solution);
        template.nodes.data{2}.analysisType = analysisType;
        template.nodes.data{2}.analysisModifier = newAnalysisModifier;
        
        % Fill with empty data (circuits/header/solution) the other
        % template edges...
        for ii = 2:3
            template.edges.data{ii}.G_step = [];
            template.edges.data{ii}.header_step = {};
            template.edges.data{ii}.solution_step = {};
            template.edges.data{ii}.G_step_SVG = {};
        end
        % ... and nodes ...
        for ii = 3:4
            template.nodes.data{ii}.G = [];
            template.nodes.data{ii}.header = {};
            template.nodes.data{ii}.solution = {};
            template.nodes.data{ii}.G_SVG = {};
        end
       
        % Copy original circuit to sink node of template, but set its flag
        % for suppressing circuit drawing
        template.nodes.data{4}.G = currentG;
        template.nodes.data{4}.G.circuitOptions.noCircuitDrawing = true;

        %% Aggiunto qui
    case   {'TwoPorts_OneStep'}
        template.edges.data{1}.G_step = G_{1} ;
        template.edges.data{1}.header_step = header_{1};
        template.edges.data{1}.solution_step = solution_{1};
        template.edges.data{1}.G_step_SVG = generate_G_SVG(G_{1},header_{1},solution_{1});
        
        % Copy new circuit to be solved for symbolic characteristic
        % equation to the next active node of template, and properly set
        % its analysis type/modifier.
        
        newAnalysisModifier = 'SOLVE';
               
        template.nodes.data{2}.G = colorCircuitElements(G_{1},[],1);
        template.nodes.data{2}.header = ...
            writeProblemStatement(analysisType,...
            newAnalysisModifier,...
            G_{1});
        template.nodes.data{2}.solution = {};
        template.nodes.data{2}.G_SVG = generate_G_SVG(...
            G_{1},...
            template.nodes.data{2}.header,...
            template.nodes.data{2}.solution);
        template.nodes.data{2}.analysisType = analysisType;
        template.nodes.data{2}.analysisModifier = newAnalysisModifier;
        
        % Fill with empty data (circuits/header/solution) the other
        % template edges...
        for ii = 2:3
            template.edges.data{ii}.G_step = [];
            template.edges.data{ii}.header_step = {};
            template.edges.data{ii}.solution_step = {};
            template.edges.data{ii}.G_step_SVG = {};
        end
        % ... and nodes ...
        for ii = 3:4
            template.nodes.data{ii}.G = [];
            template.nodes.data{ii}.header = {};
            template.nodes.data{ii}.solution = {};
            template.nodes.data{ii}.G_SVG = {};
        end
       
        % Copy original circuit to sink node of template, but set its flag
        % for suppressing circuit drawing
        template.nodes.data{4}.G = currentG;
        template.nodes.data{4}.G.circuitOptions.noCircuitDrawing = true;

    case   {'PruneCircuit'}
        
        % Assign results to template only if method was successful
        if(~isempty(G_))
            
            % Get here if application of method was successful: must copy
            % results into template.
            
            % Populate template with results of reduction. Reduction
            % steps go in the first edge of the template
            template.edges.data{1}.G_step = G_ ;
            template.edges.data{1}.header_step = header_;
            template.edges.data{1}.solution_step = solution_;
            template.edges.data{1}.G_step_SVG = generate_G_SVG(G_,header_,solution_);
            
            % Future edge: this is still undefined: set as empty
            template.edges.data{2}.G_step = [];
            
            % Clear color of last circuit from reduction, this will be
            % the circuit copied to the active node of the template on
            % ouptut
            G_{end} = colorCircuitElements(G_{end},{},1);
            
            % Remove node annotation in final circuit, since unnecessary
            %%% G_{end}.nodes.mustShowNodeLabels = false;
            
            % Populate the active node of the template
            template.nodes.data{2}.G = G_{end};
            template.nodes.data{2}.analysisType = analysisType;
            template.nodes.data{2}.analysisModifier = analysisModifier;
            
            % Write initial problem statement to active template node
            % and generate HTML/SVG content
            template.nodes.data{2}.header = writeProblemStatement(...
                template.nodes.data{2}.analysisType,...
                template.nodes.data{2}.analysisModifier,...
                template.nodes.data{2}.G);
            template.nodes.data{2}.solution = [];
            template.nodes.data{2}.G_SVG = generate_G_SVG(...
                template.nodes.data{2}.G,...
                template.nodes.data{2}.header,...
                template.nodes.data{2}.solution);
            
            % Future node of template must remain empty
            template.nodes.data{3}.G = [];
            
        end
        
    case   {'ConvertToPhasorCircuit','SteadyStateAnalysis_AC'}
        
        % Assign results to template only if method was successful
        if(~isempty(G_))
            
            % Get here if application of method was successful: must copy
            % results into template.
            
            % Populate template with results of reduction. Reduction
            % steps go in the first edge of the template
            template.edges.data{1}.G_step = G_ ;
            template.edges.data{1}.header_step = header_;
            template.edges.data{1}.solution_step = solution_;
            template.edges.data{1}.G_step_SVG = generate_G_SVG(G_,header_,solution_);
            
            % Future edge: this is still undefined: set as empty
            template.edges.data{2}.G_step = [];
            
            % Clear color of last circuit from reduction, this will be
            % the circuit copied to the active node of the template on
            % ouptut
            %%% G_{end} = colorCircuitElements(G_{end},{},1);
            
            % Remove node annotation in final circuit, since unnecessary
            %%% G_{end}.nodes.mustShowNodeLabels = false;
            
            % Populate the active node of the template
            template.nodes.data{2}.G = G_{end};
            template.nodes.data{2}.analysisType = analysisType;
            template.nodes.data{2}.analysisModifier = analysisModifier;
            
            % Write initial problem statement to active template node
            % and generate HTML/SVG content
            template.nodes.data{2}.header = writeProblemStatement(...
                template.nodes.data{2}.analysisType,...
                template.nodes.data{2}.analysisModifier,...
                template.nodes.data{2}.G);
            template.nodes.data{2}.solution = [];
            template.nodes.data{2}.G_SVG = generate_G_SVG(...
                template.nodes.data{2}.G,...
                template.nodes.data{2}.header,...
                template.nodes.data{2}.solution);
            
            % Future node of template must remain empty
            template.nodes.data{3}.G = [];
            
            % Propagate to collection node for SteadyStateAnalysis_AC
            if strcmpi(method,'SteadyStateAnalysis_AC')
                template.nodes.data{4}.G = [];
                template.edges.data{3}.G_step = [];
                % Copy original circuit to sink node of template, but set its flag
                % for suppressing circuit drawing
                template.nodes.data{4}.G = currentG;
                template.nodes.data{4}.G.circuitOptions.noCircuitDrawing = true;
            end
            
        end
        
    case   {'SeriesParallelReduction',...
            'GeneralizedSeriesReduction',...
            'StarDeltaReduction',...
            'SubstitutionTheorem',...
            'SourceReduction',...
            'GeneralizedVoltageSourceSeries',...
            'SimplifyCircuitTopology',...
            'BasicTheveninToNorton',...
            'BasicNortonToThevenin'}
        
        % Assign results to template only if method was successful
        if(~isempty(G_))
            
            % Get here if application of method was successful: must copy
            % results into template.
            
            % Populate template with results of reduction. Reduction
            % steps go in the first edge of the template
            template.edges.data{1}.G_step = G_ ;
            template.edges.data{1}.header_step = header_;
            template.edges.data{1}.solution_step = solution_;
            template.edges.data{1}.G_step_SVG = generate_G_SVG(G_,header_,solution_);
            
            % Future edge: this is still undefined: set as empty
            template.edges.data{2}.G_step = [];
            
            % Clear color of last circuit from reduction, this will be
            % the circuit copied to the active node of the template on
            % ouptut
            G_{end} = colorCircuitElements(G_{end},{},1);
            
            % Remove node annotation in final circuit, since unnecessary
            %%% G_{end}.nodes.mustShowNodeLabels = false;
            
            % Populate the active node of the template
            template.nodes.data{2}.G = G_{end};
            template.nodes.data{2}.analysisType = analysisType;
            template.nodes.data{2}.analysisModifier = analysisModifier;
            
            % Write initial problem statement to active template node
            % and generate HTML/SVG content
            template.nodes.data{2}.header = writeProblemStatement(...
                template.nodes.data{2}.analysisType,...
                template.nodes.data{2}.analysisModifier,...
                template.nodes.data{2}.G);
            template.nodes.data{2}.solution = [];
            template.nodes.data{2}.G_SVG = generate_G_SVG(...
                template.nodes.data{2}.G,...
                template.nodes.data{2}.header,...
                template.nodes.data{2}.solution);
            
            % Future node of template must remain empty
            template.nodes.data{3}.G = [];
            
            % Template operations depending on type of analysis
            switch upper(analysisModifier)
                
                case {'REQ','ZEQ','GEQ','YEQ'}
                    
                    % If a reduction method is applied to evaluate an
                    % equivalent resistance, impedance, conductance or
                    % admittance it is possible
                    % that the results of the reduction are already the
                    % desired results of the analysis. In this case,
                    % iterations on current analysis must stop, and results
                    % must be made available.
                    
                    % Determine if reduction is complete.
                    [isComplete,idx] = checkForCompleteReduction(template.nodes.data{2}.G,analysisType,analysisModifier);
                    
                    % If complete, assign results and modify template to
                    % its completed form
                    if isComplete
                        
                        % Set the result available
                        [val,tmpZero] = getVal(G_{end});
                        tmpInf = tmpZero; tmpInf(end+1) = Inf;
                        tmpZero(end+1) = 0;
                        template.nodes.data{2}.G.output{1}.resultAvailable = true;
                        if ismember(analysisModifier,{'REQ','ZEQ'})
                            if isnumeric(idx)
                                template.nodes.data{2}.G.output{1}.(val)=G_{end}.edges.elemdata{idx}.(val);
                            elseif strcmp(idx,'short')
                                template.nodes.data{2}.G.output{1}.(val)= tmpZero;
                            elseif strcmp(idx,'open')
                                template.nodes.data{2}.G.output{1}.(val)= tmpInf;
                            else
                                error('This case cannot occur');
                            end
                        else
                            if isnumeric(idx)
                                template.nodes.data{2}.G.output{1}.(val)= 1 / G_{end}.edges.elemdata{idx}.(val);
                            elseif strcmp(idx,'short')
                                template.nodes.data{2}.G.output{1}.(val)= tmpInf;
                            elseif strcmp(idx,'open')
                                template.nodes.data{2}.G.output{1}.(val)= tmpZero;
                            else
                                error('This case cannot occur');
                            end
                        end
                        
                        % Modify template to mark it as complete
                        template = makeTemplateComplete(template,method);
                        
                    end
                    
                case {'THEVENIN','NORTON'}
                    
                    % If a reduction method is applied to evaluate a
                    % Thevenin/Norton equivalent, it is possible
                    % that the results of the reduction are already the
                    % desired results of the analysis. In this case,
                    % iterations on current analysis must stop, and results
                    % must be made available.
                    
                    % Determine if reduction is complete.
                    [isComplete,idx] = checkForCompleteReduction(template.nodes.data{2}.G,analysisType,analysisModifier);
                    
                    % If complete, assign results and modify template to
                    % its completed form
                    if isComplete
                        
                        % Set the result available
                        [val,tmpZero] = getVal(G_{end});
                        % Append placeholders for results: used to have a
                        % symbolic zero if required
                        tmpZero(end+1) = 0;
                        template.nodes.data{2}.G.output{1}.resultAvailable = true;
                        template.nodes.data{2}.G.output{1}.parts{1}.resultAvailable = true;
                        % Assign equivalent resistance/impedance or
                        % conductance/admittance (note inversion in the
                        % latter case)
                        if idx(1)
                            if strcmpi(analysisModifier,'THEVENIN')
                                template.nodes.data{2}.G.output{1}.parts{1}.(val)=G_{end}.edges.elemdata{idx(1)}.(val);
                            else
                                template.nodes.data{2}.G.output{1}.parts{1}.(val)=1/G_{end}.edges.elemdata{idx(1)}.(val);
                            end
                        else
                            template.nodes.data{2}.G.output{1}.parts{1}.(val)=tmpZero;
                        end
                        % Assign equivalent voltage/current source
                        template.nodes.data{2}.G.output{1}.parts{2}.resultAvailable = true;
                        if idx(2)
                            template.nodes.data{2}.G.output{1}.parts{2}.(val)=sign(idx(2))*G_{end}.edges.elemdata{abs(idx(2))}.(val);
                        else
                            template.nodes.data{2}.G.output{1}.parts{2}.(val)=tmpZero;
                        end
                        
                        % Modify template to mark it as complete
                        template = makeTemplateComplete(template,method,idx);
                        
                    end                    
                    
                case {'SOLVE'}
                    
                    % Generally, reduction methods will not
                    % finalize any solution, in which case no action is
                    % required. However, the particular case of
                    % Substitution Theorem and SimplifyCircuitTopology may
                    % lead to the calculation of 
                    % some output variables (those that are in parallel to
                    % independent voltage sources or in series to
                    % independent current sources. In this case, the
                    % results in G.output are already available. If all
                    % outputs are already available, the template must be
                    % made complete.
                    if ismember(method,{
                            'SubstitutionTheorem',...
                            'SimplifyCircuitTopology',...
                            'SeriesParallelReduction',...
                            'GeneralizedSeriesReduction',...
                            'SourceReduction',...
                            'GeneralizedVoltageSourceSeries',...
                            })
                        
                        % Store all computed outputs into appropriate
                        % template circuit structure if final results are
                        % available, or store information on relation
                        % between a computed variable and other unknowns,
                        % depending on the format of the results structure.
                        val = getVal(template.nodes.data{2}.G);
                        for ii = 1:length(results)
                            [idx,isfinal] = findOutputIndex(template.nodes.data{2}.G,results{ii});
                            if isfinal
                                % Get here if the final result for current
                                % variable is available
                                template.nodes.data{2}.G.output{idx}.resultAvailable = true;
                                template.nodes.data{2}.G.output{idx}.(val)= results{ii}.value;
                            else
                                % Get here if the current variable was
                                % found but is expressed as function of
                                % other variables. Store relation by
                                % copying the corresponding results
                                % structure element
                                template.nodes.data{2}.G.output{idx}.relationAvailable = true;
                                template.nodes.data{2}.G.output{idx}.relationData = results{ii};
                            end
                        end                        
                                                
                        % Check if any output relation should be resolved
                        % and perform the substitution
                        [template.nodes.data{2}.G, resolveStr] = ...
                            resolveOutputRelations(template.nodes.data{2}.G);
                        
                        % Check if all outputs are available, in which case
                        % template must be modified and made complete.
                        if allOutputsAvailable(template.nodes.data{2}.G)
                            
                            % Modify template to mark it as complete
                            template = makeTemplateComplete(template,method);
                            
                        else
                           
                            % If not all but some outputs were computed,
                            % regenerate the header and the solution, to
                            % avoid requesting output variables that are
                            % already available
                            if ~isempty(results)
                                template.nodes.data{2}.header = writeProblemStatement(...
                                    template.nodes.data{2}.analysisType,...
                                    template.nodes.data{2}.analysisModifier,...
                                    template.nodes.data{2}.G);
                                template.nodes.data{2}.solution = [];
                                template.nodes.data{2}.G_SVG = generate_G_SVG(...
                                    template.nodes.data{2}.G,...
                                    template.nodes.data{2}.header,...
                                    template.nodes.data{2}.solution);
                            end
                            
                        end
                        
                    end
                    
                otherwise
                    
            end
                  
        end
        
        
    case   {'FundamentalKirchhoffLaws',...
            'KirchhoffLaws',...
            'SolveTwoNodes',...
            'SolveSingleLoop',...
            'VoltageDivider',...
            'CurrentDivider',...
            'Millman',...
            'SimplifiedNodalAnalysis'}
        
        switch upper(analysisModifier)
            case {'SOLVE','SOLVE_KL'}
                switch upper(analysisType)
                    case {'.DC','.AC'}
                        if(~isempty(G_))
                            
                            % Get here if application of method was successful: must copy
                            % results into template.
                            % Populate template with solution results
                            
                            % Save initial circuit (but this will not be
                            % plotted, so do not generate the SVG code for
                            % circuit diagram export to HTML)
                            template.nodes.data{2}.G = currentG;
                            
                            % Save all results for later processing. Note
                            % that all elements in resval (desired outputs)
                            % are available after application of the
                            % methods in this case, except posssibly some
                            % outputs that were predetermined by some
                            % earlier method as a relation. These relations
                            % will be resolved below
                            val = getVal(template.nodes.data{2}.G);
                            for ii = 1:length(results)
                                if ~isempty(results{ii})
                                    [idx,isfinal] = findOutputIndex(template.nodes.data{2}.G,results{ii});
                                    if isfinal % This check must always return true for this methods
                                        template.nodes.data{2}.G.output{idx}.resultAvailable = true;
                                        template.nodes.data{2}.G.output{idx}.(val)= results{ii}.value;
                                    else
                                        % We should never get here, this is an
                                        % exception
                                        error('Bug: result is available, but not in final format');
                                    end
                                end
                            end
                            
                            % Check if any output relation should be resolved
                            % and perform the substitution
                            [template.nodes.data{2}.G, resolveStr] = ...
                                resolveOutputRelations(template.nodes.data{2}.G);
                            
                            % If some output relation was resolved, add
                            % corresponding typeset steps to solution
                            if ~isempty(resolveStr)
                                if iscell(G_)
                                    solution_{end} = [solution_{end}(:); resolveStr(:)];
                                else
                                    solution_ = [solution_(:); resolveStr(:)];                                    
                                end
                            end
                            
                            % Solution steps go in the (unique) edge of the template
                            template.edges.data{1}.G_step = G_ ;
                            template.edges.data{1}.header_step =header_;
                            template.edges.data{1}.solution_step = solution_;
                            template.edges.data{1}.G_step_SVG = generate_G_SVG(G_,header_,solution_);

                            % Modify template to mark it as complete
                            template = makeTemplateComplete(template,method);
                            
                            
                        end
                        
                    otherwise
                end
            otherwise
        end
        
    case   {'ModifiedNodalAnalysis','MNA_Formulation','MNA_DCFormulation'}
        
        switch upper(analysisModifier)
            case {'SOLVE','MNA'}
                switch upper(analysisType)
                    case {'.DC','.AC','.LTI'}
                        if(~isempty(G_))
                            
                            % Get here if application of method was successful: must copy
                            % results into template.
                            % Populate template with solution results
                            
                            % Save initial circuit (but this will not be
                            % plotted, so do not generate the SVG code for
                            % circuit diagram export to HTML)
                            template.nodes.data{2}.G = currentG;
                            
                            % Save all results for later processing. Note
                            % that all elements in resval (desired outputs)
                            % are available after application of the
                            % methods in this case, except posssibly some
                            % outputs that were predetermined by some
                            % earlier method as a relation. These relations
                            % will be resolved below
                            val = getVal(template.nodes.data{2}.G);
                            for ii = 1:length(results)
                                if ~isempty(results{ii})
                                    [idx,isfinal] = findOutputIndex(template.nodes.data{2}.G,results{ii});
                                    if isfinal % This check must always return true for this methods
                                        template.nodes.data{2}.G.output{idx}.resultAvailable = true;
                                        template.nodes.data{2}.G.output{idx}.(val)= results{ii}.value;
                                    else
                                        % We should never get here, this is an
                                        % exception
                                        error('Bug: result is available, but not in final format');
                                    end
                                end
                            end
                            
                            % Check if any output relation should be resolved
                            % and perform the substitution
                            [template.nodes.data{2}.G, resolveStr] = ...
                                resolveOutputRelations(template.nodes.data{2}.G);
                            
                            % If some output relation was resolved, add
                            % corresponding typeset steps to solution
                            if ~isempty(resolveStr)
                                if iscell(G_)
                                    solution_{end} = [solution_{end}(:); resolveStr(:)];
                                else
                                    solution_ = [solution_(:); resolveStr(:)];                                    
                                end
                            end
                            
                            % Solution steps go in the (unique) edge of the template
                            template.edges.data{1}.G_step = G_ ;
                            template.edges.data{1}.header_step =header_;
                            template.edges.data{1}.solution_step = solution_;
                            template.edges.data{1}.G_step_SVG = generate_G_SVG(G_,header_,solution_);

                            % Modify template to mark it as complete
                            template = makeTemplateComplete(template,method);
                            
                            
                        end
                        
                    otherwise
                end
            otherwise
        end
        
    otherwise
end

catch ME
    rethrow(ME)
end

return
end
