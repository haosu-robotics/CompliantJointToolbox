% GETLINEARDOB Compute linear disturbance observer transfer functions.
%
%   [P, Q_td, PQ_td] = getLinearDOB(jointObj, omega_c, outputIdx, doPlot)
%
%   This function creates a DOB from a linear model jointObj with outputs
%   specified by [outputIdx]. It returns the plant model, Q-filter with
%   cut-off frequency omega_c, and the inverted plant + filter. The doPlot
%   flag plots Bode plots of the resulting transfer functions.
%
% Inputs::
%   jointObj: Joint object
%   omega_c: DOB Q-filter cut-off frequency in [rad/s]
%   outputIdx: Joint outputs measured by the observer
%   doPlot: Whether to plot the results
%
% Outputs::
%   P: Plant transfer function
%   Q_td: Low-pass filter (Q-filter) with cut-off frequency omega_c
%   PQ_td: Inverted plant + filter
%
% Notes::
%
%
% Examples::
%
%
% Author::
%  Joern Malzahn
%  Wesley Roozing
%
% See also getLinearDOB_fromData, getObserver, getKalman.

% Copyright (C) 2016, by Joern Malzahn, Wesley Roozing
%
% This file is part of the Compliant Joint Toolbox (CJT).
%
% CJT is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% CJT is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
% License for more details.
%
% You should have received a copy of the GNU General Public License
% along with CJT. If not, see <http://www.gnu.org/licenses/>.
%
% For more information on the toolbox and contact to the authors visit
% <https://github.com/geez0x1/CompliantJointToolbox>

function [P, Q_td, PQ_td] = getLinearDOB(jointObj, omega_c, outputIdx, doPlot)
    % Default parameters
    if (~exist('doPlot','var') || isequal(doPlot,[]))
        doPlot = 0;
    end

    
    %% Get joint object and state-space system with current input and specified output
    sys     = jointObj.getStateSpace();
    sys     = ss(sys.A, sys.B(:,1), sys.C(outputIdx,:), sys.D(outputIdx,1));
    P       = tf(sys);

    % Check if P is a dynamic system
    % If we select the output position for a fixed-output plant for
    % example, P will be a static gain of 0, and a DOB cannot be
    % constructed.
    if (order(P) == 0)
        error('getLinearDOB error: Plant P has zero order for the chosen output, cannot continue.');
    end
    
    
    %% Design low-pass Butterworth filters

    % Q_td
    [a, b]  = butter(order(P), omega_c, 's');
    Q_td    = tf(a,b);

    % P^-1 * Q_td
    PQ_td   = inv(P) * Q_td;


    %% Show Bode plots of results
    % Bode options
    bodeOpt             = bodeoptions;
    bodeOpt.FreqUnits   = 'Hz';
    
    % Plot if required
    if doPlot
        figure(5); clf; hold on;
        bode(P, bodeOpt);
        bode(inv(P), bodeOpt);
        bode(Q_td, bodeOpt);
        bode(PQ_td, bodeOpt);
        xlim([0.1 100]);
        grid on;
        legend('P', 'P^{-1}', 'Q_{td}', 'PQ_{td}');
    end

    
    %% Optionally save results
    
    % Disabled as this causes problems when calling automatically from
    % Simulink masks
%     fname = 'DOB_results.mat';
%     if confirm(['Do you want to save the results to ' fname ' [y/N]?'], 0)
%         save(fname, 'jointObj', 'P', 'Q_td', 'PQ_td');
%         disp(['Data saved to ' fname]);
%     end
    
end
