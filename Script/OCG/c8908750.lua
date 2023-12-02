--Sky Striker Mecha - Scorpion Gladius
local s,id=GetID()
function s.initial_effect(c)
	--equip Procedure
	aux.AddEquipProcedure(c,nil,nil,nil,nil,nil,nil,s.condition)
	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetCondition(s.atkcon)
	c:RegisterEffect(e1)
	--Double any damage
	--double
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0x115}
function s.cfilter(c)
	return c:GetSequence()<5
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	local ec=e:GetHandler():GetEquipTarget()
	return ec and (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and ec:IsRelateToBattle()
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local eq=e:GetHandler():GetEquipTarget()
	if eq~=re:GetHandler() then return false end
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if ex then return true end
	if not ex then return false end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetValue(s.dammul)
	e2:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e2,tp)
end
function s.dammul(e,re,val,r,rp,rc)
	return HALF_DAMAGE
end
