--Odd-Eyes Arc Rebellion Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Enable pendulum summon
	Pendulum.AddProcedure(c,false)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--4 Level 12 monsters
	Xyz.AddProcedure(c,nil,12,4,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	--spsummon limit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.xyzlimit)
	c:RegisterEffect(e0)
	--Name becomes "Supreme King Dragon Z-ARC" while on the field or in the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(CARD_ZARC)
	c:RegisterEffect(e1)
	--negate the effects of all face-up cards your opponent controls until the end phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(aux.dxmcostgen(1,1))
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--Inflict 1000 Damage and place it in Pendulum zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.pzcon)
	e3:SetTarget(s.pztg)
	e3:SetOperation(s.pzop)
	c:RegisterEffect(e3)
	--Prevents search
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	e5:SetRange(LOCATION_PZONE)
	e5:SetTargetRange(0,LOCATION_DECK)
	c:RegisterEffect(e5)
	--Negate the activation
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetRange(LOCATION_PZONE)
	e5:SetCondition(s.discon)
	e5:SetTarget(s.distg)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
end
s.listed_names={CARD_ZARC}

function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsOriginalCode(CARD_ZARC)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	return true
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	 local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g1>0 end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g1,#g1,0,0)
end
function s.disfilter(c)
	return (c:IsFaceup() or c:IsType(TYPE_TRAPMONSTER)) and not (c:IsType(TYPE_NORMAL) and c:GetOriginalType()&TYPE_NORMAL>0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
		if #g1==0 then return end
		Duel.BreakEffect()
		local ng=g1:Filter(s.disfilter,nil)
		for nc in aux.Next(ng) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			nc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			nc:RegisterEffect(e2)
			if nc:IsType(TYPE_TRAPMONSTER) then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				nc:RegisterEffect(e3)
		end
	end
end
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetOverlayCount()==0
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Damage(p,d,REASON_EFFECT)>0 then
	if not Duel.CheckPendulumZones(tp) then return false end
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and (re:IsActiveType(TYPE_MONSTER+TYPE_FUSION) or re:IsActiveType(TYPE_MONSTER+TYPE_SYNCHRO) or re:IsActiveType(TYPE_MONSTER+TYPE_XYZ) or 
		re:IsActiveType(TYPE_MONSTER+TYPE_PENDULUM)) and ep==1-tp and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SendtoDeck(c,nil,0,REASON_EFFECT)
	if Duel.NegateActivation(ev) then
		if re:GetHandler():IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
