function [theta, cost_history] = nonlinear_descent(X, y, theta_initial, alpha, num_iterations)
%% -----------------------------------------------------------------------------
%%
%% Function 'nonlinear_descent':
%%
%% -----------------------------------------------------------------------------
%
% Use:
%       -- [theta, cost_history] = nonlinear_descent(X, y, theta_initial,
%              alpha, num_iterations)
%
% Description:
%       Performs gradient descent to learn theta
%
%       Input:
%         X: The feature matrix with each row representing a training example
%         and each column representing a feature. The matrix should include
%         a column of ones for the intercept term
%         y: A column vector of the target values (output) corresponding to each
%         training example
%         alpha: The learning rate, which determines the step size in
%         each iteration
%         num_iterations: The number of iterations to perform the
%         gradient descent
%
%       Output:
%         theta: learned value of theta
%         cost_history: vector of cost function history
%
%       Example:
%         data = [1 1; 1 2; 1 3];
%         y = [1; 2; 3];
%         m = length(y);  % number of training examples
%         X = [ones(m, 1), data(:, 1)];  % feature matrix
%         theta_initial = [0; 0];
%         alpha = 0.1;
%         num_iterations = 10;
%         [theta, cost_history] = nonlinear_descent(X, y, theta_initial,
%              alpha, num_iterations)
%
%       Note:
%         The input X must be a matrix of size (m x n) where:
%           m = number of training examples
%           n = number of features
%
% -----------------------------------------------------------------------------
    m = length(y);              % number of training examples
    n = length(theta_initial);  % number of parameters
    
    theta = theta_initial;  % initialize theta
    cost_history = zeros(num_iterations, 1);  % track the cost function history

    i = 1;
    while num_iterations >= i
        % Compute the hypothesis (predictions)
        h = X * theta;
        
        % Compute the error
        error = h - y;

        % Update theta using gradient descent
        gradient = (1/m) * (X' * error);
        theta = theta - alpha * gradient;
        
        % Compute the cost function
        cost = (1/(2*m)) * sum(error.^2);
        cost_history(i) = cost;

        i = i + 1;

    endwhile;  % end of while loop

endfunction;  % end of function 'nonlinear_descent'