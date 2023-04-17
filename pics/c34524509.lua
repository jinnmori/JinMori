--Borrelguard-eXecution-Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Xyz summon procedure
	Xyz.AddProcedure(c,nil,4,3)
	--Destroy all cards on the field execpt this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descond)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--inflict 500 damage to your opponent for each
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.damcost)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.descond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetChainLimit(s.chainlm)
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		if #sg>0 then
		Duel.Destroy(sg,REASON_EFFECT)
		--this turn Cannot Enter Battle Phase
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
		end
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
		local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetOperation(s.damop2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.cfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cfilter,1,nil) then
		Duel.Damage(1-tp,#eg*500,REASON_EFFECT)
	end
end
