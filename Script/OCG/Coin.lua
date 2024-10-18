--Coin Toss Effects Handler
if not CoinEffects then
	CoinEffects = {}
end
CoinEffects.COIN_HEADS = 0
CoinEffects.COIN_TAILS = 1

CoinEffects.effects = {
	[CoinEffects.COIN_HEADS] = {},
	[CoinEffects.COIN_TAILS] = {}
}

CoinEffects.registerEffect = function(cardId, coinResult, effectFunction)
	CoinEffects.effects[coinResult][cardId] = effectFunction
end

CoinEffects.getEffect = function(cardId, coinResult)
	return CoinEffects.effects[coinResult][cardId]
end

CoinEffects.applyEffect = function(cardId, coinResult, e, tp, eg, ep, ev, re, r, rp)
	local effectFunction = CoinEffects.getEffect(cardId, coinResult)
	if effectFunction then
		effectFunction(e, tp, eg, ep, ev, re, r, rp)
	end
end

CoinEffects.createCoinEffect = function(c, coinEffectParams)
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(c:GetOriginalCode(), coinEffectParams.descriptionId))
	e1:SetCategory(coinEffectParams.category or 0)
	e1:SetType(coinEffectParams.effectType or EFFECT_TYPE_IGNITION)
	e1:SetRange(coinEffectParams.range or LOCATION_MZONE)
	if coinEffectParams.property then e1:SetProperty(coinEffectParams.property) end
	if coinEffectParams.code then e1:SetCode(coinEffectParams.code) end
	if coinEffectParams.countLimit then e1:SetCountLimit(coinEffectParams.countLimit, coinEffectParams.countLimitCode) end
	if coinEffectParams.cost then e1:SetCost(coinEffectParams.cost) end
	if coinEffectParams.target then e1:SetTarget(coinEffectParams.target) end
	e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
		local res = Duel.TossCoin(tp, coinEffectParams.coinCount or 1)
		local coinResult = (res == coinEffectParams.coinCount) and CoinEffects.COIN_HEADS or CoinEffects.COIN_TAILS
		CoinEffects.applyEffect(c:GetOriginalCode(), coinResult, e, tp, eg, ep, ev, re, r, rp)
	end)
	return e1
end

CoinEffects.proc = function(c, params)
	params = params or {}
	local e1 = CoinEffects.createCoinEffect(c, params)
	c:RegisterEffect(e1)
	return e1
end

-- Example usage:
-- CoinEffects.registerEffect(21208154, CoinEffects.COIN_HEADS, function(e,tp,eg,ep,ev,re,r,rp)
--     -- Implement The Empress heads effect
-- end)
-- CoinEffects.registerEffect(21208154, CoinEffects.COIN_TAILS, function(e,tp,eg,ep,ev,re,r,rp)
--     -- Implement The Empress tails effect
-- end)

-- In the card's script:
-- CoinEffects.proc(c, {
--     descriptionId = 1,
--     category = CATEGORY_DRAW,
--     effectType = EFFECT_TYPE_IGNITION,
--     range = LOCATION_MZONE,
--     countLimit = 1,
--     coinCount = 1
-- })

return CoinEffects