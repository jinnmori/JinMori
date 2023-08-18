--Number U39: Utopic Astral
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,4,4,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	--Add 1 "Rank-Up-Magic" or 1 "Rank-Down-Magic"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
		--Equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(aux.dxmcostgen(1,1))
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={SET_RANK_UP_MAGIC,SET_RANK_DOWN_MAGIC,SET_ZW} 
s.listed_names={48333324,45950291,71345905}
s.xyz_number=39
function s.cfilter(c)
	return (c:IsSetCard(SET_RANK_UP_MAGIC) or c:IsSetCard(SET_RANK_DOWN_MAGIC)) and c:IsSpell() and c:IsAbleToGraveAsCost()
end
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsRank(4)
end
function s.xyzop(e,tp,chk,mc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil):SelectUnselect(Group.CreateGroup(),tp,false,Xyz.ProcCancellable)
	if tc then
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
		return true
	else return false end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	 local c=e:GetHandler()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and c:GetFlagEffect(id)~=0
end
--Check for "ZW -" monster
function s.thfilter(c)
	return (c:IsSetCard(SET_RANK_UP_MAGIC) or c:IsSetCard(SET_RANK_DOWN_MAGIC)) and c:IsSpell() and c:IsAbleToHand()
end
	--Activation legality
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.disfilter(c)
	return (c:IsFaceup() or c:IsType(TYPE_TRAPMONSTER)) and not (c:IsType(TYPE_NORMAL) and c:GetOriginalType()&TYPE_NORMAL>0)
end
function s.spellfilter(c)
	return c:IsSpell() and c:IsAbleToHand()
end
	--Add 1 "ZW -" monster from deck
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsCode(48333324) then
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
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
			elseif tc:IsCode(45950291) then
				local g=Duel.SelectTarget(tp,s.spellfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst() 
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			elseif tc:IsCode(71345905) then
		--actlimit
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTargetRange(0,1)
			e1:SetValue(1)
			e1:SetCondition(s.actcon)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.eqfilter(c,tc,tp)
	if not (c:IsSetCard(SET_ZW) and not c:IsForbidden()) then return false end
	local effs={c:GetCardEffect(75402014)}
	for _,te in ipairs(effs) do
		if te:GetValue()(tc,c,tp) then return true end
	end
	return false
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler(),tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_EXTRA)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_EXTRA,0,1,1,nil,c,tp)
	local tc=g:GetFirst()
	if tc then
		local eff=tc:GetCardEffect(75402014)
		eff:GetOperation()(tc,eff:GetLabelObject(),tp,c)
	end
end