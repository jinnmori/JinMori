--Solfachord Metronome
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_series={SET_SOLFACHORD}
function s.filter(c,lv,e,tp)
    return c:IsSetCard(SET_SOLFACHORD) and c:IsType(TYPE_PENDULUM) and c:IsLevel(lv)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local lscale=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
    local rscale=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
    if chk==0 then return (lscale or rscale)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,lscale:GetLeftScale(),e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local lscale=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
    local rscale=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
    if not lscale then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,lscale:GetLeftScale(),e,tp)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
            --Cannot attack unless even scale
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            e1:SetCondition(s.atkcon)
            tc:RegisterEffect(e1)
            --Cannot activate effects unless odd scale
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_CANNOT_TRIGGER)
            e2:SetCondition(s.effcon)
            tc:RegisterEffect(e2)
            --Indestructible if both scales present
            local e3=Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
            e3:SetCondition(s.indcon)
            e3:SetValue(1)
            tc:RegisterEffect(e3)
            local e4=e3:Clone()
            e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            tc:RegisterEffect(e4)
        end
    end
end
function s.atkcon(e)
    local tp=e:GetHandlerPlayer()
    return not Duel.IsExistingMatchingCard(Card.IsEvenScale,tp,LOCATION_PZONE,0,1,nil)
end
function s.effcon(e)
    local tp=e:GetHandlerPlayer()
    return not Duel.IsExistingMatchingCard(Card.IsOddScale,tp,LOCATION_PZONE,0,1,nil)
end
function s.indcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(Card.IsEvenScale,tp,LOCATION_PZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsOddScale,tp,LOCATION_PZONE,0,1,nil)
end