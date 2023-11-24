--Pygmalion, the Orcust Automaton
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,nil,s.matcheck)
	--Cannot be destroyed by battle while it is linked
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(function(e) return e:GetHandler():IsLinked() end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Shuffle 1 Machine monster into the Deck to special summon 1 "Orcust"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.spcon2)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ORCUST}
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_ORCUST,lc,sumtype,tp)
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsPlayerAffectedByEffect(tp,CARD_ORCUSTRATED_BABEL)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,CARD_ORCUSTRATED_BABEL)
end
function s.tdfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ORCUST) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.tdfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)
	if not Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_DECK|LOCATION_EXTRA) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
end