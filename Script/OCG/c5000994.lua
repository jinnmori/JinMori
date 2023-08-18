--Majestic Quasar Dragon
Duel.LoadScript("SP_CARDS.lua")
Duel.LoadScript("Archlua.lua")
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterSummonCode(CARD_MAJESTIC_DRAGON),1,1,Synchro.NonTuner(s.matfiler),1,1)
	c:EnableReviveLimit()
	--Synchro Level
	local syc1=Effect.CreateEffect(c)
	syc1:SetType(EFFECT_TYPE_SINGLE)
	syc1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	syc1:SetCode(id)
	syc1:SetRange(LOCATION_EXTRA)
	c:RegisterEffect(syc1)
		local syc2=Effect.CreateEffect(c)
		syc2:SetType(EFFECT_TYPE_SINGLE)
		syc2:SetCode(EFFECT_SYNCHRO_LEVEL)
		syc2:SetValue(function(e,c)
		local lv=e:GetHandler():GetLevel()
		return c:IsHasEffect(id) and ((11<<16)|lv) or lv
	end)
	local syc3=Effect.CreateEffect(c)
	syc3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	syc3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	syc3:SetRange(LOCATION_EXTRA)
	syc3:SetTargetRange(LOCATION_MZONE,0)
	syc3:SetTarget(s.syntg)
	syc3:SetLabelObject(syc2)
	c:RegisterEffect(syc3)
	--Negate the effects of all cards on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon) 
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Gain the targeted effects and replace the ATK with the targeted monster
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,id+1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.gaintg)
	e2:SetOperation(s.gainop)
	c:RegisterEffect(e2)
		--Negate the activation
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+2)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--Special Summon Shooting,Quasar or Cosmic Synchro Monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+3)
	e4:SetTarget(s.sumtg)
	e4:SetOperation(s.sumop)
	c:RegisterEffect(e4)
end
s.material={CARD_MAJESTIC_DRAGON}
s.listed_names={id,CARD_MAJESTIC_DRAGON}
s.listed_series={SET_STARDUST}
s.synchro_nt_required=1
function s.matfilter(c,val,scard,sumtype,tp)
	return c:IsRace(RACE_DRAGON,scard,sumtype,tp) and not c:IsAttribute(ATTRIBUTE_DARK,scard,sumtype,tp) and c:IsType(TYPE_SYNCHRO,scard,sumtype,tp) 
	and c:IsLevel(12,scard,sumtype,tp)
end
function s.syntg(e,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(12)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler() 
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,LOCATION_MZONE,LOCATION_MZONE,c):Filter(Card.IsCanBeDisabledByEffect,nil,e)
	if #g==0 then return end
	--Negate the effects of all cards
	local c=e:GetHandler()
	for tc in g:Iter() do
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
function s.gainfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and (c:IsDisabled() or c:IsStatus(STATUS_DISABLED))
end
function s.gaintg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.gainfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.gainfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.gainfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
function s.gainop(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsType(TYPE_TOKEN) then
		local code=tc:GetOriginalCodeRule()
		if not tc:IsType(TYPE_TRAPMONSTER) then
			c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
		local atk=tc:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
	and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,99,c)
	g:AddCard(c)
	e:SetLabel(#g)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,e:GetLabel()) and Duel.IsPlayerCanDraw(1-tp,e:GetLabel()) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,e:GetLabel())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoGrave(eg,REASON_EFFECT)
	end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT) then
		Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
		Duel.Draw(1-tp,e:GetLabel(),REASON_EFFECT)
	end
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
function s.sumfilter(c,e,tp)
	return (c:IsCosmic() or c:IsShooting() or c:IsSetCard(SET_STARDUST)) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetFlagEffect(id)>0
	and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		local sc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
		Duel.SpecialSummon(sc,0,tp,tp,true,true,POS_FACEUP)
	end
end