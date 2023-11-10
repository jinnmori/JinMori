--Tearlaments Lorulay
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA),2,2)
	--disable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.distg)
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
end
function s.pointfilter(c,tp,lg)
	return c:IsType(TYPE_FUSION) and lg:IsContains(c)
end
function s.distg(e,c)
	local tp=e:GetHandlerPlayer()
	local lg=e:GetHandler():GetLinkedGroup()
	local g=Duel.GetMatchingGroup(s.pointfilter,tp,LOCATION_MZONE,0,nil,tp,lg)
	local atk=g:GetSum(Card.GetAttack)
	return #g>0 and c:IsType(TYPE_MONSTER) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT and g:GetSum(Card.GetLevel)==c:GetAttack()
end