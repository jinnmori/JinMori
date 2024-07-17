--King's Counter
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Banish effect
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.immtg)
    e2:SetOperation(s.immop)
    c:RegisterEffect(e2)
    --Check deck and extra deck
    if not s.global_check then
        s.global_check=true
        s.resonators={}
        s.red_dragons={}
        s.dark_dragons={}
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_STARTUP)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
    end
end
s.listed_series={SET_RESONATOR,SET_RED_DRAGON_ARCHFIEND}
s.listed_names={CARD_RED_DRAGON_ARCHFIEND,66141736}
function s.RDAfilter(c)
	return c:IsSetCard(SET_RED_DRAGON_ARCHFIEND) and c:IsType(TYPE_SYNCHRO)
end
function s.lvl12filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(12) and c:IsType(TYPE_SYNCHRO)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,SET_RESONATOR)
    local g2=Duel.GetMatchingGroup(s.RDAfilter,tp,LOCATION_EXTRA,0,nil)
    local g3=Duel.GetMatchingGroup(s.lvl12filter,tp,LOCATION_EXTRA,0,nil)
    s.resonators[tp]=#g1>=6 and g1:GetClassCount(Card.GetCode)>=6
    s.red_dragons[tp]=#g2>=3 and g2:GetClassCount(Card.GetCode)>=3
    s.dark_dragons[tp]=#g3>=2 and g3:GetClassCount(Card.GetCode)>=2
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
        and s.resonators[tp] and s.red_dragons[tp] and s.dark_dragons[tp]
end
function s.thfilter(c)
    return c:IsSetCard(SET_RESONATOR) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
    return c:IsCode(66141736) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
        and Duel.IsExistingMatchingCard(aux.AND(Card.IsMonster,Card.IsAbleToDeck),tp,LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g1=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g1>0 and Duel.SendtoHand(g1,nil,REASON_EFFECT)>0 then
            Duel.ConfirmCards(1-tp,g1)
            if Duel.GetLocationCountFromEx(tp,tp,nil,nil)>0 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local g2=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
                if #g2>0 and Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)>0 then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
                    local g3=Duel.SelectMatchingCard(tp,aux.AND(Card.IsMonster,Card.IsAbleToDeck),tp,LOCATION_HAND,0,1,1,nil)
                    if #g3>0 then
                        Duel.SendtoDeck(g3,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
						end
                    end
                end
            end
        end
    end
function s.immfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_RED_DRAGON_ARCHFIEND) and c:IsType(TYPE_SYNCHRO)
end
function s.immtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.immfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.immfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.immfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(id,0)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetValue(s.efilter)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        if tc:IsCode(CARD_RED_DRAGON_ARCHFIEND) then
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetDescription(id,1)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_IMMUNE_EFFECT)
            e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            e2:SetValue(s.efilter2)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
end
function s.efilter(e,te)
    return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.efilter2(e,te)
    return te:IsActiveType(TYPE_MONSTER) and te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end