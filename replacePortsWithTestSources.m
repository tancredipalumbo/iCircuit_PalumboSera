function [G,header,solution] = replacePortsWithTestSources(G,p_edge,types)

%% Add the source

for ii=1:2
% Generate new name
newElementSubscript = getNewElementSubscript;
SourceName = [types '_' newElementSubscript];
G.edges.elem{p_edge(ii)} = SourceName;

G.edges.elemdata{p_edge(ii)}.sourcetype = 'DC';

SourceSym = SourceName;
% Assign symbolic value and make sure this source is recognized as a test
% source, so that its variables voltage and current are defined with a
% non-normal sign reference
G.edges.elemdata{p_edge(ii)}.type = 'symbolic';
G.edges.elemdata{p_edge(ii)}.valueSym = sym(SourceSym);
G.edges.elemdata{p_edge(ii)}.valueLaTeX = formatResult(G.edges.elemdata{p_edge(ii)}.valueSym, G.circuitOptions, '');
G.edges.elemdata{p_edge(ii)}.testSource = true;

% Update and generate labels of element, voltage and current
G.edges.labels{p_edge(ii)} = SourceName;
[G.edges.elemdata{p_edge(ii)}.voltageLabel,G.edges.elemdata{p_edge(ii)}.currentLabel] = ...
    vi_label(G,[],newElementSubscript,[types(ii) 'source']);

% Highlight test source with a dedicated color
G.edges.elemdata{p_edge(ii)}.highlight = 1;

% Update all topological information after replacement of port 
G = updateCircuitTopologyInfo(G);

% Mark output variables for display on circuit drawing
if strcmp(types(ii), 'I')
    G.edges.elemdata{p_edge(ii)}.showV = 1;
else
    G.edges.elemdata{p_edge(ii)}.showI = 1;
end

end

solutionData.sourceName = texifySub(SourceSym);
for ii=1:2
    if strcmp(types(ii), 'I')
        solutionData.equivalentType = 'V';
        solutionData.outputName = G.edges.elemdata{p_edge(ii)}.voltageLabel;
        
    else
        solutionData.equivalentType = 'I';
        solutionData.outputName = G.edges.elemdata{p_edge(ii)}.currentLabel;
    end
end


[header,solution] = writeSolutionStep('theveninNorton_1step',[lower(solutionData.equivalentType) 'addSymSource'],G,solutionData);


return
end


