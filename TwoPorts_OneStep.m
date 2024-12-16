function [isApplicable, Gout, header, solution, results] = ...
    TwoPorts_OneStep(G,solutionOptions)

% Find port elements
p_edge = findElementsOfType(G, 'P');

% Determine applicability
isApplicable = ~isempty(p_edge) && length(p_edge) == 2 && ~strcmpi(G.output{1,1}.type,'Tmatrix'); % && nSources == 0;

% Return if not applicable or if only check is required
if ~isApplicable || strcmpi(solutionOptions.process,'checkOnly')
    Gout = {};
    header = {};
    solution = {};
    results = {};
    return;
end

Gout = cell(1,2);
header = cell(1,2);
solution = cell(1,2);
results = {};

% ... Convert circuit to symbolic form
G = convertToSymbolic(G,p_edge);

if strcmpi(G.output{1,1}.type,'Rmatrix')
    types={'V','V'};
elseif strcmpi(G.output{1,1}.type,'Gmatrix')
    types={'I','I'};
elseif strcmpi(G.output{1,1}.type,'hmatrix')
    types={'I','V'};
elseif strcmpi(G.output{1,1}.type,'gmatrix')
    types={'V','I'};
end

[Gout,header,solution] = replacePortsWithTestSources(G,p_edge,types);




% % ... copy circuit to output by removing output structure (redefined below)
% Gout{1} = rmfield(G,'output');
% 
% % ... assign output data structure to subcircuit
% Gout{1}.output = cell(1);
% Gout{1}.output{1}.type = 'voltage';
% Gout{1}.output{1}.unitType = 'V';
% 
% for ii=1:2
%     Gout{1}.output{1}.label = Gout{1}.edges.elemdata{port(ii)}.voltageLabel;  %%%%%%%%VEDERE QUI
%     Gout{1}.edges.elemdata{port(ii)}.showV = 1;
% end
% 
% % ... redefine output label so that it matches port voltage and make sure
% % output variable is displayed on circuit schematic
% Gout{1}.output{1}.resultAvailable = false;
% 
% Gout{2} = Gout{1};
% 
% %% Finalize header and solution
% header = {header};
% solution = {solution};
% 
% end
