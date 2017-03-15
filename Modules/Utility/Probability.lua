-- Probability.lua
-- @author Quenty, w/ contribs for this...

local lib = {}

-- Continuous distributions

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

function lib.GammaDistribution(K, Scale)
	-- Samples from a gamma distribution with specified alpha/k value and theta (scale) value
	-- Note: To use alpha+beta parameters, theta=1/beta
	
	assert(K >= 0, "K must be greater than or equal to 0.")
	
	if K == 0 then
		return 0
	elseif K == 1 then
		return -math.log(math.random())
	elseif K < 1 then
		-- Ahrens-Dieter acceptance–rejection method, doi:10.1145/358315.358390
		val = 0
		
		while true do
			u = math.random()
			v = math.random()
			w = math.random()
			
			if u <= math.exp(1)/(math.exp(1) + K) then
				val = v^(1/K)
				
				if w * val^(K-1) <= val^(k-1) * math.exp(-val) then
					break
				end
			else
				val = 1 - math.log(v)
				
				if w * math.exp(-val) <= val^(k-1) * math.exp(-val) then
					break
				end
			end
		end
		
		return val*Scale
	elseif K > 1 then
		-- Marsaglia-Tsang transformation-rejection method, doi:10.1145/358407.358414
		D = K - 1/3
		C = 1/math.sqrt(9*D)
		val = 0
		
		while true do
			v = 0
			while v <= 0 do
				x = BoxMuller()
				v = 1 + C*x
			end
			v = v^3
			
			u = math.random()
			if u < 1 - 0.0331*x^4 or math.log(u) < 0.5*x^2 + d*(1 - v + math.log(v)) then
				val = D*v
				break
			end
		end
		
		return val*Scale
	end
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
