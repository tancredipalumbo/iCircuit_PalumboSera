%% Container in G that defines problem statement and stores results of any analysis

% This field must be present. It is a cell array of structures
G.output

% Each element of G.outputs{ii} is a structure with fields

% Type of output: mandatory
type = {...
    'voltage',...           % if output is a branch voltage
    'current',...           % if output is a branch current
    'power',...             % if output is power (abs or del) of branch
    'power_active',...      % if output is active power (abs or del) of branch
    'power_reactive',...    % if output is reactive power (abs or del) of branch
    'characteristic',...    % if output is a symbolic characteristic at given port
    'resistance',...        % if output is equivalent resistance at given port
    'conductance',...       % if output is equivalent conductance at given port
    'impedance',...         % if output is equivalent impedance at given port
    'admittance',...        % if output is equivalent admittance at given port
    'reactance',...         % if output is equivalent rectance at given port
    'susceptance',...       % if output is equivalent susceptance at given port
    'thevenin',...          % if output is thevenin equivalent at given port
    'norton',...            % if output is norton equivalent at given port
    'Veq',...               % if output is open-circuit voltage at given port
    'Ieq',...               % if output is short-circuit current at given port
    'capacitance',...       % if output is a capacitance value
    'inductance',...        % if output is an inductance value
    'transferfunction',...  % if output is a transfer function between a source and some output
    'impulseresponse',...   % if output is an impulse response/transfer function pair
    'Rmatrix',...           % if output is the resistance matrix at two given ports
    'Gmatrix',...           % if output is the conductance matrix at two given ports
    'H1matrix',...          % if output is the hybrid-1 matrix at two given ports
    'H2matrix',...          % if output is the hybrid-2 matrix at two given ports
    'T1matrix',...          % if output is the transmission-1 matrix at two given ports
    'T2matrix',...          % if output is the transmission-2 matrix at two given ports
    'Zmatrix',...           % if output is the impedance matrix at two given ports
    'Ymatrix',...           % if output is the admittance matrix at two given ports
    'port',...              % if output is a port where some equivalent will be inserted
    'poles',...             % if output is the set of natural frequencies
    'tau',...               % if output is a time constant of I order circuit
    'mna',...               % if output is the MNA system (both DC or LTI)
    };

%%% Warning: index will become outdated when circuit reduction is
%%% performed. Must either modify substituteSubGraph_multiple.m to remap
%%% index, or index MUST NOT be used when typesetting statements or
%%% results. Current solution is tu use label and nodeLabels instead, which
%%% are guaranteed not to change throughoug solution process.

%%% The following index is NOT USED. Labels are used as a main descriptor
%%% for each output (labels of output are locked throughout solution
%%% steps), net of adding/removing superscripts
%%% index = jj; % Index of edge where this output is measured (two-element vector in case of two-port)

srcIndex = kk; % Index of source exciting this output (used only for two-port or H(s)). Two-element vector for two-port.
srcType = {'v','i'}; % Type of source exciting this output (as above). Single string or two-element cell array of strings for two-port.

nodeLabels = {'A','B'}; % labels of nodes of port where equivalent is required
label = str; % label of this output (LaTeX math-mode compatible)


%% Information about the results (see examples below for detailed explanation)

resultAvailable = {true,false}; % Logical, true if result is available, false if not available

value = X; % numeric or symbolic value (single scalar or matrix for two-port)

referenceValue = X; % true result for current output computed by MNA (in solve_XXX.m functions)

parts; % structure that includes individual components of multiple-output (thevenin, norton, etc...)


%% Modifications that are necessary to implement automated problem statement and result detection
%
% 1. When problem is generated, create G.output and its subfields. Proper
%    location should be the functions solve_*, where all information about
%    the desired outputs is available. REQUIRES CARE to enforce backward
%    compatibility!!!
%
% 2. Modify writeProblemStatement so that the header is automatically
%    generated using only the information retrieved from G.output
%
% 3. Modify each method to write its results to G.output when completed, so
%    that methods will terminate automatically when results are detected by
%    higher level iteration control
%
% 4. Generate a new function that typesets the result (solution) using
%    ONLY the fields of G.output
%
% 5. Perform necessary updates to applyMethod, applyMethodToTemplate and
%    all other related functions. Recall that some outputs of a given
%    analysis may be inputs for a subsequent analysis as defined by the
%    cirSolTree structure. So, G.output can be an output but also an input.
%    Template handling must take this into account.
%
% 6. All reduction methods cause renumbering of elements. Must propagate to
%    the G.output{ii}.index and G.output{ii}.srcIndex the redefinition of
%    the target indexes after reduction methods.


% --- Example: voltage or current (DC)
G.output{1}.type = 'voltage'; % or current
G.output{1}.unitType = 'V'; % or 'I'
G.output{1}.label = 'v_{4}'; % or 'i_{4}';
G.output{1}.resultAvailable = false;
G.output{1}.referenceValue = 10;

% --- Example: equivalent resistance (DC)
G.output{1}.type = 'resistance';
G.output{1}.unitType = 'R';
G.output{1}.label = 'R_{eq}';
G.output{1}.resultAvailable = false;
G.output{1}.referenceValue = 50;
G.output{1}.nodeLabels = {'A','B'};

% --- Example: thevenin equivalent (DC)
% ... general data
G.output{1}.type = 'thevenin';
G.output{1}.resultAvailable = false;
G.output{1}.nodeLabels = {'A','B'};
% ... equivalent resistance
G.output{1}.parts{1}.label = 'R_{eq}';
G.output{1}.parts{1}.type = 'resistance';
G.output{1}.parts{1}.unitType = 'R';
G.output{1}.parts{1}.referenceValue = 50;
G.output{1}.parts{1}.resultAvailable = false;
% ... Open-circuit voltage
G.output{1}.parts{2}.label = 'V_{eq}';
G.output{1}.parts{2}.unitType = 'V';
G.output{1}.parts{2}.type = 'voltage';
G.output{1}.parts{2}.referenceValue = 10;
G.output{1}.parts{2}.resultAvailable = false;

% --- Example: norton equivalent (DC)
% ... general data
G.output{1}.type = 'norton';
G.output{1}.resultAvailable = false;
G.output{1}.nodeLabels = {'A','B'};
% ... equivalent conductance
G.output{1}.parts{1}.label = 'G_{eq}';
G.output{1}.parts{1}.type = 'conductance';
G.output{1}.parts{1}.unitType = 'G';
G.output{1}.parts{1}.referenceValue = 0.02;
G.output{1}.parts{1}.resultAvailable = false;
% ... short-circuit current
G.output{1}.parts{2}.label = 'I_{eq}';
G.output{1}.parts{2}.unitType = 'I';
G.output{1}.parts{2}.type = 'current';
G.output{1}.parts{2}.referenceValue = 1;
G.output{1}.parts{2}.resultAvailable = false;

% Example: two-port (DC)
G.output{1}.label = '\mathbf{R}'; % any of RGhgT
G.output{1}.type = 'Rmatrix'; % any of Rmatrix,Gmatrix,hmatrix,gmatrix,Tmatrix
G.output{1}.unitType = 'R';
G.output{1}.resultAvailable = false;
G.output{1}.referenceValue = [1 2;3 4];

% --- Example: voltage or current (AC)
G.output{1}.label = 'v_{4}(t)'; % or 'i_{4}(t)';
G.output{1}.type = 'voltage'; % or 'current';
G.output{1}.unitType = 'V'; % or 'I';
G.output{1}.resultAvailable = false;
G.output{1}.referenceValue = 1+1j; % a phasor
G.output{1}.omega0 = 4;

% --- Example: equivalent impedance (AC)
G.output{1}.label = 'Z_{eq}';
G.output{1}.labelReal = 'R_{eq}';
G.output{1}.labelImag = 'X_{eq}';
G.output{1}.type = 'impedance';
G.output{1}.unitType = 'R';
G.output{1}.resultAvailable = false;
G.output{1}.referenceValue = 50+50j;
G.output{1}.nodeLabels = {'A','B'};
G.output{1}.omega0 = 4;

% --- Example: thevenin equivalent (AC)
% ... general data
G.output{1}.type = 'thevenin';
G.output{1}.resultAvailable = false;
G.output{1}.nodeLabels = {'A','B'};
G.output{1}.omega0 = 4;
% ... equivalent impedance
G.output{1}.parts{1}.label = 'Z_{eq}';
G.output{1}.parts{1}.labelReal = 'R_{eq}';
G.output{1}.parts{1}.labelImag = 'X_{eq}';
G.output{1}.parts{1}.type = 'impedance';
G.output{1}.parts{1}.unitType = 'R';
G.output{1}.parts{1}.resultAvailable = false;
G.output{1}.parts{1}.referenceValue = 50+50j;
% ... open-circuit voltage
G.output{1}.parts{2}.label = '\hat{V}_{eq}';
G.output{1}.parts{2}.labelReal = '\hat{V}''_{eq}';
G.output{1}.parts{2}.labelImag = '\hat{V}''''_{eq}';
G.output{1}.parts{2}.type = 'voltage';
G.output{1}.parts{2}.unitType = 'V';
G.output{1}.parts{2}.resultAvailable = false;
G.output{1}.parts{2}.referenceValue = 1+1j;  % a phasor

% --- Example: norton equivalent (AC)
% ... general data
G.output{1}.type = 'norton';
G.output{1}.resultAvailable = false;
G.output{1}.nodeLabels = {'A','B'};
G.output{1}.omega0 = 4;
% ... equivalent admittance
G.output{1}.parts{1}.label = 'Y_{eq}';
G.output{1}.parts{1}.labelReal = 'G_{eq}';
G.output{1}.parts{1}.labelImag = 'B_{eq}';
G.output{1}.parts{1}.type = 'admittance';
G.output{1}.parts{1}.unitType = 'G';
G.output{1}.parts{1}.resultAvailable = false;
G.output{1}.parts{1}.referenceValue = 50+50j;
% ... short-circuit current
G.output{1}.parts{2}.label = '\hat{I}_{eq}';
G.output{1}.parts{2}.labelReal = '\hat{I}_{eq}';
G.output{1}.parts{2}.labelImag = '\hat{I}_{eq}';
G.output{1}.parts{2}.type = 'current';
G.output{1}.parts{2}.unitType = 'I';
G.output{1}.parts{2}.resultAvailable = false;
G.output{1}.parts{2}.referenceValue = 1+1j;  % a phasor

% --- Example: power (AC)
% ... complex power
G.output{1}.label = 'S';
G.output{1}.type = 'power';
G.output{1}.resultAvailable = false;
G.output{1}.referenceValue = 1+1j;
G.output{1}.omega0 = 4;
% ... active power
G.output{1}.parts{1}.label = 'P';
G.output{1}.parts{1}.type = 'power_active';
G.output{1}.parts{1}.unitType = 'P';
G.output{1}.parts{1}.resultAvailable = false;
G.output{1}.parts{1}.referenceValue = 1;
% ... reactive power
G.output{1}.parts{2}.label = 'Q';
G.output{1}.parts{2}.type = 'power_reactive';
G.output{1}.parts{2}.unitType = 'Q';
G.output{1}.parts{2}.resultAvailable = false;
G.output{1}.parts{2}.referenceValue = 1;

% --- Example: natural frequencies
G.output{ii}.label = ['p_{' int2str(ii) '}'];
G.output{ii}.type = 'poles';
G.output{ii}.unitType = 'p';
G.output{ii}.resultAvailable = false;
G.output{ii}.referenceValue = 1+1j;

% --- Example: I order transients
G.output{ii}.label = 'i_4(t)'; % or 'v_4(t)'
G.output{ii}.type = 'current'; % or voltage
G.output{ii}.unitType = 'I';
G.output{ii}.resultAvailable = false;
% ... time constant (the same for all output variables) (no label needed)
G.output{ii}.parts{1}.type = 'tau';
G.output{ii}.parts{1}.unitType = 'T';
G.output{ii}.parts{1}.label = '';
G.output{ii}.parts{1}.resultAvailable = false;
G.output{ii}.parts{1}.referenceValue = 0.1;
% ... coefficient of exponential [y(0+)-y(\infty)] (no label needed)
G.output{ii}.parts{2}.type = 'X0p_Xinf';
G.output{ii}.parts{1}.unitType = 'I'; % same as G.output{ii}.unitType
G.output{ii}.parts{2}.label = '';
G.output{ii}.parts{2}.resultAvailable = false;
G.output{ii}.parts{2}.referenceValue = 2;
% ... asymptotic value (DC steady state) (no label needed)
G.output{ii}.parts{3}.type = 'Xinf';
G.output{ii}.parts{3}.unitType = 'I'; % same as G.output{ii}.unitType
G.output{ii}.parts{3}.label = '';
G.output{ii}.parts{3}.resultAvailable = false;
G.output{ii}.parts{3}.referenceValue = 1;

% Example: transfer functions
G.output{ii}.label = ['H_{' int2str(ii) '}(s)'];
G.output{ii}.type = 'transferfunction';
G.output{ii}.unitType = '';
G.output{ii}.resultAvailable = false;
G.output{ii}.referenceValue = '1/s+1';

% Example: impulse response
G.output{ii}.type = 'impulseresponse';
G.output{ii}.resultAvailable = false;
G.output{ii}.parts{1}.label = ['H_{' int2str(ii) '}(s)'];
G.output{ii}.parts{1}.type = 'transferfunction';
G.output{ii}.parts{1}.unitType = '';
G.output{ii}.parts{1}.resultAvailable = false;
G.output{ii}.parts{1}.referenceValue = '1/s+1';
G.output{ii}.parts{2}.label = ['h_{' int2str(ii) '}(t)'];
G.output{ii}.parts{2}.type = 'current'; % or 'voltage'
G.output{ii}.parts{2}.unitType = '';
G.output{ii}.parts{2}.resultAvailable = false;
G.output{ii}.parts{2}.referenceValue = 'e^{-t} u(t)';

% Example: two-port (LTI)
G.output{1}.label = '\mathbf{Z}'; % any of ZYHGT
G.output{1}.type = 'Zmatrix'; % any of Zmatrix,Ymatrix,Hmatrix,Gmatrix,Tmatrix
G.output{1}.unitType = 'R';
G.output{1}.resultAvailable = false;
G.output{1}.referenceValue = ['s' 's+1';'s+1' 's+2'];

% Example: LTI Transients (noIC, ICfromDC, general)
G.output{1}.type = 'voltage'; % or current
G.output{1}.unitType = 'V'; % or 'I'
G.output{1}.label = 'v_{4}(t)'; % or 'i_{4}(t)';
G.output{1}.resultAvailable = false;
G.output{1}.referenceValue = '10 e^{-t}';

% Example: DC or LTI MNA
G.output{1}.label = '\mathbf{G}';
G.output{1}.type = 'mna';
G.output{1}.unitType = '';
G.output{1}.resultAvailable = false;
G.output{1}.referenceValue = [1/R -1/R; -1/R 1/R];
G.output{2}.label = '\mathbf{B}';
G.output{2}.type = 'mna';
G.output{2}.unitType = '';
G.output{2}.resultAvailable = false;
G.output{2}.referenceValue = [1 0; 0 1];
G.output{3}.label = '\mathbf{x}';
G.output{3}.type = 'mna';
G.output{3}.unitType = '';
G.output{3}.resultAvailable = false;
G.output{3}.referenceValue = {'e_1','e_2'};
G.output{4}.label = '\mathbf{u}';
G.output{4}.type = 'mna';
G.output{4}.unitType = '';
G.output{4}.resultAvailable = false;
G.output{4}.referenceValue = [1; 2];
G.output{5}.label = '\mathbf{C}';
G.output{5}.type = 'mna';
G.output{5}.unitType = '';
G.output{5}.resultAvailable = false;
G.output{5}.referenceValue = [0 0; 0 0];
