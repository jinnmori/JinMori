--Samsara B Lotus
local s,id=GetID()
function s.initial_effect(c)
    --Discard and Tribute
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_RELEASE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.tribcost)
    e1:SetTarget(s.tribtg)
    e1:SetOperation(s.tribop)
    c:RegisterEffect(e1)
    --Destroy Yubel monster if destroyed
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
    --Add to hand or Special Summon during End Phase
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_YUBEL}
s.listed_names={78371393}
function s.tribcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.tribtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
    return c:IsSetCard(SET_YUBEL) and c:IsMonster() and c:IsAbleToHand()
end
function s.tribop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    if #g>0 and Duel.Release(g,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #sg>0 then
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
    end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.desfilter(c)
    return c:IsSetCard(SET_YUBEL) and c:IsMonster() and c:IsAbleToGrave()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,78371393),tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0 and c:IsAbleToHand() then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    elseif Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end