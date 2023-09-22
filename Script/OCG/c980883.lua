--Void Desperation
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
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.filter(c,e)
    return c:IsFaceup() and c:IsSetCard(SET_INFERNOID) and c:IsType(TYPE_MONSTER)
        and c:IsLevelBelow(10) and c:IsCanBeEffectTarget(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e) end
    if chk==0 then return g:CheckWithSumGreater(Card.GetLevel,11,1) end
    local sg=Group.CreateGroup()
    repeat
        local tc=g:SelectUnselect(sg,tp,sg:CheckWithSumGreater(Card.GetLevel,11),false,1,3)
        if tc then
            if sg:IsContains(tc) then sg:RemoveCard(tc)
            else sg:AddCard(tc) end
        end
    until sg:CheckWithSumGreater(Card.GetLevel,11) and (#sg>2 or #sg>0 and not Duel.SelectYesNo(tp,210))
    Duel.SetTargetCard(sg)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoDeck(Duel.GetTargetCards(e),nil,1,REASON_EFFECT)
end