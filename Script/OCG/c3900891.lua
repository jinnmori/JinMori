--Honor Palladium Oracle
local s,id=GetID()
function s.initial_effect(c)
	--Special summon itself from hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
-----Here We Have the Effects for the Cards to Activate based on Type-----
	--negate the activation
	local neg=Effect.CreateEffect(c)
	neg:SetCategory(CATEGORY_NEGATE)
	neg:SetType(EFFECT_TYPE_QUICK_O)
	neg:SetDescription(aux.Stringid(id,2))
	neg:SetCode(EVENT_CHAINING)
	neg:SetRange(LOCATION_MZONE)
	neg:SetCountLimit(1,id)
	neg:SetCondition(s.discon)
	neg:SetTarget(s.distg)
	neg:SetOperation(s.disop)
	c:RegisterEffect(neg)
	--Add 1 Quick Spell card
	local qui=Effect.CreateEffect(c)
	qui:SetDescription(aux.Stringid(id,3))
	qui:SetCategory(CATEGORY_TOHAND)
	qui:SetType(EFFECT_TYPE_QUICK_O)
	qui:SetCode(EVENT_CHAINING)
	qui:SetProperty(EFFECT_FLAG_CARD_TARGET)
	qui:SetRange(LOCATION_MZONE)
	qui:SetCountLimit(1,id)
	qui:SetCondition(s.thcon)
	qui:SetTarget(s.thtg)
	qui:SetOperation(s.thop)
	c:RegisterEffect(qui)
	--Draw 2 cards, then discard 1 card
	local dra=Effect.CreateEffect(c)
	dra:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE)
	dra:SetDescription(aux.Stringid(id,4))
	dra:SetType(EFFECT_TYPE_QUICK_O)
	dra:SetCode(EVENT_CHAINING)
	dra:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	dra:SetRange(LOCATION_MZONE)
	dra:SetCountLimit(1,id)
	dra:SetCondition(s.drcon)
	dra:SetTarget(s.drtg)
	dra:SetOperation(s.drop)
	c:RegisterEffect(dra)
	--Banish that monster
	local rem=Effect.CreateEffect(c)
	rem:SetCategory(CATEGORY_REMOVE)
	rem:SetDescription(aux.Stringid(id,5))
	rem:SetType(EFFECT_TYPE_QUICK_O)
	rem:SetCode(EVENT_CHAINING)
	rem:SetRange(LOCATION_MZONE)
	rem:SetCountLimit(1,id)
	rem:SetCondition(s.remcon)
	rem:SetTarget(s.remtg)
	rem:SetOperation(s.remop)
	c:RegisterEffect(rem)
	--Special Summon 1 level 4 or lower monster from your GY
	local sp=Effect.CreateEffect(c)
	sp:SetCategory(CATEGORY_SPECIAL_SUMMON)
	sp:SetDescription(aux.Stringid(id,6))
	sp:SetType(EFFECT_TYPE_QUICK_O)
	sp:SetCode(EVENT_CHAINING)
	sp:SetRange(LOCATION_MZONE)
	sp:SetCountLimit(1,id)
	sp:SetCondition(s.spcon1)
	sp:SetTarget(s.sptg1)
	sp:SetOperation(s.spop1)
	c:RegisterEffect(sp)
	--------------------
end
s.listed_names={id}
function s.cfilter(c,tp)
	return (c:GetPreviousTypeOnField()&TYPE_SPELL==TYPE_SPELL or c:GetPreviousTypeOnField()&TYPE_TRAP==TYPE_TRAP)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.setfilter(c)
	return c:IsSpellTrap() and not c:IsFieldSpell() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSSetable()
end
function s.ownerfilter(c,p)
	return c:GetOwner()==p
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local ft1=Duel.GetLocationCount(tp,LOCATION_SZONE) --your spell/trap zones
		local ft2=Duel.GetLocationCount(1-tp,LOCATION_SZONE) --your opponent's spell/trap zones
		local setg=eg:Filter(s.setfilter,nil) --let's filter in eg by the cards that can actually be set
		if #setg==0 then return end --no card to set
		local setg1=setg:Filter(s.ownerfilter,nil,tp) --here we have your cards
		local setg2=setg:Filter(s.ownerfilter,nil,1-tp) --here we have your opponent's cards
		if (ft1>=#setg1 or ft2>=setg2) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then --number of zones is enough to set all the cards and the player says yes
			Duel.BreakEffect()
			Duel.SSet(tp,setg1,tp,true)
			Duel.SSet(tp,setg2,1-tp,true)
		end
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and re:IsActiveType(TYPE_EFFECT) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_FUSION) and Duel.IsChainNegatable(ev)
end
function s.thfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_SYNCHRO) and Duel.IsChainNegatable(ev)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		Duel.ShuffleHand(p)
		Duel.BreakEffect()
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
function s.remcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_XYZ) and Duel.IsChainNegatable(ev)
end
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler():IsRelateToEffect(re) then
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
	local rc=eg:GetFirst()
		rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(rc)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function s.spfilter1(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_LINK) and Duel.IsChainNegatable(ev)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and 
	Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end