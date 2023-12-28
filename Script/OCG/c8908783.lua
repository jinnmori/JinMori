--Gravekeeper's Escort
local s,id=GetID()
function s.initial_effect(c)
	--cannot be battle target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	--ATK change
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_GRAVEKEEPERS}
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_GRAVEKEEPERS) and c:IsMonster() and c~=e:GetHandler()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
function s.atkfilter(c)
	return (c:IsFaceup() or not c:IsOnField()) and c:IsSetCard(SET_GRAVEKEEPERS) and c:IsMonster()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=0
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,c)
		local bc=g:GetFirst()
		for bc in aux.Next(g) do
			atk=atk+bc:GetAttack()
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
	--cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_OATH)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.ftarget)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	end
end
function s.ftarget(e,c)
	return e:GetHandler()~=c:GetFieldID()
end