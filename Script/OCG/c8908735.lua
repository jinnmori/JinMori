--Sky Striker Ace - Asahi
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SKY_STRIKER),4,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	--double damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetOperation(s.damop)
	e1:SetCountLimit(1)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--A Sky Striker Ace Monster Link Summoned using this card cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&REASON_LINK>0 and e:GetHandler():GetReasonCard():IsSetCard(SET_SKY_STRIKER_ACE) end)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsType(TYPE_LINK,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsSetCard(SET_SKY_STRIKER_ACE,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--any damage is inflicted by "Sky Striker Ace" monster is doubled
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetTarget(s.damfilter)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	Duel.RegisterEffect(e1,tp)
	--pierce
	local e2=e1:Clone()
	e2:SetCode(EFFECT_PIERCE)
	Duel.RegisterEffect(e2,tp)
end
function s.damfilter(e,c)
	return c:IsSetCard(SET_SKY_STRIKER_ACE)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3000)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1)
end