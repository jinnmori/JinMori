--The Phantom knights of Legendary Knight 
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),5,2,s.ovfilter,aux.Stringid(id,0))
		--Change the position of all monsters on the field 
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.poscon)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
		--attack all
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(aux.dxmcostgen(1,1,nil))
	e2:SetCondition(s.multcon)
	e2:SetOperation(s.multop)
	c:RegisterEffect(e2)
		--pierce
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetCondition(s.pircon)
	c:RegisterEffect(e3)
end
s.listed_series={SET_THE_PHANTOM_KNIGHTS,SET_REBELLION}

function s.ovfilter(c,tp,sc)
	return c:IsFaceup() and (c:IsSetCard(SET_THE_PHANTOM_KNIGHTS,sc,SUMMON_TYPE_XYZ,tp) or c:IsSetCard(SET_REBELLION,sc,SUMMON_TYPE_XYZ,tp)) and c:GetRank()<=4 and
	c:IsType(TYPE_XYZ,sc,SUMMON_TYPE_XYZ,tp)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.posfilter(c)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
		local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local def=tc:GetDefense()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(def/2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		end
end
function s.filter(c)
	return c:IsSetCard(SET_THE_PHANTOM_KNIGHTS) and c:IsType(TYPE_XYZ) 
end
function s.multcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ov=c:GetOverlayGroup()
	return ov:IsExists(s.filter,1,nil)
end
function s.multop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
end
function s.filter2(c)
	return c:IsSetCard(SET_REBELLION) and c:IsType(TYPE_XYZ) 
end
function s.pircon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ov=c:GetOverlayGroup()
	return ov:IsExists(s.filter2,1,nil)
end