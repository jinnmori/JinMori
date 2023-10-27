--Borrel Reform
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local rparams={lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),des=aux.Stringid(id,1),extrafil=s.extrafil,extraop=s.extraop,matfilter=s.forcedgroup,extratg=s.extratg,}
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate(Ritual.Target(rparams),Ritual.Operation(rparams)))
	c:RegisterEffect(e1)
end
s.listed_series={SET_ROKKET}
s.listed_names={id}
---Ritual Requirments and functions
function s.mfilter(c,e)
	return c:HasLevel() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsMonster() and c:IsDestructable(e)
end
function s.forcedgroup(c,e,tp)
	return c:HasLevel() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsMonster() and c:IsDestructable(e) and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_HAND))
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,e)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(mat,REASON_EFFECT+REASON_RITUAL+REASON_MATERIAL)
end
--------------
function s.thfilter(c,code)
	return c:IsSetCard(SET_ROKKET) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(code)
end
function s.desfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_ROKKET) and c:IsMonster() 
	and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.desfilter(chkc,c,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_TOHAND,c,1,0,0)
end
function s.activate(rittg,ritop)
	return function(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
		if rittg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			ritop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end
