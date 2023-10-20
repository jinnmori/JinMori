--Ultimate Crystal Infinity Rainbow Dragon
local s,id=GetID()
function s.initial_effect(c)
--creating table for Crystal Beast Monsters to be added in strings
 	s.index_t = {36795102,7093411,69937550,95600067,21698716,32933942,68215963,32710364,71620241,18847598,72843899,45236142,19963185,46358784,83575471}
	for i,code in ipairs(s.index_t) do --Suppose `t` is a table containing the ids of all Crystal Beast monsters
    s.index_t[code]=i==1 and 0 or i-1
	   end
	--Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,s.mfilter2,1,99,s.mfilter1)
	--Send 1 "Crystal Beast" monster to the GY and gain 1000 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(980891,3))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Negate the activation of card/effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(980891,4))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.negcon)
	e2:SetCountLimit(1)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--Place itself into pendulum zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86238081,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
	--Check For materials for Fusion Summoning
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	--Pendulum Effect
	local pe1=Effect.CreateEffect(c)
	pe1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	pe1:SetType(EFFECT_TYPE_IGNITION)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCountLimit(1,id)
	pe1:SetCost(s.pecost)
	pe1:SetTarget(s.petg)
	pe1:SetOperation(s.peop)
	c:RegisterEffect(pe1)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
	--Register Card Names used
	aux.GlobalCheck(s,function()
		s.code_list={}
		s.code_list[0]={}
		s.code_list[1]={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_LEAVE_FIELD)
		ge1:SetCountLimit(1)
		ge1:SetCondition(s.resetop)
		Duel.RegisterEffect(ge1,0)
	   end)
	end
s.listed_series={SET_ULTIMATE_CRYSTAL,SET_CRYSTAL_BEAST,SET_CRYSTAL}
s.listed_materials={SET_ULTIMATE_CRYSTAL,SET_CRYSTAL_BEAST}
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	s.code_list[0]={}
	s.code_list[1]={}
	return false
end
function s.mfilter1(c,fc,sumtype,tp)
	return c:IsSetCard(SET_ULTIMATE_CRYSTAL,fc,sumtype,tp)
end
function s.mfilter2(c,fc,sumtype,tp)
	return c:IsSetCard(SET_CRYSTAL_BEAST,fc,sumtype,tp)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_CRYSTAL_BEAST) and c:IsAbleToGraveAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,1000)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetValue(1000)
		c:RegisterEffect(e1)
	end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negfilter(c,e,tp)
	local code=c:GetCode()
	return c:IsSetCard(SET_CRYSTAL_BEAST) and c:IsMonster() and c:IsAbleToDeckAsCost() and not s.code_list[tp][code]
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local rg=Duel.SelectMatchingCard(tp,s.negfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetCode())
	Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local name=e:GetLabel()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
	s.code_list[tp][name] = name
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(980892,s.index_t[name]))
end
function s.valcheck(e,c)
	if c:GetMaterial():FilterCount(Card.IsSetCard,nil,SET_CRYSTAL_BEAST)>=2
	then e:GetLabelObject():SetLabel(1) 
	end
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()==1
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.pefilter(c,e,tp)
	return c:IsSetCard(SET_CRYSTAL) and c:IsSpellTrap() and c:IsAbleToDeckAsCost() 
	and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,card)
	return c:IsSetCard(SET_CRYSTAL_BEAST) and not c:IsCode(card) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.pecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pefilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.pefilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetCode())
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function s.petg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.peop(e,tp,eg,ep,ev,re,r,rp)
	local card=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,card)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end