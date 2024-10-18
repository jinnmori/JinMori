--Arcana Force X - The Wheel of Fortune
Duel.LoadScript("Coin.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY),2,2,s.lcheck)
	--Coin toss effect on Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.cointg)
	e1:SetOperation(s.coinop)
	c:RegisterEffect(e1)
	--Banish from GY to treat coin tosses as heads
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.bancon)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x5,lc,sumtype,tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.tgfilter(c)
	return c.toss_coin and c:IsAbleToGrave()
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local res=Duel.TossCoin(tp,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local tc=g:GetFirst()
		local coinResult = (res == 1) and CoinEffects.COIN_HEADS or CoinEffects.COIN_TAILS
		local targetCard = (coinResult == CoinEffects.COIN_HEADS) and c or Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
		if targetCard then
			CoinEffects.registerEffect(tc:GetOriginalCode(), coinResult, function(e,tp,eg,ep,ev,re,r,rp)
				-- Implement the effect for the specific coin result here
				if coinResult == CoinEffects.COIN_HEADS then
					-- Heads effect
					Duel.Draw(tp,1,REASON_EFFECT)
				else
					-- Tails effect
					Duel.Damage(tp,500,REASON_EFFECT)
				end
			end)
			local e1 = CoinEffects.createCoinEffect(tc, {
				descriptionId = coinResult + 1,
				effectType = EFFECT_TYPE_IGNITION,
				range = LOCATION_MZONE,
				countLimit = 1,
				operation = function(e,tp,eg,ep,ev,re,r,rp)
					CoinEffects.applyEffect(tc:GetOriginalCode(), coinResult, e, tp, eg, ep, ev, re, r, rp)
				end
			})
			targetCard:RegisterEffect(e1)
		end
	end
end
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasCategory(CATEGORY_COIN)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_ALL,LOCATION_ALL)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_COIN_NEGATE)
	e1:SetCondition(s.changecon)
	e1:SetOperation(s.changeop)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function s.changecon(e,tp,eg,ep,ev,re,r,rp)
	return ev&(1<<tp)~=0
end
function s.changeop(e,tp,eg,ep,ev,re,r,rp)
	local res={Duel.GetCoinResult()}
	local ct=ev&0xff
	for i=1,ct do res[i]=1 end
	Duel.SetCoinResult(table.unpack(res))
end