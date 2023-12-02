--Sky Striker Ace - Kagari Fast Mode
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--Activation limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCountLimit(1)
	e1:SetValue(1)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
	--you can have this card gains ATK equal to all "Sky Striker Ace" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE) 
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.adcon)
	e2:SetOperation(s.adop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}
function s.matfilter(c,lc,st,tp)
	return c:IsSetCard(SET_SKY_STRIKER,lc,st,tp) and c:IsType(TYPE_LINK,lc,st,tp)
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and (e:GetHandler():GetLinkedGroup():IsContains(bc) or bc:GetLinkedGroup():IsContains(e:GetHandler()))
end
function s.atkfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsLinkMonster()
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_GRAVE,0,nil)
	if #g>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=g:GetSum(Card.GetAttack)
		local def=g:GetSum(Card.GetDefense)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(def)
		c:RegisterEffect(e2)
		end
	end
end
