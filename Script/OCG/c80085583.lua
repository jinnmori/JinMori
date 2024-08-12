--Umbral Horror Creepy Beast
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon from hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Add DARK Fiend monster to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end
s.listed_series={SET_UMBRAL_HORROR}
s.listed_names={id}

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
   return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttackAbove,2000),tp,0,LOCATION_MZONE,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_UMBRAL_HORROR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=g:Select(tp,1,1,nil)
            if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
                local tg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_UMBRAL_HORROR),tp,LOCATION_MZONE,0,nil)
                if #tg>0 then
                    for tc in aux.Next(tg) do
                        local e1=Effect.CreateEffect(c)
                        e1:SetType(EFFECT_TYPE_SINGLE)
                        e1:SetCode(EFFECT_XYZ_LEVEL)
                        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                        e1:SetValue(s.xyzlv)
                        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                        tc:RegisterEffect(e1)
                    end
                end
            end
        end
        --Restrict Special Summons
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e2:SetDescription(aux.Stringid(id,3))
        e2:SetTargetRange(1,0)
        e2:SetTarget(s.splimit)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)
    end
end
function s.xyzlv(e,c,rc)
    if rc:IsType(TYPE_XYZ) then
        return 1,2,3
    else
        return e:GetHandler():GetLevel()
    end
end
function s.splimit(e,c)
    return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_MZONE,0,1,nil)
end
function s.thfilter(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end