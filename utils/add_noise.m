function noisy = add_noise(x,noise_type,noise_level)
% x: input GT image, range: 0-1
% noise_level:0-255 for gauss, poisson,speckle noise, 0-1 for uniform, salt&pepper, bernoulli, impluse noise
rng('default')
rng(0); % for reproducibility
if strcmp(noise_type, 'gauss')
    noisy = x + randn(size(x)) * (noise_level / 255.0);
elseif strcmp(noise_type, 'poisson')
    noisy = poissrnd(noise_level * x) / noise_level;
elseif strcmp(noise_type, 'salt&pepper')
    prob = rand(size(x));
    noisy = x;
    noisy(prob < 0.5*noise_level) = 0;
    noisy(prob > 1 - 0.5*noise_level) = 1;
elseif strcmp(noise_type, 'bernoulli')
    prob = rand(size(x));
    noisy = x;
    noisy(prob < noise_level) = 0;
elseif strcmp(noise_type, 'impulse')
    prob = rand(size(x));
    rng(1); % reset seed for impulse noise
    imp_noise = rand(size(x));
    noisy = x;
    noisy(prob < noise_level) = imp_noise(prob < noise_level);
elseif strcmp(noise_type, 'speckle')
    noisy = x + x .* randn(size(x)) * (noise_level / 255.0);
elseif strcmp(noise_type, 'uniform')
    noisy = x + (2*noise_level) * (rand(size(x)) - 0.5);
else
    error('Unsupported noise type');
end
end


