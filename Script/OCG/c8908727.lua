--Galatea, the Orcust of the Dark Star
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--You can only Special Summon "Galatea, the Orcust of the Dark Star(s)" once per turn
	c:SetSPSummonOnce(id)
	--Xyz Summon Procedure
	Xyz.AddProcedure(c,nil,6,2,s.ovfilter,aux.Stringid(id,0))
	--Cannot be destroyed by battle or card effects during opponent turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE)
	e1:SetValue(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.incon)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetCost(aux.dxmcostgen(1,1))
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={SET_ORCUST}
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsType(TYPE_LINK,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(SET_ORCUST,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.incon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local tc=Duel.GetFirstTarget()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end