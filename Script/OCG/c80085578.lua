--Evil HERO Revenge Smog
local s,id=GetID()
function s.initial_effect(c)
    --On Summon effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    --Activate Supreme King's Castle
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,4))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e3:SetCost(aux.bfgcost)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.actg)
    e3:SetOperation(s.acop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_HERO}
s.listed_names={72043279}
function s.herofilter(c,e,tp)
	return c:IsSetCard(SET_HERO) and (c:IsAbleToHand() 
	or (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_HERO),tp,LOCATION_GRAVE,0,1,nil)
    local b2=Duel.IsExistingTarget(s.herofilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    if chk==0 then return b1 or b2 end
    local op=Duel.SelectEffect(tp,
        {b1,aux.Stringid(id,1)},
        {b2,aux.Stringid(id,2)})
    e:SetLabel(op)
    if op==2 then
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local g=Duel.SelectTarget(tp,s.herofilter,tp,LOCATION_GRAVE,0,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==1 then
        local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_HERO),tp,LOCATION_GRAVE,0,nil)
        Duel.Damage(1-tp,ct*300,REASON_EFFECT)
    elseif op==2 then
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) then
            aux.ToHandOrElse(tc,tp,
                function(c)
                    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
                end,
                function(c)
                    Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
                end,
                aux.Stringid(id,3)
            )
        end
    end
end
function s.actfilter(c,tp)
    return c:IsCode(72043279) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    if tc then
        local te=tc:GetActivateEffect()
        local b=te:IsActivatable(tp,true,true)
        if b then
            Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
        end
    end
end