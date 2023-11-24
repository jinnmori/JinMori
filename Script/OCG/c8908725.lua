--Carya, the Orcust Automaton
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,99,s.lcheck)
	--Cannot be destroyed by battle or card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	--Add 1 Orcust monster and 1 Orcust spell/trap
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon1)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(s.thcon2)
	c:RegisterEffect(e4)
end
s.listed_series={SET_ORCUST}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_MACHINE,lc,sumtype,tp)
end
function s.indcon(e)
	return e:GetHandler():IsLinked()
end
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsPlayerAffectedByEffect(tp,CARD_ORCUSTRATED_BABEL)
end
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,CARD_ORCUSTRATED_BABEL)
end
function s.tdfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil,tp)
end
function s.thfilter1(c,tp)
	return c:IsAbleToHand() and c:IsSetCard(SET_ORCUST) and c:IsMonster() and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,tp)
end
function s.thfilter2(c,tp)
	return c:IsAbleToHand() and c:IsSetCard(SET_ORCUST) and c:IsSpellTrap()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.tdfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,2,nil,tp) end
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,2,2,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	if not Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_DECK|LOCATION_EXTRA) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil,tp)
	local cc=g1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,tp)
	g1:Merge(g2)
		Duel.BreakEffect()
		Duel.SendtoHand(g1,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1)
	end