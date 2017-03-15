-- Probability.lua
-- @author Quenty, w/ contribs for this...

local lib = {}

local function BoxMuller()
	-- Box-Muller Transform
	-- Samples a normal distribution of mean=0, stddev=1 using a uniform random source
	
	return math.sqrt(-2 * math.log(math.random())) * math.cos(2 * math.pi * math.random())
end

function lib.UnboundedNormalDistribution(Average, StdDeviation)
	-- Samples from a normal distribution with specified mean, and standard deviation
	-- Note: Has no hard cutoffs, see NormalDistribution(...)
	
	return Average + BoxMuller() * StdDeviation
end

function lib.NormalDistribution(Average, StdDeviation, HardMin, HardMax)
	-- Samples from a normal distribution with specified mean, standard deviation, and cutoffs
	-- Output is bounded by HardMin and HardMax
	
	return math.min(HardMax, math.max(HardMin, Average + BoxMuller() * StdDeviation))
end

--- Discrete distributions

function lib.Bernoulli(Probability)
	-- Samples from a Bernoulli discrete distribution
	-- Output is true/false
	-- @param Probability, chance a sample will be 'true'
	
	return math.random() < Probability
end

function lib.Binomial(Probability, Trials)
	-- Samples from a binomial discrete distribution
	-- Note: Should not be used to gather large samples
	-- @param Probability, chance of a single trial 
	-- @param Trials, number of trials
	
	local val = 0
	for i=1, Trials do
		-- Not calling lib.Bernoulli because function calls would make this even slower
		val = val + (math.random() < Probability and 1 or 0)
	end
	return val
end

return lib
