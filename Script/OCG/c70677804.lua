--Chaos Emperor Dragon - Envoy of the Evening Twilight
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special Summon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Special Summon procedure
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	e2:SetLabel(ATTRIBUTE_LIGHT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetLabel(ATTRIBUTE_DARK)
	c:RegisterEffect(e3)
	--Banish a monster and 1 random card from the opponent's hand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(function(e) return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1 end)
	e5:SetCost(s.rmcost)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
	e2:SetLabelObject(e5)
	e3:SetLabelObject(e5)
end
function s.remfilter(c,att)
	return c:IsAttribute(att) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.remfilter2(c)
	return c:IsAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ct=Duel.GetMatchingGroupCount(Card.IsAttribute,tp,LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_DARK)
		and ct>0 and ct~=Duel.GetMatchingGroupCount(Card.IsAttribute,tp,LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)
		and Duel.IsExistingMatchingCard(s.remfilter2,tp,LOCATION_GRAVE,0,ct,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.remfilter,tp,LOCATION_GRAVE,0,nil,e:GetLabel())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:GetLabelObject():SetLabel(e:GetLabel())
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	if chk==0 then
		if e:GetLabel()==ATTRIBUTE_LIGHT then
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		elseif e:GetLabel()==ATTRIBUTE_DARK then
			return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil)
		end
	end
end
function s.rmfilter(c)
	return c:IsMonster()
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==ATTRIBUTE_DARK then
		local mg=Duel.GetFieldGroup(1-tp,LOCATION_MZONE,0):Filter(Card.IsAbleToRemove,nil)
		local gyc=Duel.GetMatchingGroupCount(s.rmfilter,tp,LOCATION_MZONE,0,nil)
			if gyc==0 then return end
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
			local bg=mg:Select(1-tp,gyc,gyc,nil)
			Duel.Remove(bg,POS_FACEUP,REASON_EFFECT)
		elseif e:GetLabel()==ATTRIBUTE_LIGHT then
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0):Filter(Card.IsAbleToRemove,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),ct,#g)
	if ft<1 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end