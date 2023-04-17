--Harpie Phantom Gryphon 
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_HARPIE_LADY,{74852097,s.ffilter})
	--Remove all spell/traps cards your opponent controls 
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.Remcon)
	e1:SetTarget(s.Remtg)
	e1:SetOperation(s.Remop)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
		--cannot be target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.condition)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	--cannot be destroyed
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.condition)
	e5:SetValue(aux.indoval)
	c:RegisterEffect(e5)
	--Decrease the ATK of monster your opponent controls
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetValue(s.atkval)
	c:RegisterEffect(e6)
		--Negate the activation of card/effect
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e7:SetCode(EVENT_CHAINING)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetCondition(s.negcon)
	e7:SetCost(s.negcost)
	e7:SetTarget(s.negtg)
	e7:SetOperation(s.negop)
	c:RegisterEffect(e7)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
	end
s.material={CARD_HARPIE_LADY,74852097}
s.listed_names={CARD_HARPIE_LADY,74852097}
s.material_setcode={SET_HARPIE}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(SET_HARPIE,fc,sumtype,tp) and c:IsMonster(fc,sumtype,tp)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_NORMAL,c,SUMMON_TYPE_FUSION) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.Remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.Remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_SZONE)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.Remop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_SZONE)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer() 
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_HARPIE_LADY)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsCode,e:GetHandler():GetControler(),LOCATION_GRAVE+LOCATION_MZONE,0,nil,CARD_HARPIE_LADY)*-100
end
	--Card/effect activated
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
	--Check for "Harpie Lady"
function s.negfilter(c)
	return c:IsCode(CARD_HARPIE_LADY) and (not c:IsOnField() or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
end
	--Banish 1 "Harpie Lady" from face-up field/GY as cost
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	local rg=Duel.SelectMatchingCard(tp,s.negfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
	--Activation legality
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
	--Negate the activation of card/effect, and if you do, Destroy it
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end