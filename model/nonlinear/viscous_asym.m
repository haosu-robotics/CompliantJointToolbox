%VISCOUS_ASYM Calculate asymetric viscous friction torques
%
% [tau] = viscous_asym(jointObj, x)
%
% jointObj is the instance of the joint class object for which this
% function has been called.
%
%
% Inputs::
%   x: state vector depending on the model type as
%     x = [q_m; q_g; q_l; q_m_dot; q_g_dot, q_l_dot'];  full_dyn
%     x = [q_g, q_l, q_g_dot, q_l_dot]'                 rigid_gearbox
%     x = [q_m, q_g, q_l, q_m_dot, q_g_dot]'            output_fixed
%     x = [q_g, q_l, q_g_dot]'                          output_fixed_rigid_gearbox
%     x = [q_g, q_g_dot]'                               rigid
%
% Outputs::
%   tau: friction torque
%
% Notes::
%
%
% Examples::
%
% Author::
%  Joern Malzahn
%  Wesley Roozing
%
% See also full_dyn, coulomb.

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

function [ tau ] = viscous_asym(obj, x)
    
    % Preallocate coefficient vectors
    c       = zeros(size(x));
    c_neg   = zeros(size(x));
    cc      = zeros(size(x));
    
    % Get some shorthands
    d_m     = obj.d_m;
    d_g     = obj.d_g;
    d_l     = obj.d_l;
    d_m_n   = obj.d_m_n;
    d_g_n   = obj.d_g_n;
    d_l_n   = obj.d_l_n;
    
    % Build coefficient vector
    % Because the positive part is built into the linear dynamics, we
    % compensate for them in this asymmetric nonlinear model to obtain the
    % desired damping values. For the same reason, the positive part is zero.
    if (strcmp(obj.modelName, 'full_dyn'))
        c       = [0, 0, 0, 0,              0,              0               ]';
        c_neg   = [0, 0, 0, -d_m + d_m_n,   -d_g + d_g_n,   -d_l + d_l_n    ]';
        
    elseif (strcmp(obj.modelName, 'rigid_gearbox'))
        c       = [0, 0, 0,                             0               ]';
        c_neg   = [0, 0, -d_m - d_g + d_m_n + d_g_n,    -d_g + d_g_n    ]';
        
    elseif (strcmp(obj.modelName, 'output_fixed'))
        c       = [0, 0, 0, 0,              0               ]';
        c_neg   = [0, 0, 0, -d_m + d_m_n,   -d_g + d_g_n    ]';
        
    elseif (strcmp(obj.modelName, 'output_fixed_rigid_gearbox'))
        c       = [0, 0, 0                              ]';
        c_neg   = [0, 0, -d_m - d_g + d_m_n + d_g_n     ]';
        
    elseif (strcmp(obj.modelName, 'rigid'))
        c       = 0;
        c_neg   = -d_m - d_g - d_l + d_m_n + d_g_n + d_l_n;
        
    end
    
    % Build coefficients depending on signs of velocities
    cc(x>0) = c(x>0);
    cc(x<0) = c_neg(x<0);

    % If we have values over time per variable, pad the coefficients
    if (size(x,2) > 1)
        cc = padarray(cc, [1 size(x,2)-1], 'replicate', 'post');
    end
    
    % Calculate asymmetric viscous friction torques
    tau = -cc .* x;

end

