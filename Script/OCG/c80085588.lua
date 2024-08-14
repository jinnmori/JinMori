--Chaos Armed Dragon
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Special Summon procedure
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Special Summon banished monsters
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetTarget(s.sstg)
    e2:SetOperation(s.ssop)
    c:RegisterEffect(e2)
    --Banish and gain ATK
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCountLimit(1)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.rmcost)
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)
end
function s.spfilter(c,att)
    return c:IsAttribute(att) and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,ATTRIBUTE_LIGHT)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,ATTRIBUTE_DARK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)
    local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)
    local g=aux.SelectUnselectGroup(g1+g2,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_REMOVE)
    if #g>0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    Duel.Remove(g,POS_FACEUP,REASON_COST)
    c:SetMaterial(g)
    g:DeleteGroup()
end
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) and e:GetHandler():GetMaterial()
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_REMOVED)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
    local g=e:GetHandler():GetMaterial()
    if #g~=2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
    local sg1=g:Select(tp,1,1,nil)
    local sg2=g-sg1
    if #sg1>0 and #sg2>0 then
        Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
        Duel.SpecialSummon(sg2,0,tp,1-tp,false,false,POS_FACEUP)
    end
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,100) end
    local lp=Duel.GetLP(tp)
    local m=math.floor(math.min(lp,2800)/100)
    local t={}
    for i=1,m do
        t[i]=i*100
    end
    local ac=Duel.AnnounceNumber(tp,table.unpack(t))
    Duel.PayLPCost(tp,ac)
    e:SetLabel(ac)
end
function s.rmfilter(c,atk)
    return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
    local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local lp=e:GetLabel()
    local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE,nil,lp)
    if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(lp)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END,2)
        c:RegisterEffect(e1)
    end
end