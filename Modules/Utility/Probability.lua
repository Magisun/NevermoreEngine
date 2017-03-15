-- Probability.lua
-- @author Quenty, w/ contribs for this...

local lib = {}

local log, exp, sqrt, min, max, cos, random = math.log, math.exp, math.sqrt, math.min, math.max, math.cos, math.random

-- Continuous distributions

local function BoxMuller()
	-- Box-Muller Transform
	-- Samples a normal distribution of mean=0, stddev=1 using a uniform random source
	
	return sqrt(-2 * log(random())) * cos(2 * math.pi * random())
end

function lib.UnboundedNormal(Average, StdDeviation)
	-- Samples from a normal distribution with specified mean, and standard deviation
	-- Note: Has no hard cutoffs, see NormalDistribution(...)
	
	return Average + BoxMuller() * StdDeviation
end

-- Deprecated March 3rd, 2017
lib.UnboundedNormalDistribution = function(...)
	print("Warning: UnboundedNormalDistribution is deprecated in favor of UnboundedNormal")
	return lib.UnboundedNormal(...)
end

function lib.Normal(Average, StdDeviation, HardMin, HardMax)
	-- Samples from a normal distribution with specified mean, standard deviation, and cutoffs
	-- Output is bounded by HardMin and HardMax
	
	return min(HardMax, max(HardMin, Average + BoxMuller() * StdDeviation))
end

-- Deprecated March 3rd, 2017
lib.NormalDistribution = function(...)
	print("Warning: NormalDistribution is deprecated in favor of Normal")
	return lib.Normal(...)
end

function lib.Gamma(K, Scale)
	-- Samples from a gamma distribution with specified alpha/k value and theta (scale) value
	-- Note: To use alpha+beta parameters, theta=1/beta
	
	assert(K >= 0, "K must be greater than or equal to 0.")
	
	if K == 0 then
		return 0
	elseif K == 1 then
		return -log(random())
	elseif K < 1 then
		-- Ahrens-Dieter acceptance–rejection method, doi:10.1145/358315.358390
		val = 0
		
		while true do
			u = random()
			v = random()
			w = random()
			
			if u <= exp(1)/(exp(1) + K) then
				val = v^(1/K)
				
				if w * val^(K-1) <= val^(K-1) * exp(-val) then
					break
				end
			else
				val = 1 - log(v)
				
				if w * exp(-val) <= val^(K-1) * exp(-val) then
					break
				end
			end
		end
		
		return val*Scale
	elseif K > 1 then
		-- Marsaglia-Tsang transformation-rejection method, doi:10.1145/358407.358414
		D = K - 1/3
		C = 1/sqrt(9*D)
		val = 0
		
		while true do
			v = 0
			while v <= 0 do
				x = BoxMuller()
				v = 1 + C*x
			end
			v = v^3
			
			u = random()
			if u < 1 - 0.0331*x^4 or log(u) < 0.5*x^2 + D*(1 - v + log(v)) then
				val = D*v
				break
			end
		end
		
		return val*Scale
	end
end

function lib.Beta(Alpha, Beta)
	-- Samples from a beta distribution with specified alpha and beta parameters
	
	assert(Alpha > 0, "Alpha must be greater than 0.")
	assert(Beta > 0, "Beta must be greater than 0.")
	
	x = lib.Gamma(Alpha, 1)
	y = lib.Gamma(Beta, 1)
	
	return x / (x + y)
end

--- Discrete distributions

function lib.Bernoulli(Probability)
	-- Samples from a Bernoulli discrete distribution
	-- Output is true/false
	-- @param Probability, chance a sample will be 'true'
	
	return random() < Probability
end

function lib.Binomial(Probability, Trials)
	-- Samples from a binomial discrete distribution
	-- Note: Should not be used to gather large samples
	-- @param Probability, chance of a single trial 
	-- @param Trials, number of trials
	
	local val = 0
	for i=1, Trials do
		val = val + (lib.Bernoulli(Probability) and 1 or 0)
	end
	return val
end

return lib
