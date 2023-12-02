--Sky Striker Ace - Izumi
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SKY_STRIKER),4,2,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--Disable the effects of monsters your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Double the Original ATK of a Sky Striker Ace monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&REASON_LINK>0 and e:GetHandler():GetReasonCard():IsSetCard(SET_SKY_STRIKER_ACE) end)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}
s.listed_names={id}
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsType(TYPE_LINK,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsSetCard(SET_SKY_STRIKER_ACE,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.disfilter(c)
	return c:IsSpell() and c:IsSetCard(SET_SKY_STRIKER)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.disfilter,tp,LOCATION_GRAVE,0,nil)
	local cg=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #cg>0 and ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,0,1-tp,LOCATION_ONFIELD)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ct=Duel.GetMatchingGroupCount(s.disfilter,tp,LOCATION_GRAVE,0,nil)
	local cg=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sg=cg:Select(tp,1,ct,nil)
		if #sg==0 then return end
		Duel.HintSelection(sg,true)
		Duel.BreakEffect()
		for tc in aux.Next(sg) do
		--Negate its effects
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--Double the original Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(rc:GetTextAttack()*2)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1)
end