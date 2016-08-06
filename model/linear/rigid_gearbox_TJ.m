% RIGID_GEARBOX_TJ Get linear dynamics matrices  - rigid gearbox with torque-jerk states
%
% [A, B, C, I, D, K] = jointObj.rigid_gearbox_TJ
%
% jointObj is the instance of the joint class object for which this
% function has been called.
%
% Outputs::
%   A:   System matrix
%   B:   Input matrix
%   C:   Output matrix
%   I:   Inertia matrix
%   D:   Damping matrix
%   K:   Stiffness matrix
%
% Notes::
%  This function is identical to rigid_gearbox, but with the difference that it 
%  works with a transformed state vector. The transformed vector represents
%  torques and jerks instead of positions and velocities.
%
% Examples::
%
% Author::
%  Joern Malzahn
%  Wesley Roozing
%
% See also full_dyn, output_fixed, rigid_gearbox.

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

function [A, B, C, I, D, K] = rigid_gearbox_TJ(obj)
    
    % x = [tau_l, tau_e, tau_l_dot, tau_e_dot]'

    % Get position-velocity states
    [A, B, C, I, D, K] = obj.rigid_gearbox();

    k_b = obj.k_b;
    k_e = obj.k_e; % shorthands %#ok<*PROP>
    T = [   -k_b,	k_b;
            0,      k_e     ];

    Tx = [	T,                  zeros(size(T));
            zeros(size(T)),     T               ];

    A = Tx*A/Tx;
    B = Tx*B;
    C = Tx\C;
    
end
