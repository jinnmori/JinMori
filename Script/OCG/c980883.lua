--Void Desperation
Duel.LoadScript("SP_CARDS.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_series={SET_INFERNOID}
s.listed_names={CARD_INFERNOID_TIERRA}
function s.filter(c)
    return c:IsFaceup() and c:IsSetCard(SET_INFERNOID) and c:IsType(TYPE_MONSTER)
        and c:IsLevelBelow(10)
end
function s.rmgfilter(c)
    return c:IsMonster() and c:IsType(TYPE_EFFECT)
end
function s.rescon(sg,e,tp,mg)
    return sg:GetSum(Card.GetLevel)>=11
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) end
	if chk==0 then return #g>0 and aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon,0) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x143,0x11,3400,3600,5,RACE_FIEND,ATTRIBUTE_FIRE) end
    local tg=aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon,1,tp,HINTMSG_TODECK,s.rescon)
    Duel.SetTargetCard(tg)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x143,0x11,3400,3600,11,RACE_FIEND,ATTRIBUTE_FIRE) then return end
   if Duel.SendtoDeck(tg,nil,1,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.rmgfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil) then
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct==0 then return end
	Duel.BreakEffect()
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
	c:AddMonsterAttributeComplete()
	--change code
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(CARD_INFERNOID_TIERRA)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1,true)
	Duel.SpecialSummonComplete()
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
	local dg=Duel.SelectMatchingCard(tp,s.rmgfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,ct,nil)
	Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
		end
	end
end