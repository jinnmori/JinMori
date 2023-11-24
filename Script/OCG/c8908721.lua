--Kentauros, the Orcust Frame
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--This Linked Card Cannot be Targated by Card's effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.ntgcon)
	e1:SetValue(s.ntgfilter)
	c:RegisterEffect(e1)
	--Choose the opponent's attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.chsatkcon)
	c:RegisterEffect(e2)
	--Your opponent takes the battle damage involving Orcust monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.bdcon)
	e3:SetOperation(s.bdop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ORCUST}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_ORCUST,scard,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end
function s.ntgcon(e)
	return e:GetHandler():IsLinked()
end
function s.ntgfilter(e,te)
  local tp=e:GetHandlerPlayer()
	return te:GetOwnerPlayer()==1-tp
end
function s.chsatkcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_DARK)==#g
end
function s.bdcon(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and d:IsSetCard(SET_ORCUST) and d:IsMonster()
end
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--Opponent takes the battle damage instead
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3008)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end