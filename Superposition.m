function [isApplicable, Gout, header, solution, results] = ...
    Superposition(G,solutionOptions)
%
% function [isApplicable, Gout, header, solution, results] = ...
%    Superposition(G,solutionOptions)
%
% This function implements the Superposition theorem. The initial circuit G
% is split into nSources independent circuits, each with a single active
% source and all other sources deactivated. 
%
% Applicability of this method requires:
% - a number of (active) independent sources larger than one (note that
%   active sources are denoted by field G_s.edges.elemdata{jj}.sourcetype
%   equal to the string '0')
%
% This method only provides the splitting of the circuit into its
% modified subcircuits with deactivated sources. Individual circuit
% solution is delayed to specific methods to be applied by the User for
% each circuit. Finally method CollectSuperpositionResults will have to be
% called automatically as soon as all individual circuits are solved for
% the respectibe output variables. Here, results is a dummy variable (not
% assigned here and returned as empty.
%
% Author: Stefano Grivet-Talocia, DET, Politecnico di Torino
% Last revision: June 29, 2020


% Check applicability first: determine the number of independent sources
[v_sources,i_sources] = findActiveSources(G);
sources = [v_sources,i_sources];
nSources = length(sources);

% Must have more than one source
isApplicable = nSources > 1;

% Determine number of active sources (if required), and update
% applicability flag: there must be more than one active sources, otherwise
% superposition does not make sense...
if isApplicable
    nActive = 0;
    for jj = sources
        if ~strcmp(G.edges.elemdata{jj}.sourcetype,'0')
            nActive = nActive + 1;
        end
    end
    isApplicable = (nActive > 1);
end

% Return if not applicable or if only check is required
if ~isApplicable || strcmpi(solutionOptions.process,'checkOnly')
    Gout = {};
    header = {};
    solution = {};
    results = {};
    return;
end

%% Split circuit by switching off sources except one

% Get here if Superposition is applicable.

% Initialize output variables. All outputs are cell arrays
% - elements 1:nSources are obtained by switching off sources except one
% - elements nSources+1:2*nSources are obtained from the above by
%   topological simplification and redrawing

Gout = cell(1,2*nSources);
header = cell(1,2*nSources);
solution = cell(1,2*nSources);
results = {};

% Reset the color of all elements in the circuit
G = colorCircuitElements(G,[],1);

% Loop over the sources
for ii = 1: nSources
    
    % Switch off all sources except current and assign the resulting
    % circuit, header and solution to the elements of Gout, header and
    % solution (these are cell arrays of structs (G) and cell arrays
    % (header and solution) and will need to be decoded by calling unit
    % (applyMethodToTemplate)
    [Gout{ii},header{ii},solution{ii}] = switchOffSuperposition(G,sources(ii),ii);
    
    % For each circuit obtained above, generate a new circuit obtained by
    % simplifying topology.
%%%%    Gout{ii+nSources} = SimplifyTopology(Gout{ii});
    Gout{ii+nSources} = Gout{ii};
    
    % The corresponding header is obtained by the problem statement of the
    % original circuit, which is not available here. Header is here left
    % empty and will be typeset in calling unit (applyMethodToTemplate)
    
end

%% Finalize header

% Prepend introduction to header of first individual circuit, that serves
% as method description for the splitting operation
[header_intro,~] = writeSolutionStep('superposition','intro',Gout{1},nSources);
header{1} = [header_intro(:); header{1}(:)];

return
end
