function [header,solution] = writeSolutionStep(type,mode,G,solutionData)
%
% Returns a cell array of strings (LaTeX) that are typeset before/after a
% circuit in its step-by-step solution. First argument denotes the type of
% operation that is being documented, second argument denotes the
% particular solution step. Third argument is the circuit on
% which the operation is being performed, and last argument is a
% cell array of structures storing any data that are required to typeset
% header and/or solution (see evalAllSeriesParallelReq.m)
%
% Author: Stefano Grivet-Talocia, DET, Politecnico di Torino
% Revised: September 14, 2020
% Last revised: Jan 5, 2021

% Handle missing arguments
if nargin<4
    solutionData = [];
end

% Initialize header and solution
header = {}; %#ok<*AGROW>
solution = {};

switch type
    
    case 'reduceResistance'
        %% Reduction methods (equivalent resistance) ----------------------
        % Define here common terms
        if isfield(G,'domain') && ismember(G.domain,{'phasor','Laplace'})
            RsEN = 'impedances';
            RsIT = 'impedenze';
            RIT = 'impedenza';
            REN = 'impedance';
            connIT = 'connesse';
            RRsEN = 'impedances';
            RRsIT = 'impedenze';
        else
            RsEN = 'resistors';
            RsIT = 'resistori';
            RIT = 'resistenza';
            REN = 'resistance';
            connIT = 'connessi';
            RRsEN = 'resistances';
            RRsIT = 'resistenze';
            
        end
        
        switch mode
            case 'highlight'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = ['We highlight with different colors groups of ' RsEN ' connected in parallel or in series'];
                else
                    header{end+1} = ['Evidenziamo con colori differenti i gruppi di ' RsIT ' ' connIT ' in serie e in parallelo'];
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                
            case 'highlightSeries'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = ['We highlight with different colors groups of ' RsEN ' connected in series'];
                else
                    header{end+1} = ['Evidenziamo con colori differenti i gruppi di ' RsIT ' ' connIT ' in serie'];
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                
            case 'highlightTriangle'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = ['We highlight a delta of ' RsEN];
                else
                    header{end+1} = ['Evidenziamo un triangolo di ' RsIT];
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                
            case 'highlightStar'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = ['We highlight a star of ' RsEN];
                else
                    header{end+1} = ['Evidenziamo una stella di ' RsIT];
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                
            case 'equivalentsStarDelta'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The equivalent group of ' RRsEN ' is'];
                else
                    solution{end+1} = ['Il gruppo di ' RRsIT ' equivalenti ' specialChar('egrave',G.circuitOptions)];
                    
                end
                for ii = 1 : length(solutionData)
                    color = getColorTable(solutionData{ii}.elemdata.highlight);
                    solution{end+1} = typesetColorContent(['\[' solutionData{ii}.Solution '\]'],color,G.circuitOptions);
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'equivalents'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The equivalent ' REN ' of each group is obtained as'];
                else
                    solution{end+1} = ['La ' RIT ' equivalente di ogni gruppo vale'];
                    
                end
                for ii = 1 : length(solutionData)
                    color = getColorTable(solutionData{ii}.elemdata.highlight);
                    solution{end+1} = typesetColorContent(['\[' solutionData{ii}.Solution '\]'],color,G.circuitOptions);
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'relocateControls'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The following variables can be eliminated before applying circuit reduction';
                else
                    solution{end+1} = 'Le variabili seguenti possono essere eliminate prima di effettuare la sostutizione';
                end
                
                for ii = 1:length(solutionData)
                    solution{end+1} = solutionData{ii};
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'afterReduction'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'The circuit after reduction is';
                else
                    header{end+1} = 'Dopo la riduzione si ottiene il circuito';
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                
            case 'complete'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'Circuit reduction is complete.';
                else
                    header{end+1} = ['La riduzione del circuito ' specialChar('egrave',G.circuitOptions) ' completa.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                %
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The equivalent ' REN ' is'];
                else
                    solution{end+1} = ['La ' RIT ' equivalente vale'];
                    
                end
                iReq = findElementsOfType(G,'R');
                if strcmp(G.circuitOptions.type,'numeric')
                    val = 'value';
                else
                    val = 'valueSym';
                end
                Req = G.edges.elemdata{iReq}.(val);
                [str, fullunit] = formatResult(Req,G.circuitOptions,'R');
                if isfield(G.edges.elemdata{iReq},'typesetOnlyNameInLabel')
                    strName = [G.edges.elem{iReq} '='];
                else
                    strName = '';
                end
                solution{end+1} = ['\[R_{eq} = ' strName str fullunit '\]'];
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                
            case 'irreducible'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'The circuit cannot be further simplified.';
                else
                    header{end+1} = ['Il circuito non pu' specialChar('ograve',G.circuitOptions) ' essere ulteriormente semplificato.'];
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                
            case 'resultAvailable'
                
                % Decode type of result
                switch [solutionData.outputType G.circuitOptions.language]
                    case 'REN'
                        elString = 'resistance';
                        elUnit = 'R';
                    case 'RIT'
                        elString = 'resistenza';
                        elUnit = 'R';
                    case 'GEN'
                        elString = 'conductance';
                        elUnit = 'G';
                    case 'GIT'
                        elString = 'conduttanza';
                        elUnit = 'G';
                    case 'ZEN'
                        elString = 'impedance';
                        elUnit = 'R';
                    case 'ZIT'
                        elString = 'impedenza';
                        elUnit = 'R';
                    case 'YEN'
                        elString = 'admittance';
                        elUnit = 'G';
                    case 'YIT'
                        elString = 'ammettenza';
                        elUnit = 'G';
                end
                
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'Circuit reduction is complete.';
                else
                    header{end+1} = ['La riduzione del circuito ' specialChar('egrave',G.circuitOptions) ' completa.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                %
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The equivalent ' elString ' is'];
                else
                    solution{end+1} = ['La ' elString ' equivalente vale'];
                    
                end
                if strcmp(G.circuitOptions.type,'numeric')
                    val = 'value';
                else
                    val = 'valueSym';
                end
                
                % Find the unique resistor left in circuit
                iReq = findElementsOfType(G,'R');
                if ~isempty(iReq)
                    % If a resistor is found, typeset also its name in the
                    % result string
                    Req = G.edges.elemdata{iReq}.(val);
                    if isfield(G.edges.elemdata{iReq},'typesetOnlyNameInLabel')
                        strName = [G.edges.elem{iReq}];
                        eq = '=';
                    else
                        strName = '';
                        eq = '';
                    end
                    if strcmp(elUnit,'R')
                        [str, fullunit] = formatResult(Req,G.circuitOptions,'R');
                    else
                        [str, fullunit] = formatResult(1/Req,G.circuitOptions,'G');
                        if ~isempty(strName)
                            strName = ['\frac{1}{' strName '}'];
                        end
                    end
                    solution{end+1} = ['\[' solutionData.outputType '_{eq} = ' strName eq str fullunit '\]'];
                else
                    % Get here if the result is either a short or an open
                    % circuit. Retrieve its value from the output field of
                    % circuit structure
                    [str, fullunit] = formatResult(G.output{1}.(val),G.circuitOptions,elUnit);
                    solution{end+1} = ['\[' solutionData.outputType '_{eq} = ' str fullunit '\]'];
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                
            otherwise
        end
        
    case 'sourceReduction'
        %% source Reduction ----------------------------------------------
        switch mode
            case 'highlight'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'Colored groups of sources can be replaced with a single equivalent source';
                else
                    header{end+1} = 'I gruppi di generatori evidenziati possono essere sostituiti con un unico generatore equivalente';
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'equivalents'
                solution{end+1} = typesetCirProblemTag('solstep','openresult', G.circuitOptions);
            case 'equivalentsWithCalculations'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The equivalent source of each group is obtained as';
                else
                    solution{end+1} = 'Il generatore equivalente di ogni gruppo vale';
                    
                end
                for ii = 1 : length(solutionData)
                    color = getColorTable(solutionData{ii}.elemdata.highlight);
                    solution{end+1} = typesetColorContent(['\[' solutionData{ii}.Solution '\]'],color,G.circuitOptions);
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'afterReduction'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'The following simplified circuit is obtained';
                else
                    header{end+1} = 'Si ottiene il seguente circuito semplificato';
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            otherwise
        end
        
        
    case 'KVLKCL'
        %% KVL/KCL --------------------------------------------------------
        switch mode
            case 'header'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = ['We find \(' solutionData.unknownString '\) using Kirchhoff''s laws.'];
                else
                    header{end+1} = ['Troviamo \(' solutionData.unknownString '\) tramite un sistema di equazioni di Kirchhoff.'];
                end
                header{end+1} =  typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'resultAvailable'
                
                nVars = length(G.output);
                
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = [typesetCirProblemTag('solstep','openresult',G.circuitOptions) 'The value' plural(nVars) ' of '];
                else
                    header{end+1} = [typesetCirProblemTag('solstep','openresult',G.circuitOptions) plural(nVars,'Il') ' valor' plural(nVars,'e') ' di '];
                end
                for ii = 1:nVars
                    header{end+1} = ['\(' G.output{ii}.label '\)' ...
                        resultSeparator(ii,nVars)];
                end
                header{end+1} = [' ' toBe(nVars,G.circuitOptions) ':']; % 'is' or 'are' for EN, 'egrave' o 'sono' per IT
                header = [header(:); typesetCirProblemTag('solstep','closeresult',G.circuitOptions)];
                
                solution{end+1} =  typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                
                val = getVal(G);
                for ii = 1:nVars
                    % [strX{ii},fullunit{ii}] = formatResult(G.output{ii}.value,...
                    [strX{ii},fullunit{ii}] = formatResult(G.output{ii}.(val),...
                        G.circuitOptions, getOutputFormat(G,ii)); %#ok<*AGROW>
                    solution{end+1} = ['\[' G.output{ii}.label ' = ' strX{ii} fullunit{ii} '\]']; %#ok<*SAGROW>
                end
                solution = [solution(:); typesetCirProblemTag('solstep','closeresult',G.circuitOptions)];
                
            otherwise
        end
        
    case 'MNA'
        %% MNA Formulation -----------------------------------------------
        switch mode
            case 'header'
                header{1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = ['The Modified Nodal Analysis system is constructed based on the following circuit, setting ' G.nodes.labels{G.gnd} ' as the ground (reference) node.'];
                    if solutionData.Iextra
                        header{end+1} = 'A short circuit is added in series to each element requiring its current to be present in the MNA variables (e.g. since a control current of a dependent source).';
                    end
                else
                    header{end+1} = ['Scriviamo il sistema nodale modificato con riferimento al circuito seguente, utilizando il nodo ' G.nodes.labels{G.gnd} ' come riferimento.'];
                    if solutionData.Iextra
                        header{end+1} = 'Un cortocircuito viene inserito in serie agli elementi che richiedono esplicitamente che la corrente sia presente nelle variabili MNA (ad esempio in quanto corrente pilotante di un generatore dipendente).';
                    end
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,solutionData.circuitDataForHeader);
            case 'Xvars'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                %
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The MNA variables are collected in vector';
                else
                    solution{end+1} = 'Le variabili del sistema MNA sono raccolte nel vettore';
                end
                solution{end+1} = '\(\mathbf{x} = \left(';
                solution{end+1} = typeList(solutionData.xLabels,',');
                solution{end+1} = '\right)^\mathsf{T}\)';
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = [' where \(' nodal_label(G) '_{\vartheta}\) denotes the voltage of node \((\vartheta)\) with respect to the ground'];
                    if length(solutionData.xLabels) > G.n-1
                        solution{end+1} = [' and \(' typeList(solutionData.xLabels(G.n:end),',') '\) '];
                        if length(solutionData.xLabels) == G.n
                            solution{end+1} = 'is an additional current through the element in the circuit that is not voltage-controlled';
                        else
                            solution{end+1} = 'are additional currents through elements that are not voltage-controlled';
                        end
                    end
                else
                    solution{end+1} = [' dove \(' nodal_label(G) '_{\vartheta}\) indica la tensione del nodo \((\vartheta)\) rispetto al nodo di riferimento'];
                    if length(solutionData.xLabels) > G.n-1
                        solution{end+1} = [' e \(' typeList(solutionData.xLabels(G.n:end),',') '\) '];
                        if length(solutionData.xLabels) == G.n
                            solution{end+1} = [specialChar('egrave',G.circuitOptions) ' la corrente che attraversa l''elemento del circuito non controllato in tensione'];
                        else
                            solution{end+1} = 'sono le correnti aggiuntive degli elementi non controllati in tensione';
                        end
                    end
                end
                solution{end} = [solution{end} '.'];
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'sources'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if isempty(solutionData.UUnames) % Handle the case of no sources
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = 'There are no active independent sources in the circuit, so that the MNA source term is ';
                    else
                        solution{end+1} = 'Non ci sono generatori indipendenti attivi nel circuito, quindi il termine noto del sistema MNA vale ';
                    end
                    solution{end+1} = '\(\mathbf{b} = \mathbf{0}\).';
                else
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = 'The independent sources are collected in vector';
                    else
                        solution{end+1} = 'I generatori indipendenti sono raccolti nel vettore';
                    end
                    solution{end+1} = ['\[\mathbf{u} = ' solutionData.UUnames solutionData.UUvalsUnits '\]'];
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'outputs'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The output variables to be computed are collected in vector';
                else
                    solution{end+1} = 'Le variabili di uscita da calcolare sono raccolte nel vettore';
                end
                solution{end+1} = '\(\mathbf{y} = \left(';
                solution{end+1} = typeList(solutionData.outLabels,',');
                if solutionData.nVars == 1
                    solution{end+1} = '\right)\).';
                else
                    solution{end+1} = '\right)^\mathsf{T}\).';
                end
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'These variables can be expressed in terms of the MNA variables as \(\mathbf{y} = \mathbf{L} \mathbf{x} \), where';
                else
                    solution{end+1} = 'Queste variabili possono essere espresse in funzione delle variabili MNA come \(\mathbf{y} = \mathbf{L} \mathbf{x} \), dove';
                end
                solution{end+1} = '\[\mathbf{L} = ';
                tmpSym = fixLaTeX(latex(solutionData.LLsym));
                tmpNum = formatResult(solutionData.LL,G.circuitOptions,'',-1);
                solution{end+1} = tmpSym;
                if ~strcmp(tmpSym(~isspace(tmpSym)),tmpNum(~isspace(tmpNum)))
                    solution{end+1} = ['=' tmpNum];
                end
                solution{end+1} = '\]';
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'matrices'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if isempty(solutionData.UUnames)
                    rhs = '\mathbf{b}';
                else
                    rhs = '\mathbf{B} \mathbf{u}';
                end
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The MNA system \(\mathbf{G} \mathbf{x} = ' rhs '\) is written by stamping, obtaining'];
                else
                    solution{end+1} = ['Il sistema MNA ' specialChar('egrave',G.circuitOptions) ...
                        ' \(\mathbf{G} \mathbf{x} = ' rhs '\), con le matrici ottenute per ispezione mediante stamping'];
                end
                %
                solution{end+1} = '\[\mathbf{G} = ';
                solution{end+1} = fixLaTeX(latex(solutionData.GGsym));
                solution{end+1} = ['=' formatResult(solutionData.GG,G.circuitOptions,'',-1)];
                solution{end+1} = '\]';
                solution{end+1} = '';
                %
                if ~isempty(solutionData.UUnames)
                    solution{end+1} = '\[\mathbf{B} \mathbf{u} = ';
                    solution{end+1} = [fixLaTeX(latex(solutionData.BBsym)) solutionData.UUnames '='];
                    if strcmp(G.circuitOptions.type,'numeric')
                        if isscalar(solutionData.UU)
                            pre = ' \left( ';
                            post = ' \right) ';
                        else
                            pre = '';
                            post = '';
                        end
                        solution{end+1} = [formatResult(solutionData.BB,G.circuitOptions,'',-1) ...
                            pre formatResult(solutionData.UU,G.circuitOptions,'',-1) post '='];
                    end
                    solution{end+1} = [formatResult(solutionData.BB*solutionData.UU,G.circuitOptions,'',-1) '\]'];
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'matrices_full'
                if isempty(solutionData.UUnames)
                    rhs = '\mathbf{b}';
                else
                    rhs = '\mathbf{B} \mathbf{u}';
                end
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The MNA system \(\mathbf{G} \mathbf{x} + \mathbf{C} \dfrac{d\mathbf{x}}{dt} = ' rhs '\) is written by stamping, obtaining'];
                else
                    solution{end+1} = ['Il sistema MNA ' specialChar('egrave',G.circuitOptions) ...
                        ' \(\mathbf{G} \mathbf{x} + \mathbf{C} \dfrac{d\mathbf{x}}{dt} = ' rhs '\), con le matrici ottenute per ispezione mediante stamping'];
                end
                %
                solution{end+1} = '\[\mathbf{G} = ';
                solution{end+1} = fixLaTeX(latex(solutionData.GGsym));
                solution{end+1} = ['=' formatResult(solutionData.GG,G.circuitOptions,'',-1)];
                solution{end+1} = '\]';
                solution{end+1} = '';
                %
                solution{end+1} = '\[\mathbf{C} = ';
                solution{end+1} = fixLaTeX(latex(solutionData.CCsym));
                solution{end+1} = ['=' formatResult(solutionData.CC,G.circuitOptions,'',-1)];
                solution{end+1} = '\]';
                solution{end+1} = '';
                %
                if ~isempty(solutionData.UUnames)
                    solution{end+1} = '\[\mathbf{B} \mathbf{u} = ';
                    solution{end+1} = [fixLaTeX(latex(solutionData.BBsym)) solutionData.UUnames '='];
                    if strcmp(G.circuitOptions.type,'numeric')
                        if isscalar(solutionData.UU)
                            pre = ' \left( ';
                            post = ' \right) ';
                        else
                            pre = '';
                            post = '';
                        end
                        solution{end+1} = [formatResult(solutionData.BB,G.circuitOptions,'',-1) ...
                            pre formatResult(solutionData.UU,G.circuitOptions,'',-1) post '='];
                    end
                    solution{end+1} = [formatResult(solutionData.BB*solutionData.UU,G.circuitOptions,'',-1) '\]'];
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'Yfinal'
                if isempty(solutionData.UUnames)
                    rhs = '\mathbf{b}';
                else
                    rhs = '\mathbf{B} \mathbf{u}';
                end
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The solution of this system for the output variables is ';
                    solution{end+1} = ['\(\mathbf{y} = \mathbf{L} \mathbf{G}^{-1} ' rhs ' \), with'];
                else
                    solution{end+1} = 'La soluzione del sistema per le variabili di uscita vale ';
                    solution{end+1} = ['\(\mathbf{y} = \mathbf{L} \mathbf{G}^{-1} ' rhs ' \), con'];
                end
                %
                solution{end+1} = ['\[\mathbf{y} = ' solutionData.Ynames solutionData.YvalsUnits '\]'];
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'resultAvailable'
                if (isfield(solutionData,'UUnames') && isempty(solutionData.UUnames)) || isempty(findSources(G))
                    rhs = '\mathbf{b}';
                else
                    rhs = '\mathbf{B} \mathbf{u}';
                end
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = ['The MNA system is \(\mathbf{G} \mathbf{x} = ' rhs '\), where'];
                else
                    header{end+1} = ['Il sistema MNA ' specialChar('egrave',G.circuitOptions) ...
                        ' \(\mathbf{G} \mathbf{x} = ' rhs '\), con'];
                end
                header = [header(:); typesetCirProblemTag('solstep','closeresult',G.circuitOptions)];
                
                solution{end+1} =  typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                
                val = getVal(G);
                nVars = length(G.output);
                for ii = 1:nVars
                    if iscell(G.output{ii}.(val))
                        solution{end+1} = ['\[' G.output{ii}.label ' = \left(' ...
                            typeList(G.output{ii}.(val),',') '\right)^\mathsf{T} \]'];                        
                    else
                        solution{end+1} = ['\[' G.output{ii}.label ' = ' ...
                            formatResult(G.output{ii}.(val),G.circuitOptions,'',-1) '\]'];
                    end
                end
                solution = [solution(:); typesetCirProblemTag('solstep','closeresult',G.circuitOptions)];
            case 'resultAvailable_full'
                if (isfield(solutionData,'UUnames') && isempty(solutionData.UUnames)) || isempty(findSources(G))
                    rhs = '\mathbf{b}';
                else
                    rhs = '\mathbf{B} \mathbf{u}';
                end
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = ['The MNA system is \(\mathbf{G} \mathbf{x} + \mathbf{C} \dfrac{d\mathbf{x}}{dt} = ' rhs '\), where'];
                else
                    header{end+1} = ['Il sistema MNA ' specialChar('egrave',G.circuitOptions) ...
                        ' \(\mathbf{G} \mathbf{x} + \mathbf{C} \dfrac{d\mathbf{x}}{dt} = ' rhs '\), con'];
                end
                header = [header(:); typesetCirProblemTag('solstep','closeresult',G.circuitOptions)];
                
                solution{end+1} =  typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                
                val = getVal(G);
                nVars = length(G.output);
                for ii = 1:nVars
                    if iscell(G.output{ii}.(val))
                        solution{end+1} = ['\[' G.output{ii}.label ' = \left(' ...
                            typeList(G.output{ii}.(val),',') '\right)^\mathsf{T} \]'];                        
                    else
                        solution{end+1} = ['\[' G.output{ii}.label ' = ' ...
                            formatResult(G.output{ii}.(val),G.circuitOptions,'',-1) '\]'];
                    end
                end
                solution = [solution(:); typesetCirProblemTag('solstep','closeresult',G.circuitOptions)];
            otherwise
        end
        
    case 'KirchhoffLaws'
        %% Kirchhoff Laws --------------------------------
        stepStr = '';
        if isfield(solutionData,'step') && ~isempty(solutionData.step)
            stepStr = [int2str(solutionData.step) '. '];
        end
        switch mode
            case 'header'                
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'We find the requested variables using Kirchhoff''s laws.';
                else
                    header{end+1} = 'Troviamo le incognite tramite un sistema di equazioni di Kirchhoff.';
                end
                header{end+1} =  typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'equations'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'elimVarsBegin'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = [stepStr 'We determine a minimal set of variables to be solved for, by eliminating the unnecessary variables. '];
                    solution{end+1} = 'Elimination is performed through characteristic equations of all elements and through application of trivial KCL/KVL equations resulting from series or parallel connections.';
                else
                    solution{end+1} = [stepStr 'Si determina un insieme minimale di variabili da utilizzare, eliminando le variabili non necessarie, '];
                    solution{end+1} = 'sfruttando le caratteristiche degli elementi e l''applicazione di KCL/KVL elementari risultanti da connessioni serie/parallelo.';
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'coupledInductors'
                if ~isempty(solutionData)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = 'The characteristics of the coupled inductors are stated below and will be used to eliminate the corresponding branch voltages';
                    else
                        solution{end+1} = 'Le caratteristiche degli induttori accoppiati sono riportate di seguito, e saranno usate per eliminare le tensioni esprimendole in funzione delle correnti';
                    end                    
                    solution = [solution(:); solutionData(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end            
            case 'elimVars'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                for ii = 1:length(solutionData)
                    if strcmp(G.circuitOptions.language,'EN')
                        if strcmpi(solutionData(ii).connection,'parallel')
                            connection = 'parallel';
                            varType = 'voltage';
                        else
                            connection = 'series';
                            varType = 'current';
                        end
                        solution{end+1} = ['The elements ' solutionData(ii).elements];
                        solution{end+1} = [' are connected in ' connection ' and share the common ' varType ' '];
                        solution{end+1} = [solutionData(ii).selectedVar '. '];
                    else
                        if strcmpi(solutionData(ii).connection,'parallel')
                            connection = 'parallelo';
                            varType = 'tensione';
                        else
                            connection = 'serie';
                            varType = 'corrente';
                        end
                        solution{end+1} = ['Gli elementi ' solutionData(ii).elements];
                        solution{end+1} = [' sono connessi in ' connection ' e condividono la stessa ' varType ' '];
                        solution{end+1} = [solutionData(ii).selectedVar '. '];
                    end
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'CSloop'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The controlled sources ' solutionData.vars ' control each other in a mutual feedback loop.'];
                    solution{end+1} = 'Therefore, the sets of controlling and controlled variables coincide and satisfy a set of homogeneous equations';
                    solution = [solution(:); solutionData.Eq(:)];
                    solution{end+1} = 'whose solution is identically vanishing';
                    solution = [solution(:); solutionData.Sol(:)];
                else
                    solution{end+1} = ['I generatori dipendenti ' solutionData.vars ' controllano l''un l''altro.'];
                    solution{end+1} = 'Si ha quindi che gli insiemi di variabili pilotate e pilotanti coincidono e soddisfano un sistema di equazioni omogenee';
                    solution = [solution(:); solutionData.Eq(:)];
                    solution{end+1} = ['la cui soluzione ' toBe(1,G.circuitOptions) ' identicamente nulla'];
                    solution = [solution(:); solutionData.Sol(:)];
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'CS'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = 'Exploiting the characteristics of the controlled sources leads to';
                    else
                        solution{end+1} = 'Utilizzando le caratteristiche dei generatori dipendenti si ottiene';
                    end                    
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'Status'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = 'The following table summarizes the role of each circuit variable';
                    else
                        solution{end+1} = 'La tabella seguente specifica il ruolo delle variabili del circuito';
                    end                    
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'elimVarsEnd'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if solutionData.nEQs > 0
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = ['The remaining unknown variables are ' solutionData.vars ', '];
                        solution{end+1} = ['therefore we need to write ' int2str(solutionData.nEQs) ' independent KVL and KCL equations.'];
                        solution{end+1} = 'The equations are formulated below and graphically annotated in the circuit diagram, using the same color.';
                    else
                        solution{end+1} = ['Rimangono da determinare le variabili incognite ' solutionData.vars ', '];
                        solution{end+1} = ['per cui si dovranno scrivere ' int2str(solutionData.nEQs) ' KVL e KCL indipendenti.'];
                        solution{end+1} = 'Le equazioni sono formulate di seguito e annotate graficamente nel circuito con lo stesso colore.';
                    end
                else
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = 'No KCL or KVL equations are needed, since all requested variables can be computed by inspection.';
                    else
                        solution{end+1} = 'Non sono necessarie equazioni di Kirchhoff in quanto tutte le variabili richieste possono essere calcolare direttamente.';
                    end
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'unnecessaryVoltages'
                if solutionData.nVars > 0
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = ['The voltage' plural(solutionData.nVars) ' across element' plural(solutionData.nVars) ' ' solutionData.vars ' ' toBe(solutionData.nVars,G.circuitOptions) '  not required.'];
                        solution{end+1} = [plural(solutionData.nVars,'This') ' element' plural(solutionData.nVars) ' will be excluded from any KVL path.'];
                    else
                        solution{end+1} = ['La tensione degli elementi ' solutionData.vars ' non ' toBe(solutionData.nVars,G.circuitOptions) ' richiesta o necessaria.'];
                        solution{end+1} = 'Non verranno quindi formulate equazioni alle maglie che attraversino questi elementi.';
                    end
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'unnecessaryCurrents'
                if solutionData.nVars > 0
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = ['The current' plural(solutionData.nVars) ' through element' plural(solutionData.nVars) ' ' solutionData.vars ' ' toBe(solutionData.nVars,G.circuitOptions) '  not required.'];
                        solution{end+1} = [plural(solutionData.nVars,'This') ' element' plural(solutionData.nVars) ' will be excluded from any KCL equation.'];
                    else
                        solution{end+1} = ['La corrente degli elementi ' solutionData.vars ' non ' toBe(solutionData.nVars,G.circuitOptions) ' richiesta o necessaria.'];
                        solution{end+1} = 'Non verranno quindi formulate equazioni KCL che utilizzino queste correnti.';
                    end
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'additionalVars'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = 'We can now evaluate the requested variables';
                    else
                        solution{end+1} = 'E'' ora possibile calcolare le variabili richieste';
                    end
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
                
        end
        
    case 'SNA'
        %% Simplified Nodal Analysis (SNA) --------------------------------
        stepStr = '';
        if ~isempty(solutionData.step)
            stepStr = [int2str(solutionData.step) '. '];
        end
        switch mode
            case 'header'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if solutionData.noGnd
                    if strcmp(G.circuitOptions.language,'EN')
                        header{end+1} = 'The (Simplified) Nodal Analysis system is constructed, defining the unknown nodal voltages with respect to the ground (reference) node.';
                    else
                        header{end+1} = 'Scriviamo il sistema nodale (semplificato), utilizando il nodo di massa (ground) come riferimento per le tensioni nodali.';
                    end
                else
                    if strcmp(G.circuitOptions.language,'EN')
                        header{end+1} = ['The (Simplified) Nodal Analysis system is constructed, setting ' G.nodes.labels{G.gnd} ' as the ground (reference) node.'];
                    else
                        header{end+1} = ['Scriviamo il sistema nodale (semplificato), utilizando il nodo ' G.nodes.labels{G.gnd} ' come riferimento per le tensioni nodali.'];
                    end
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'nodalVariables'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if ~isempty(solutionData.str)
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = [stepStr 'A system of KCL equations is written using the nodal variables '];
                    else
                        solution{end+1} = [stepStr 'Scriviamo un sistema di KCL in funzione delle tensioni nodali '];
                    end
                    solution = [solution(:); solutionData.str(:)];
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = 'corresponding to each of the highlighted nodes or supernodes (excluding the ground node)';
                    else
                        solution{end+1} = 'corrispondenti a ogni nodo o supernodo evidenziato nel circuito (escludendo il nodo di riferimento)';
                    end
                else
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = [stepStr 'All circuit nodes are connected by voltage sources, no KCL will be written.'];
                    else
                        solution{end+1} = [stepStr 'Tutti i nodi del circuito sono connessi da generatori di tensione, non viene formulata nessuna KCL.'];
                    end
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'mainKCLs'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'trafos'
                if ~isempty(solutionData.str)
                    n = length(solutionData.str);
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = [stepStr 'Let us first recall the characteristics of the ideal transformer' plural(n)];
                    else
                        solution{end+1} = [stepStr 'Ricordiamo le caratteristiche ' plural(n,'del') ' trasformator' plural(n,'e') ' ideal' plural(n,'e')];
                    end
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'extraEquations'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = [stepStr 'An additional equation is needed for each element that is not voltage-controlled, and whose current is required since either the control variable of a dependent source, or a variable to be computed. ' ...
                            'These characteristics are written in terms of the nodal voltages'];
                    else
                        solution{end+1} = [stepStr 'Aggiungiamo le equazioni caratteristiche degli elementi non controllati in tensione, la cui corrente ' specialChar('egrave',G.circuitOptions) ...
                            ' necessaria in quanto variabile di controllo di un generatore dipendente oppure una grandezza da calcolare. ' ...
                            'Queste caratteristiche sono espresse in funzione delle tensioni nodali'];
                    end
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'OAEquations'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = [stepStr 'The input voltage of OpAmps is zero: in terms of nodal variables we have'];
                    else
                        solution{end+1} = [stepStr 'La tensione di ingresso degli amplificatori operazionali ' specialChar('egrave',G.circuitOptions) ...
                            ' nulla. In termini delle tensioni nodali possiamo quindi scrivere'];
                    end
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'elimInternalNodalVariables'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = [stepStr 'The following nodal variables can be determined through KVL equations (dashed paths) as '];
                    else
                        solution{end+1} = [stepStr 'Le tensioni nodali seguenti possono essere determinate mediante KVL (linee tratteggiate)'];
                    end
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'solvedElimNodalVariables'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = [stepStr 'Replacing component values and solving leads to'];
                    else
                        solution{end+1} = [stepStr 'Sostituendo i valori dei componenti e risolvendo si ottiene'];
                    end
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'subsInternalNodalVariables'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = [stepStr 'Elimination of these variables from all equations leads to'];
                    else
                        solution{end+1} = [stepStr 'Eliminando queste variabili da tutte le equazioni produce il sistema'];
                    end
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'symbolicSystem'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = [stepStr 'Rearranging all coefficients'];
                    else
                        solution{end+1} = [stepStr 'Ordinando equazioni ed incognite'];
                    end
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'numericSystem'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = [stepStr 'and replacing component values'];
                    else
                        solution{end+1} = [stepStr 'e sostituendo i valori dei componenti'];
                    end
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'solutionSystem'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = [stepStr 'The solution is'];
                    else
                        solution{end+1} = [stepStr 'Risolvendo si ottiene'];
                    end
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'typesetComputedInternalNodalVariables'
                if ~isempty(solutionData.str)
                    solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                    if strcmp(G.circuitOptions.language,'EN')
                        solution{end+1} = [stepStr 'The previously eliminated node voltages are now fully determined as '];
                    else
                        solution{end+1} = [stepStr 'Le tensioni dei nodi precedentemente eliminate sono ora note '];
                    end
                    solution = [solution(:); solutionData.str(:)];
                    solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                end
            case 'solutionAvailable'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = [stepStr 'The variables of interest can now be found as'];
                else
                    solution{end+1} = [stepStr 'Le variabili di interesse possono ora essere calcolate'];
                end
                solution = [solution(:); solutionData.str(:)];
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            otherwise
        end
    case 'superposition'
        %% Superposition --------------------------------------------------
        switch mode
            case 'intro'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = 'Superposition Theorem.';
                    header{end+1} = ['We split the problem into ' int2str(solutionData) ' individual circuits.'];
                    header{end+1} =  'Each of these circuits includes a single active source, with all other sources switched off.';
                    header{end+1} =  'A dedicated superscript is used to label all variables in each circuit.';
                else
                    header{end+1} = 'Sovrapposizione degli effetti.';
                    header{end+1} = ['Si divide il problema in ' int2str(solutionData) ' circuiti separati.'];
                    header{end+1} =  'Ciascuno di questi circuiti include un singolo generatore, con tutti gli altri generatori spenti.';
                    header{end+1} =  'Le variabili di questi circuiti sono etichettate con un apice.';
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'switchOff'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = ['Superposition circuit n.' int2str(solutionData)];
                else
                    header{end+1} = ['Sovrapposizione degli effetti, circuito n.' int2str(solutionData)];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'collection'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = 'We now apply Superposition Theorem by adding individual contributions';
                else
                    header{end+1} = 'Applichiamo ora il Teorema di Sovrapposizione degli effetti, sommando i vari contributi';
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                
            otherwise
        end
        
    case 'circuit_reduction'
        switch mode
            case 'intro'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = 'Circuit Reduction.';
                    header{end+1} = 'The circuit is split into two well-defined one-ports connected by two interface nodes (highlighted).';
                    header{end+1} =  'The first one-port includes all variables to be computed and is left unchanged.';
                    header{end+1} =  'The second one-port will be replaced by a simpler equivalent circuit.';
                    header{end+1} =  'The edges of the one-port to be simplified are highlighted.';
                    if ~isempty(solutionData)
                        header{end+1} = '<span class="clickMe" onclick=''document.getElementById("myModal").style.display = "block";''>Click here</span> to check all possible circuit partitions.';
                        header{end+1} = '<div id="myModal" class="modal-container">';
                        header{end+1} = '<div class="modal-content">';
                        header{end+1} = '<span class="closeMe" onclick=''document.getElementById("myModal").style.display = "none";''>&times;</span>';
                        header{end+1} = ['<iframe src="' solutionData '" class="modal-content-iframe"></iframe>'];
                        header{end+1} = '</div></div>';
                    end
                else
                    header{end+1} = 'Semplificazione del circuito tramite equivalente.';
                    header{end+1} = 'Si divide il circuito in due bipoli connessi dai due nodi evidenziati.';
                    header{end+1} =  ['Il primo bipolo include le variabili da calcolare e non sar' specialChar('agrave',G.circuitOptions) ' modificato.'];
                    header{end+1} =  ['Il secondo bipolo sar' specialChar('agrave',G.circuitOptions) ' sostituito da un circuito equivalente.'];
                    header{end+1} =  'Gli elementi del bipolo da semplificare sono evidenziati.';
                    if ~isempty(solutionData)
                        header{end+1} = '<span class="clickMe" onclick=''document.getElementById("myModal").style.display = "block";''>Clicca qui</span> per verificare tutte le possibili partizioni del circuito.';
                        header{end+1} = '<div id="myModal" class="modal-container">';
                        header{end+1} = '<div class="modal-content">';
                        header{end+1} = '<span class="closeMe" onclick=''document.getElementById("myModal").style.display = "none";''>&times;</span>';
                        header{end+1} = ['<iframe src="' solutionData '" class="modal-content-iframe"></iframe>'];
                        header{end+1} = '</div></div>';                        
                    end
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'one-port-A'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = ['This one-port will not be modified. The equivalent to be determined below will replace the port defined by nodes \(' solutionData{1} '\) and \(' solutionData{2} '\).'];
                else
                    header{end+1} = ['Questo bipolo non sar' specialChar('agrave',G.circuitOptions) ' modificato. L''equivalente da determinare rimpiazzer' specialChar('agrave',G.circuitOptions) ' la porta definita dai nodi \(' solutionData{1} '\) e \(' solutionData{2} '\).'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'one-port-B' % Currently unused
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = 'This one-port will be replaced by its equivalent circuit.';
                else
                    header{end+1} = ['Questo bipolo sar' specialChar('agrave',G.circuitOptions) ' sostituito da un circuito equivalente.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'resultAvailable'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                solutionData(1) = upper(solutionData(1));
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = ['After reconnecting the ' solutionData ' equivalent, we obtain the following circuit:'];
                else
                    header{end+1} = ['Riconnettendo l''equivalente di ' solutionData ' otteniamo il circuito seguente:'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'allSolutions'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = ['Possible split n.' int2str(solutionData) ' of the original circuit.'];
                    if solutionData==1
                        header{end+1} = 'This is the circuit partitioning selected by autoCircuits.';
                    end
                else
                    header{end+1} = ['Possibile partizione n.' int2str(solutionData) ' del circuito originale.'];
                    if solutionData==1
                        header{end+1} = ['Questa ' specialChar('egrave',G.circuitOptions) ' la partizione automaticamente selezionata da autoCircuits.'];
                    end
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
        end
    case 'voltageDivider'
        %% Voltage Divider ------------------------------------------------
        switch mode
            case 'header'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'We apply the voltage divider rule';
                else
                    header{end+1} = 'Si applica la regola del partitore di tensione';
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
        end
        
    case 'currentDivider'
        %% Current Divider ------------------------------------------------
        switch mode
            case 'header'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'We apply the current divider rule';
                else
                    header{end+1} = 'Si applica la regola del partitore di corrente';
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
        end
        
    case 'twoNodes'
        %% Two-Nodes circuits ---------------------------------------------
        switch mode
            case 'header'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'We evaluate the voltage across the two circuit nodes';
                else
                    header{end+1} = 'Si calcola la tensione ai capi dei due nodi del circuito';
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'otherVars'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The other variables are easily found from the computed voltage as';
                else
                    solution{end+1} = 'Le altre variabili si ottengono facilmente dalla tensione appena calcolata';
                    
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
        end
        
    case 'singleLoop'
        %% Single Loop circuits -------------------------------------------
        switch mode
            case 'header'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'We evaluate the current through the single loop of the circuit';
                else
                    header{end+1} = 'Si calcola la corrente nell''unica maglia del circuito';
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'otherVars'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The other variables are easily found from the computed current as';
                else
                    solution{end+1} = 'Le altre variabili si ottengono facilmente dalla corrente appena calcolata';
                    
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
        end
        
    case 'Millman'
        %% Millman --------------------------------------------------------
        switch mode
            case 'headerWithCircuit'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'We apply Millman''s Theorem';
                else
                    header{end+1} = 'Applichiamo il Teorema di Millman';
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'header'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'We apply Millman''s Theorem';
                else
                    header{end+1} = 'Applichiamo il Teorema di Millman';
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'otherVars'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The other variables are easily found from the computed voltage as';
                else
                    solution{end+1} = 'Le altre variabili si ottengono facilmente dalla tensione appena calcolata';
                    
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
        end
    case 'basicTheveninToNorton'
        %% Basic Thevenin to Norton source conversion ---------------------
        switch mode
            case 'highlight'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'We highlight with a different color a basic Thevenin circuit';
                else
                    header{end+1} = 'Evidenziamo con un colore differente un circuito elementare di Thevenin';
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'equivalents'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The equivalent Norton (short-circuit current) source is computed as';
                else
                    solution{end+1} = 'Il generatore equivalente di Norton (corrente di corto-circuito) vale';
                    
                end
                color = getColorTable(solutionData.elemdata.highlight);
                solution{end+1} = typesetColorContent(solutionData.Solution,color,G.circuitOptions);
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'afterReduction'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'The circuit after source transformation is';
                else
                    header{end+1} = 'Dopo la trasformazione Thevenin-Norton si ottiene il circuito';
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                
        end
    case 'basicNortonToThevenin'
        %% Basic Norton to Thevenin source conversion ---------------------
        switch mode
            case 'highlight'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'We highlight with a different color a basic Norton circuit';
                else
                    header{end+1} = 'Evidenziamo con un colore differente un circuito elementare di Norton';
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'equivalents'
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The equivalent Thevenin (open-circuit voltage) source is computed as';
                else
                    solution{end+1} = 'Il generatore equivalente di Thevenin (tensione a vuoto) vale';
                    
                end
                color = getColorTable(solutionData.elemdata.highlight);
                solution{end+1} = typesetColorContent(solutionData.Solution,color,G.circuitOptions);
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'afterReduction'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'The circuit after source transformation is';
                else
                    header{end+1} = 'Dopo la trasformazione Norton-Thevenin si ottiene il circuito';
                    
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                
        end
        
    case 'TheveninByReduction'
        %% Thevenin equivalent obtained by reduction ----------------------
        switch mode
            case 'resultAvailable'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'The Thevenin equivalent circuit is now available.';
                else
                    header{end+1} = ['Il circuito equivalente di Thevenin ' specialChar('egrave',G.circuitOptions) ' disponibile.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                %
                val = getVal(G);
                %
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The equivalent resistance is';
                else
                    solution{end+1} = 'La resistenza equivalente vale';
                end
                % Retrieve index of resistor whose value is related
                % to the equivalent Thevenin voltage
                idx = solutionData(1);
                if idx
                    resLabel = G.edges.elem{idx};
                    [str, fullunit] = formatResult(G.output{1}.parts{1}.(val),G.circuitOptions,'R');
                    solution{end+1} = ['\[' G.output{1}.parts{1}.label ' = ' resLabel ' = ' str fullunit '\]'];
                else
                    [str, fullunit] = formatResult(G.output{1}.parts{1}.(val),G.circuitOptions,'R');
                    solution{end+1} = ['\[' G.output{1}.parts{1}.label ' = ' str fullunit '\]'];
                end
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The open-circuit voltage is';
                else
                    solution{end+1} = 'La tensione a vuoto vale';
                end
                % Retrieve index of voltage source whose value is related
                % to the equivalent Thevenin voltage
                idx = solutionData(2);
                if idx
                    if idx<0
                        op = '-';
                    else
                        op = '';
                    end
                    sourceLabel = G.edges.elemdata{abs(idx)}.voltageLabel;
                    [str, fullunit] = formatResult(G.output{1}.parts{2}.(val),G.circuitOptions,'V');
                    solution{end+1} = ['\[' G.output{1}.parts{2}.label ' = ' op sourceLabel ' = ' str fullunit '\]'];
                else
                    [str, fullunit] = formatResult(G.output{1}.parts{2}.(val),G.circuitOptions,'V');
                    solution{end+1} = ['\[' G.output{1}.parts{2}.label ' = ' str fullunit '\]'];
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
        end
        
    case 'NortonByReduction'
        %% Norton equivalent obtained by reduction ------------------------
        switch mode
            case 'resultAvailable'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'The Norton equivalent circuit is now available.';
                else
                    header{end+1} = ['Il circuito equivalente di Norton ' specialChar('egrave',G.circuitOptions) ' disponibile.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                %
                val = getVal(G);
                %
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The equivalent conductance is';
                else
                    solution{end+1} = 'La conduttanza equivalente vale';
                end
                % Retrieve index of resistor whose value is related
                % to the equivalent Thevenin voltage
                idx = solutionData(1);
                if idx
                    resLabel = G.edges.elem{idx};
                    [str, fullunit] = formatResult(G.output{1}.parts{1}.(val),G.circuitOptions,'G');
                    solution{end+1} = ['\[' G.output{1}.parts{1}.label ' = \frac{1}{' resLabel '} = ' str fullunit '\]'];
                else
                    [str, fullunit] = formatResult(G.output{1}.parts{1}.(val),G.circuitOptions,'G');
                    solution{end+1} = ['\[' G.output{1}.parts{1}.label ' = ' str fullunit '\]'];
                end
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The short-circuit current is';
                else
                    solution{end+1} = 'La corrente di cortocircuito vale';
                end
                % Retrieve index of current source whose value is related
                % to the equivalent Thevenin voltage
                idx = solutionData(2);
                if idx
                    if idx<0
                        op = '-';
                    else
                        op = '';
                    end
                    sourceLabel = G.edges.elemdata{abs(idx)}.currentLabel;
                    [str, fullunit] = formatResult(G.output{1}.parts{2}.(val),G.circuitOptions,'I');
                    solution{end+1} = ['\[' G.output{1}.parts{2}.label ' = ' op sourceLabel ' = ' str fullunit '\]'];
                else
                    [str, fullunit] = formatResult(G.output{1}.parts{2}.(val),G.circuitOptions,'I');
                    solution{end+1} = ['\[' G.output{1}.parts{2}.label ' = ' str fullunit '\]'];
                end
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
        end
        
    case 'thevenin_2steps'
        %% TheveninEquivalent_TwoStep -------------------------------------
        if isfield(G,'domain') && strcmpi(G.domain,'phasor')
            REN = 'impedance';
            RIT = 'impedenza';
        else
            REN = 'resistance';
            RIT = 'resistenza';
        end
        switch mode
            case 'intro'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = 'Two-step Thevenin equivalent calculation.';
                    header{end+1} = 'We split the problem into two individual circuits: ';
                    header{end+1} = ['one for equivalent ' REN ' calculation (with all independent sources switched off), '];
                    header{end+1} = 'and one for open-circuit voltage calculation. ';
                    %header{end+1} =  'A dedicated superscript is used to label all variables in each circuit.';
                else
                    header{end+1} = 'Calcolo del circuito equivalente di Thevenin in due passi.';
                    header{end+1} = 'Si divide il problema in due circuiti separati: ';
                    header{end+1} = ['il primo per il calcolo della ' RIT ' equivalente (con tutti i generatori indipendenti spenti), '];
                    header{end+1} = 'il secondo per il calcolo della tensione a vuoto. ';
                    %header{end+1} =  'Le variabili di questi circuiti sono etichettate con un apice.';
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'Req'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = ['Circuit for determination of equivalent ' REN '.'];
                else
                    header{end+1} = ['Circuito per il calcolo della ' RIT ' equivalente.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'Veq'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = 'Circuit for determination of open-circuit voltage.';
                else
                    header{end+1} = 'Circuito per il calcolo della tensione a vuoto.';
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'collection'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = ['Both equivalent ' REN ' and open-circuit voltage have been computed.'];
                else
                    header{end+1} = ['La ' RIT ' equivalente e la tensione a vuoto sono state calcolate.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'resultAvailable'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'The Thevenin equivalent circuit is now available.';
                else
                    header{end+1} = ['Il circuito equivalente di Thevenin ' specialChar('egrave',G.circuitOptions) ' disponibile.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                %
                val = getVal(G);
                %
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The equivalent ' REN ' is'];
                else
                    solution{end+1} = ['La ' RIT ' equivalente vale'];
                end
                [str, fullunit] = formatResult(G.output{1}.parts{1}.(val),G.circuitOptions,'R');
                solution{end+1} = ['\[' G.output{1}.parts{1}.label ' = ' str fullunit '\]'];
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The open-circuit voltage is';
                else
                    solution{end+1} = 'La tensione a vuoto vale';
                end
                [str, fullunit] = formatResult(G.output{1}.parts{2}.(val),G.circuitOptions,'V');
                solution{end+1} = ['\[' G.output{1}.parts{2}.label ' = ' str fullunit '\]'];
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
        end
        
    case 'norton_2steps'
        %% NortonEquivalent_TwoStep -------------------------------------
        if isfield(G,'domain') && strcmpi(G.domain,'phasor')
            GEN = 'admittance';
            GIT = 'ammettenza';
        else
            GEN = 'conductance';
            GIT = 'conduttanza';
        end
        switch mode
            case 'intro'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = 'Two-step Norton equivalent calculation.';
                    header{end+1} = 'We split the problem into two individual circuits: ';
                    header{end+1} = ['one for equivalent ' GEN ' calculation (with all independent sources switched off), '];
                    header{end+1} = 'and one for short-circuit current calculation. ';
                    %header{end+1} =  'A dedicated superscript is used to label all variables in each circuit.';
                else
                    header{end+1} = 'Calcolo del circuito equivalente di Norton in due passi.';
                    header{end+1} = 'Si divide il problema in due circuiti separati: ';
                    header{end+1} = ['il primo per il calcolo della ' GIT ' equivalente (con tutti i generatori indipendenti spenti), '];
                    header{end+1} = 'il secondo per il calcolo della corrente di corto-circuito. ';
                    %header{end+1} =  'Le variabili di questi circuiti sono etichettate con un apice.';
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'Geq'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = ['Circuit for determination of equivalent ' GEN '.'];
                else
                    header{end+1} = ['Circuito per il calcolo della ' GIT ' equivalente.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'Ieq'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = 'Circuit for determination of short-circuit current.';
                else
                    header{end+1} = 'Circuito per il calcolo della corrente di corto-circuito.';
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
            case 'collection'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = ['Both equivalent ' GEN ' and short-circuit current have been computed.'];
                else
                    header{end+1} = ['La ' GIT ' equivalente e la corrente di corto-circuito sono state calcolate.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'resultAvailable'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'The Norton equivalent circuit is now available.';
                else
                    header{end+1} = ['Il circuito equivalente di Norton ' specialChar('egrave',G.circuitOptions) ' disponibile.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                %
                val = getVal(G);
                %
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The equivalent ' GEN ' is'];
                else
                    solution{end+1} = ['La ' GIT ' equivalente vale'];
                end
                [str, fullunit] = formatResult(G.output{1}.parts{1}.(val),G.circuitOptions,'G');
                solution{end+1} = ['\[' G.output{1}.parts{1}.label ' = ' str fullunit '\]'];
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The short-circuit current is';
                else
                    solution{end+1} = 'La corrente di corto-circuito vale';
                end
                [str, fullunit] = formatResult(G.output{1}.parts{2}.(val),G.circuitOptions,'I');
                solution{end+1} = ['\[' G.output{1}.parts{2}.label ' = ' str fullunit '\]'];
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
        end
        
    case 'theveninNorton_1step'
        %% Equivalents by external excitation (one-step): Thevenin, Norton, Req, Geq
        if isfield(G,'domain') && strcmpi(G.domain,'phasor')
            hat = '\hat';
            REN = 'impedance';
            RIT = 'impedenza';
            GEN = 'admittance';
            GIT = 'ammettenza';
            RR = 'Z';
            GG = 'Y';
        else
            hat = '';
            REN = 'resistance';
            RIT = 'resistenza';
            GEN = 'conductance';
            GIT = 'conduttanza';
            RR = 'R';
            GG = 'G';
        end
        switch mode
            case {'theveninaddSymSource','nortonaddSymSource'}
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    if strcmpi(solutionData.equivalentType,'Thevenin')
                        primal = 'current';
                        dual = 'voltage';
                        char_eq = ['\[' solutionData.outputName '= ' hat '{V}_{eq} + ' RR '_{eq} \cdot ' fixLaTeX(solutionData.sourceName) '\]'];
                    else
                        primal = 'voltage';
                        dual = 'current';
                        char_eq = ['\[' solutionData.outputName '= - ' hat '{I}_{eq} + ' GG '_{eq} \cdot ' fixLaTeX(solutionData.sourceName) '\]'];
                    end
                    header{end+1} = ['One-step ' solutionData.equivalentType ' equivalent calculation. '];
                    header{end+1} = ['The one-port circuit is excited by an external ' primal ' source \(' fixLaTeX(solutionData.sourceName) '\) (highlighted), '];
                    header{end+1} = ['and the corresponding ' dual ' \(' solutionData.outputName '\) is computed. '];
                    if isfield(solutionData,'remappedCtrlSources') && ~isempty(solutionData.remappedCtrlSources)
                        nRemapSources = length(solutionData.remappedCtrlSources);
                        header{end+1} = ['The controlled source' plural(nRemapSources) ' \(' ...
                            sprintf('%s, ',solutionData.remappedCtrlSources{1:end-1}) sprintf('%s',solutionData.remappedCtrlSources{end}) ...
                            '\) ' toBe(nRemapSources,G.circuitOptions) ...
                            ' redefined in terms of the new source current \(' solutionData.controlCurrentName '\).'];
                    end
                    solution{end+1} = ['The coefficients of the resulting characteristic equation ' char_eq ' will provide the desired equivalent.'];
                else
                    if strcmpi(solutionData.equivalentType,'Thevenin')
                        primal = 'corrente';
                        dual = 'tensione';
                        char_eq = ['\[' solutionData.outputName '= ' RR '_{eq} \cdot ' fixLaTeX(solutionData.sourceName) ' + ' hat '{V}_{eq}\]'];
                    else
                        primal = 'tensione';
                        dual = 'corrente';
                        char_eq = ['\[' solutionData.outputName '= ' GG '_{eq} \cdot ' fixLaTeX(solutionData.sourceName) ' - ' hat ' {I}_{eq}\]'];
                    end
                    header{end+1} = ['Calcolo del circuito equivalente di ' solutionData.equivalentType ' mediante definizione.'];
                    header{end+1} = ['Il bipolo ' specialChar('egrave',G.circuitOptions) ' eccitato da un generatore di ' primal ' di test \(' fixLaTeX(solutionData.sourceName) '\) (evidenziato), '];
                    header{end+1} = ['e si calcola la ' dual ' \(' solutionData.outputName '\) corrispondente. '];
                    if isfield(solutionData,'remappedCtrlSources') && ~isempty(solutionData.remappedCtrlSources)
                        nRemapSources = length(solutionData.remappedCtrlSources);
                        header{end+1} = [plural(nRemapSources,'Il') ' generator' plural(nRemapSources,'e') ' dipendent' plural(nRemapSources,'e') ' \(' ...
                            sprintf('%s, ',solutionData.remappedCtrlSources{1:end-1}) sprintf('%s',solutionData.remappedCtrlSources{end}) ...
                            '\) ' toBe(nRemapSources,G.circuitOptions) ...
                            ' ridefinit' plural(nRemapSources,'o') ' in funzione della corrente \(' solutionData.controlCurrentName '\) del nuovo generatore di test.'];
                    end
                    solution{end+1} = ['I coefficienti della caratteristica ottenuta ' char_eq ' forniranno l''equivalente desiderato.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case {'thevenincollection','nortoncollection'}
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmpi(solutionData.eqv_type,'thevenin')
                    char_eq = ['= ' RR '_{eq} \cdot ' solutionData.in_name ' + ' hat '{V}_{eq}'];
                    if strcmp(G.circuitOptions.language, 'EN')
                        header{end+1} = ['Equivalent ' REN ' and open-circuit voltage are now extracted from the coefficients of the equation relating the port variables.'];
                    else
                        header{end+1} = ['La ' RIT ' equivalente e la tensione a vuoto sono ora estratte dei coefficienti dell''equazione che lega le variabili di porta del bipolo.'];
                    end
                else
                    char_eq = ['= ' GG '_{eq} \cdot ' solutionData.in_name ' - ' hat '{I}_{eq}'];
                    if strcmp(G.circuitOptions.language, 'EN')
                        header{end+1} = ['Equivalent ' GEN ' and short-circuit current are now extracted from the coefficients of the equation relating the port variables.'];
                    else
                        header{end+1} = ['La ' GIT ' equivalente e la corrente di corto-circuito sono ora estratte dei coefficienti dell''equazione che lega le variabili di porta del bipolo.'];
                    end
                end
                %                 header{end+1} = ['\[' solutionData.out_name char_eq ' = ' fixLaTeX(latex(solutionData.char_eq)) ...
                %                     ' = ' fixLaTeX(myLaTeX(solutionData.char_eq)) '\]'];
%                header{end+1} = ['\[' solutionData.out_name char_eq ' = ' fixLaTeX(latex(simplify(solutionData.char_eq,'Steps',10))) ...
%                    ' = ' fixLaTeX(myLaTeX(simplify(solutionData.char_eq,'Steps',10))) '\]'];
                header{end+1} = ['\[' solutionData.out_name char_eq ...
                    ' = ' solutionData.char_eq '\]'];
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'theveninResultAvailable'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'The Thevenin equivalent circuit is now available.';
                else
                    header{end+1} = ['Il circuito equivalente di Thevenin ' specialChar('egrave',G.circuitOptions) ' disponibile.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                %
                val = getVal(G);
                %
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The equivalent ' REN ' is'];
                else
                    solution{end+1} = ['La ' RIT ' equivalente vale'];
                end
                [str, fullunit] = formatResult(G.output{1}.parts{1}.(val),G.circuitOptions,'R');
                solution{end+1} = ['\[' G.output{1}.parts{1}.label ' = ' str fullunit '\]'];
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The open-circuit voltage is';
                else
                    solution{end+1} = 'La tensione a vuoto vale';
                end
                [str, fullunit] = formatResult(G.output{1}.parts{2}.(val),G.circuitOptions,'V');
                solution{end+1} = ['\[' G.output{1}.parts{2}.label ' = ' str fullunit '\]'];
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case 'nortonResultAvailable'
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = 'The Norton equivalent circuit is now available.';
                else
                    header{end+1} = ['Il circuito equivalente di Norton ' specialChar('egrave',G.circuitOptions) ' disponibile.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                %
                val = getVal(G);
                %
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The equivalent ' GEN ' is'];
                else
                    solution{end+1} = ['La conduttanza ' GIT ' vale'];
                end
                [str, fullunit] = formatResult(G.output{1}.parts{1}.(val),G.circuitOptions,'G');
                solution{end+1} = ['\[' G.output{1}.parts{1}.label ' = ' str fullunit '\]'];
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = 'The short-circuit current is';
                else
                    solution{end+1} = 'La corrente di corto-circuito vale';
                end
                [str, fullunit] = formatResult(G.output{1}.parts{2}.(val),G.circuitOptions,'I');
                solution{end+1} = ['\[' G.output{1}.parts{2}.label ' = ' str fullunit '\]'];
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                
            case {'resistanceaddSymSource','conductanceaddSymSource'}
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    if strcmpi(solutionData.equivalentType,'Resistance')
                        primal = 'current';
                        dual = 'voltage';
                        ReqGeq = REN;
                        char_eq = ['\[' solutionData.outputName '= ' RR '_{eq} \cdot ' fixLaTeX(solutionData.sourceName) '\]'];
                    else
                        primal = 'voltage';
                        dual = 'current';
                        ReqGeq = GEN;
                        char_eq = ['\[' solutionData.outputName '= ' GG '_{eq} \cdot ' fixLaTeX(solutionData.sourceName) '\]'];
                    end
                    header{end+1} = ['One-step equivalent ' ReqGeq ' calculation. '];
                    header{end+1} = ['The one-port circuit is excited by an external ' primal ' source \(' fixLaTeX(solutionData.sourceName) '\) (highlighted), '];
                    header{end+1} = ['and the corresponding ' dual ' \(' solutionData.outputName '\) is computed. '];
                    if isfield(solutionData,'remappedCtrlSources') && ~isempty(solutionData.remappedCtrlSources)
                        nRemapSources = length(solutionData.remappedCtrlSources);
                        header{end+1} = ['The controlled source' plural(nRemapSources) ' \(' ...
                            sprintf('%s, ',solutionData.remappedCtrlSources{1:end-1}) sprintf('%s',solutionData.remappedCtrlSources{end}) ...
                            '\) ' toBe(nRemapSources,G.circuitOptions) ...
                            ' redefined in terms of the new source current \(' solutionData.controlCurrentName '\).'];
                    end
                    solution{end+1} = ['The coefficient of the resulting characteristic equation ' char_eq ' will provide the desired equivalent.'];
                else
                    if strcmpi(solutionData.equivalentType,'Resistance')
                        primal = 'corrente';
                        dual = 'tensione';
                        ReqGeq = RIT;
                        char_eq = ['\[' solutionData.outputName '= ' RR '_{eq} \cdot ' solutionData.sourceName '\]'];
                    else
                        primal = 'tensione';
                        dual = 'corrente';
                        ReqGeq = GIT;
                        char_eq = ['\[' solutionData.outputName '= ' GG '_{eq} \cdot ' solutionData.sourceName '\]'];
                    end
                    header{end+1} = ['Calcolo della ' ReqGeq ' equivalente mediante definizione.'];
                    header{end+1} = ['Il bipolo ' specialChar('egrave',G.circuitOptions) ' eccitato da un generatore di ' primal ' di test \(' solutionData.sourceName '\) (evidenziato), '];
                    header{end+1} = ['e si calcola la ' dual ' \(' solutionData.outputName '\) corrispondente. '];
                    if isfield(solutionData,'remappedCtrlSources') && ~isempty(solutionData.remappedCtrlSources)
                        nRemapSources = length(solutionData.remappedCtrlSources);
                        header{end+1} = [plural(nRemapSources,'Il') ' generator' plural(nRemapSources,'e') ' dipendent' plural(nRemapSources,'e') ' \(' ...
                            sprintf('%s, ',solutionData.remappedCtrlSources{1:end-1}) sprintf('%s',solutionData.remappedCtrlSources{end}) ...
                            '\) ' toBe(nRemapSources,G.circuitOptions) ...
                            ' ridefinit' plural(nRemapSources,'o') ' in funzione della corrente \(' solutionData.controlCurrentName '\) del nuovo generatore di test.'];
                    end
                    solution{end+1} = ['Il coefficiente della caratteristica ottenuta ' char_eq ' fornir' specialChar('agrave',G.circuitOptions) ' l''equivalente desiderato.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case {'resistancecollection','conductancecollection','impedancecollection','admittancecollection'}
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmpi(solutionData.eqv_type,'resistance') || strcmpi(solutionData.eqv_type,'impedance')
                    char_eq = ['= ' RR '_{eq} \cdot ' solutionData.in_name];
                    if strcmp(G.circuitOptions.language, 'EN')
                        header{end+1} = ['The equivalent ' REN ' is now extracted from the coefficient of the equation relating the port variables.'];
                    else
                        header{end+1} = ['La ' RIT ' equivalente ' specialChar('egrave',G.circuitOptions) ' ora estratta dal coefficiente dell''equazione che lega le variabili di porta del bipolo.'];
                    end
                else
                    char_eq = ['= ' GG '_{eq} \cdot ' solutionData.in_name];
                    if strcmp(G.circuitOptions.language, 'EN')
                        header{end+1} = ['The equivalent ' GEN ' is now extracted from the coefficient of the equation relating the port variables.'];
                    else
                        header{end+1} = ['La ' GIT ' equivalente ' specialChar('egrave',G.circuitOptions) ' ora estratta dal coefficiente dell''equazione che lega le variabili di porta del bipolo.'];
                    end
                end
                %                 header{end+1} = ['\[' solutionData.out_name char_eq ' = ' fixLaTeX(latex(solutionData.char_eq)) ...
                %                     ' = ' fixLaTeX(myLaTeX(solutionData.char_eq)) '\]'];
                header{end+1} = ['\[' solutionData.out_name char_eq ' = ' ...
                    solutionData.char_eq '\]'];
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case {'resistanceResultAvailable','impedanceResultAvailable'}
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = ['The equivalent ' REN ' is now available.'];
                else
                    header{end+1} = ['La ' RIT ' equivalente ' specialChar('egrave',G.circuitOptions) ' ora disponibile.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                %
                val = getVal(G);
                %
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The equivalent ' REN ' is'];
                else
                    solution{end+1} = ['La ' RIT ' equivalente vale'];
                end
                [str, fullunit] = formatResult(G.output{1}.(val),G.circuitOptions,'R');
                solution{end+1} = ['\[' G.output{1}.label ' = ' str fullunit '\]'];
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            case {'conductanceResultAvailable','admittanceResultAvailable'}
                header{end+1} = typesetCirProblemTag('solstep','open',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = ['The equivalent ' GEN ' is now available.'];
                else
                    header{end+1} = ['La ' GIT ' equivalente ' specialChar('egrave',G.circuitOptions) ' ora disponibile.'];
                end
                header{end+1} = typesetCirProblemTag('solstep','close',G.circuitOptions,getDataForHeader(G));
                %
                val = getVal(G);
                %
                solution{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language,'EN')
                    solution{end+1} = ['The equivalent ' GEN ' is'];
                else
                    solution{end+1} = ['La ' GIT ' equivalente vale'];
                end
                [str, fullunit] = formatResult(G.output{1}.(val),G.circuitOptions,'G');
                solution{end+1} = ['\[' G.output{1}.label ' = ' str fullunit '\]'];
                solution{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
                
        end
        
    case 'SteadyStateAnalysis_AC'
        
        %% AC steady-state analysis via Phasor circuit solution
        switch mode
            
            case 'collection'
                header{end+1} = typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                if strcmp(G.circuitOptions.language, 'EN')
                    header{end+1} = 'The Phasor variables are now converted to the corresponding time-domain sinusoids';
                else
                    header{end+1} = 'La soluzione fasoriale viene ora convertita nel dominio del tempo, ottenendo le sinusoidi';
                end
                header{end+1} = typesetCirProblemTag('solstep','closeresult',G.circuitOptions);
            
            case 'resultAvailable'
                
                nVars = length(solutionData);
                
                if strcmp(G.circuitOptions.language,'EN')
                    header{end+1} = [typesetCirProblemTag('solstep','openresult',G.circuitOptions) 'The expression' plural(nVars) ' of '];
                else
                    header{end+1} = [typesetCirProblemTag('solstep','openresult',G.circuitOptions) plural(nVars,'La') ' espression' plural(nVars,'e') ' di '];
                end
                for ii = 1:nVars
                    header{end+1} = ['\(' G.output{ii}.label '\)' ...
                        resultSeparator(ii,nVars)];
                end
                header{end+1} = [' ' toBe(nVars,G.circuitOptions) ':']; % 'is' or 'are' for EN, 'egrave' o 'sono' per IT
                header = [header(:); typesetCirProblemTag('solstep','closeresult',G.circuitOptions)];
                
                solution{end+1} =  typesetCirProblemTag('solstep','openresult',G.circuitOptions);
                
                for ii = 1:nVars
                    solution{end+1} = ['\[' solutionData{ii} '\]']; %#ok<*SAGROW>
                end
                solution = [solution(:); typesetCirProblemTag('solstep','closeresult',G.circuitOptions)];

        end
        
    otherwise
end

end
