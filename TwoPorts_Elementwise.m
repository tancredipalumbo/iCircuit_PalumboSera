function [isApplicable, Gout, header, solution, results] = ...
    TwoPorts_Elementwise(G,solutionOptions)

%Find all port in circuit
port = findElementsOfType(G, 'P');

% Check applicability first: determine the number of independent sources
%[v_sources,i_sources] = findActiveSources(G);
%sources = [v_sources,i_sources];
%nSources = length(sources);

% Determine applicability
isApplicable = ~isempty(port) && length(port) == 2; %&& nSources == 0;

% Return if not applicable or if only check is required
if ~isApplicable || strcmpi(solutionOptions.process,'checkOnly')
    Gout = {};
    header = {};
    solution = {};
    results = {};
    return;
end

nPorts = length(port);
Gout = cell(1,2*nPorts);
header = cell(1,2*nPorts);
solution = cell(1,2*nPorts);
results = {};

% ... Convert circuit to symbolic form
G = convertToSymbolic(G,port);

% Loop over the ports
for ii = 1: length(port)
    [Gout{ii},header{ii},solution{ii}] = replacePortWithTestSource(G,port(ii),'V',0);
    Gout{ii+nPorts}.output = Gout{ii}.output;
end


% ---------------------------------------
% ... copy circuit to output by removing output structure (redefined below)
Gout{1:2} = rmfield(G,'output');

% ... assign output data structure to subcircuit
Gout{1:2}.output = cell(1);
Gout{1:2}.output{1}.type = 'voltage';
Gout{1:2}.output{1}.unitType = 'V';

for ii=1:2
    Gout{ii}.output{ii}.label = Gout{ii}.edges.elemdata{port(ii)}.voltageLabel;  %%%%%%%%VEDERE QUI
    Gout{ii}.edges.elemdata{port(ii)}.showV = 1;
end

% ... redefine output label so that it matches port voltage and make sure
% output variable is displayed on circuit schematic
Gout{1}.output{1}.resultAvailable = true;
Gout{2}.output{2}.resultAvailable = true;

Gout{3} = Gout{1};
Gout{4} = Gout{2};

%% Finalize header and solution
header = {header};
solution = {solution};

