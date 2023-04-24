--Flying Train Cartridge Case
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),4,2)
	c:EnableReviveLimit()
	--Prevent effect target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(s.condition)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--Prevent destruction by effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	--Inflict damage to your opponent 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(aux.dxmcostgen(1,1,nil))
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	e3:SetHintTiming(TIMING_STANDBY_PHASE+TIMING_END_PHASE)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	--Special Summon 1 Rank 10 using this card as material 
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(function(e) local tp=e:GetHandlerPlayer() local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g>0 and g:FilterCount(Card.IsRace,nil,RACE_MACHINE)==#g end)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,1,1,nil)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetAttack() 
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Damage(1-tp,atk/2,REASON_EFFECT)
	end
end
function s.spfilter(c,e,tp,mc,pg)
	return c:IsFacedown() and c:GetRank()==10 and c:IsType(TYPE_XYZ) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 
	and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and mc:IsCanBeXyzMaterial(c,tp) and (not pg or #pg<=0 or pg:IsContains(mc))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,1)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c,pg)
	local sc=g:GetFirst()
	if sc then
		Duel.BreakEffect()
		sc:SetMaterial(Group.FromCards(c))
		Duel.Overlay(sc,c)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		end
end