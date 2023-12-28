--Frightfur Fox
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Fusion summon procedure
	Fusion.AddProcMix(c,true,true,30068120,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_FLUFFAL))
	--Send 1 Edge imp monster to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.sencost)
	e1:SetTarget(s.sentg)
	e1:SetOperation(s.senop)
	c:RegisterEffect(e1)
	--Activation limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0,1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.actcon)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.desreptg)
	c:RegisterEffect(e3)
end
s.listed_series={SET_EDGE_IMP,SET_FLUFFAL}
s.material_setcode={SET_FLUFFAL,SET_EDGE_IMP}
s.listed_names={30068120}

function s.tgfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_EDGE_IMP) and c:IsAbleToGraveAsCost()
end
function s.sencost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.sentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.senop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
		--This Card Gains 500 Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.actcon(e)
local tp=e:GetHandlerPlayer()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return rc and rc:IsLocation(LOCATION_HAND)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then	return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT) and c:GetAttack()>=1000 end
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		--You can have it lose 1000 Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
		return true
	else return false end
end