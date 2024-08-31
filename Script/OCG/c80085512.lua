--Dark Magician Labrynth Girl
local s,id=GetID()
function s.initial_effect(c)
    --Gain ATK
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
    --Spells/Traps cannot be destroyed
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetTarget(function(e,_c) return _c:IsSpellTrap() end)
    e2:SetValue(s.indval)
    c:RegisterEffect(e2)
    --Negate Trap and banish
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_LABRYNTH}
function s.atkfilter(c)
    return c:IsType(TYPE_MONSTER) and (c:IsSetCard(SET_LABRYNTH) or c:IsRace(RACE_SPELLCASTER))
end
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil)*200
end
function s.indval(e,re,rp)
    return e:GetHandler():GetControler()~=tp
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then
            Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
        end
    end
end
