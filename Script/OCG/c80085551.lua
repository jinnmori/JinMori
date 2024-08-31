--D/D/D Lost King Babel
local s,id=GetID()
function s.initial_effect(c)
    --Pendulum Summon
    Pendulum.AddProcedure(c)
    --Pendulum Effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.pentg)
    e1:SetOperation(s.penop)
    c:RegisterEffect(e1)
    --Reduce damage
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_DAMAGE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1,0)
    e2:SetCondition(s.damcon)
    e2:SetValue(s.damval)
    c:RegisterEffect(e2)
    --Negate effects
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_DD,SET_DARK_CONTRACT}
--Pendulum Effect functions
function s.penfilter(c)
    return c:IsSetCard(SET_DD) and c:IsType(TYPE_PENDULUM) and c:IsAbleToGrave()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK,0,1,nil) end
    local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 or not Duel.SendtoGrave(g,REASON_COST) then return end
    local tc=g:GetFirst()
    e:SetLabelObject(tc)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.isPendulumEffect(eff)
    local range=eff:GetRange()
    return (range&LOCATION_PZONE)~=0
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc=e:GetLabelObject()
    if tc and tc:IsLocation(LOCATION_GRAVE) then
      local effs={tc:GetCardEffect()}
      for _,eff in ipairs(effs) do
       if s.isPendulumEffect(eff) and eff:GetCode()~=id then -- Check if it's a Pendulum effect and prevent infinite loop
            local e1=eff:Clone()
            e1:SetRange(LOCATION_PZONE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
                end
            end
            --Change Code Name
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_CHANGE_CODE)
            e2:SetValue(tc:GetCode())
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e2)
            Duel.Damage(tp,1500,REASON_EFFECT)
        end
    end
function s.damcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetFlagEffect(tp,id)==0
end
function s.damval(e,re,val,r,rp,rc)
    local tp=e:GetHandlerPlayer()
    if val>=1500 and (r&REASON_EFFECT)~=0 and re and (re:GetHandler():IsSetCard(SET_DD) or re:GetHandler():IsSetCard(SET_DARK_CONTRACT)) then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        return 1000
    else
        return val
    end
end
function s.negfilter1(c,e)
    return (c:IsSetCard(SET_DARK_CONTRACT) or c:IsSetCard(SET_DD)) and c:IsFaceup() and c:IsCanBeDisabledByEffect(e) and c:IsCanBeEffectTarget(e)
end
function s.negfilter2(c,e)
    return c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:IsCanBeDisabledByEffect(e)
end
function s.rescon(sg,e,tp,mg)
    return sg:FilterCount(Card.IsControler,nil,tp)==1
        and sg:FilterCount(Card.IsControler,nil,1-tp)==1
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g1=Duel.GetMatchingGroup(s.negfilter1,tp,LOCATION_ONFIELD,0,e:GetHandler(),e)
    local g2=Duel.GetMatchingGroup(s.negfilter2,tp,0,LOCATION_ONFIELD,nil,e)
    local g=g1:Clone()
    g:Merge(g2)
    if chkc then return false end
    if chk==0 then return #g1>0 and #g2>0 end
    local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DISABLE)
    Duel.SetTargetCard(sg)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,2,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    local tc=g:GetFirst()
    while tc do
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
        tc:RegisterEffect(e2)
        tc=g:GetNext()
    end
end