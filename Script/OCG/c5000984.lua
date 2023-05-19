--Number 39: Utopia Arc Slasher 
local s,id=GetID()
function s.initial_effect(c)
	--Can only control one
	c:SetUniqueOnField(1,0,id)
	--xyz summon
	Xyz.AddProcedure(c,nil,6,3,s.ovfilter,aux.Stringid(id,3),4,s.xyzop)
	c:EnableReviveLimit()
		--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.tgcon)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
		--Equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(aux.dxmcostgen(1,1))
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
		--negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--special summon from Extra Deck 1 "Number"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetCountLimit(1)
	e4:SetCost(s.spcost)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_UTOPIA,SET_ZW,SET_NUMBER}
s.listed_names={id}
s.xyz_number=39

function s.cfilter(c)
	return c:IsSetCard(SET_ZW) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(SET_UTOPIA,lc,SUMMON_TYPE_XYZ,tp) and c:GetRank()==4
end
function s.xyzop(e,tp,chk,mc)
	local loc=LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,loc,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,loc,0,3,3,nil)
	if g then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
		return true
	else return false end
end
function s.tgcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_UTOPIA)
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
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_REMOVED,0,1,nil,e:GetHandler(),tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_REMOVED)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=1 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_REMOVED,0,1,2,nil,c,tp)
	for tc in g:Iter() do
		local eff=tc:GetCardEffect(75402014)
		eff:GetOperation()(tc,eff:GetLabelObject(),tp,c)
	end
end
function s.tgfilter(c,tp)
	return c:IsAbleToDeck() and c:IsSetCard(SET_ZW)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and e:GetHandler():GetEquipGroup():IsExists(s.tgfilter,1,nil,tp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=c:GetEquipGroup():FilterSelect(tp,s.tgfilter,1,1,nil)
	local tc=g:GetFirst()
	if #g>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
	local tc=g:GetFirst()
	if tc then
	Duel.NegateActivation(ev)
	end
end
function s.tgfilter2(c,tp,e,self,pg)
	return c:IsSetCard(SET_ZW) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,self,pg)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	if chk==0 then return c:GetEquipGroup():IsExists(s.tgfilter2,1,nil,tp,e,c,pg) end
	local g=c:GetEquipGroup():FilterSelect(tp,s.tgfilter2,1,2,nil,tp,e,c,pg)
	Duel.Overlay(c,g,true)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.spfilter(c,e,tp,mc,pg)
	return c:IsSetCard(SET_NUMBER) and c:GetRank()<=12 and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c,tp) and (#pg<=0 or pg:IsContains(mc)) 
	and c.xyz_number and c.xyz_number>=1 and c.xyz_number<=100 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
	end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		return #pg<=1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,pg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c,pg)
	local sc=g:GetFirst()
	if sc then
		local mg=c:GetOverlayGroup()
		if #mg~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(c))
		Duel.Overlay(sc,Group.FromCards(c))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end