function [theta, cost_history, theta_history] = linear_momentum_descent(X, y,
        theta0, alpha, beta, num_iterations)
%% -----------------------------------------------------------------------------
%%
%% Function 'linear_descent':
%%
%% -----------------------------------------------------------------------------
%
% Use:
%       -- [theta, cost_history, theta_history] = linear_descent(X, y, alpha,
%                  num_iterations)
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
%         theta0: The initial value of theta, a column vector of size (n x 1)
%         alpha: The learning rate, which determines the step size in
%         each iteration
%         beta: The momentum parameter, which determines the weight of the
%         previous step in the current step
%         num_iterations: The number of iterations to perform the
%         gradient descent
%
%       Output:
%         theta: learned parameters
%         cost_history: vector of cost function history
%         theta_history: matrix of theta history
%
%       Example:
%         data = load('ex1data1.txt');
%         y = data(:, 2);  % Assuming y is the target column vector
%         m = length(y);   % number of training examples
%         X = [ones(m, 1), data(:, 1)];  % Assuming x is the feature matrix
%                                        % without the intercept term
%         [theta, cost_history] = linear_descent(X, y, 0.01, 0.9, 1500);
%
%       Note:
%         The input X must be a matrix of size (m x n) where:
%           m = number of training examples
%           n = number of features
%
% ------------------------------------------------------------------------------
    m = length(y);   % number of training examples
    n = size(X, 2);  % number of features

    theta = theta0;                           % initialize theta
    velocity = zeros(n, 1);                   % initialize velocity
    cost_history = zeros(num_iterations, 1);  % track the cost function history
    theta_history = theta0;                   % track the theta history

    i = 1;
    while num_iterations >= i
        % Compute the hypothesis (predictions)
        h = X * theta;

        % Compute the error
        error = h - y;

        % Compute the gradient
        grad = (1/m) .* X' * error;

        % Update velocity
        velocity = (beta .* velocity) + ((1 - beta) .* grad);

        % Update theta using momentum
        theta = theta - (alpha .* velocity);

        % Compute the cost function
        cost = (1/(2*m)) * sum(error.^2);
        cost_history(i) = cost;

        % Update theta_history
        theta_history = [theta_history, theta];

        i = i + 1;

    endwhile;  % end of while loop

endfunction;  % end of function 'linear_descent'