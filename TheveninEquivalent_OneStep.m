function [isApplicable, Gout, header, solution, results] = ...
    TheveninEquivalent_OneStep(G,solutionOptions)
%
% function [isApplicable, Gout, header, solution, results] = ...
%    TheveninEquivalent_OneStep(G,solutionOptions)
%
% This function implements the calculation of the Thevenin equivalent based
% on a single-step determination of equivalent resistance and open-circuit
% voltage. The initial circuit G must have a single port element. This port
% is replaced with a symbolic current test source, the entire circuit
% is converted to symbolic form, and the dual source variable (the voltage)
% is requested on output for a standard circuit solution step.
%
% Applicability of this method requires:
% - a single port element in the circuit
%
% This method only provides the setup of the symbolic circuit with the
% external test source. Individual circuit
% solution is delayed to specific methods to be applied by the User. 
% Finally, method AssembleEquivalent_OneStep will have
% to be called automatically as soon as the symbolic circuit is solved
% for its output variable. Here, results is a dummy
% variable (not assigned here and returned as empty).
%
% Author: Stefano Grivet-Talocia, DET, Politecnico di Torino
% Last revision: 16 August, 2020


% Find port elements
port = findElementsOfType(G, 'P');

% Determine applicability
isApplicable = ~isempty(port) && length(port) == 1;

% Return if not applicable or if only check is required
if ~isApplicable || strcmpi(solutionOptions.process,'checkOnly')
    Gout = {};
    header = {};
    solution = {};
    results = {};
    return;
end

%% Transform circuit for equivalent resistance and open-circuit voltage calculations

% Get here if method is applicable.

% Initialize output variables. All outputs are cell arrays

Gout = {};
% header = {};
% solution = {};
results = {};

% Reset the color of all elements in the circuit
G = colorCircuitElements(G,[],1);

% It is assumed that original circuit G is associated with a problem
% statement that coincides with the Thevenin equivalent calculation.
% Therefore, its field G.output is populated with all required subfields.
% nodeLabels = G.output{1}.nodeLabels;

% Prepare circuit for extraction of characteristic equation in symbolic
% form, after connecting a symbolic test current source...

% ... Convert circuit to symbolic form
G = convertToSymbolic(G,port);

% ... Replace port with test current source
[G,header,solution] = replacePortWithTestSource(G,port,'I',0);

% ... copy circuit to output by removing output structure (redefined below)
Gout{1} = rmfield(G,'output');

% ... assign output data structure to subcircuit
Gout{1}.output = cell(1);
Gout{1}.output{1}.type = 'voltage';
Gout{1}.output{1}.unitType = 'V';
Gout{1}.output{1}.label = Gout{1}.edges.elemdata{port}.voltageLabel;

% ... redefine output label so that it matches port voltage and make sure
% output variable is displayed on circuit schematic
Gout{1}.output{1}.resultAvailable = false;
Gout{1}.edges.elemdata{port}.showV = 1;


%% Finalize header and solution
header = {header};
solution = {solution};


return
end
