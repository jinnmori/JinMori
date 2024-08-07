--Yubel - Desperate Devil
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Cannot be Normal Summoned/Set
    c:EnableUnsummonable()
    --Must be Special Summoned by its own method
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(s.splimit)
    c:RegisterEffect(e1)
    --Special Summon procedure
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetRange(LOCATION_HAND)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    --Cannot be destroyed by battle
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetValue(1)
    c:RegisterEffect(e3)
    --No battle damage
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e4:SetValue(1)
    c:RegisterEffect(e4)
    --Inflict damage and destroy
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e5:SetCode(EVENT_BATTLE_START)
    e5:SetCondition(s.damcon)
    e5:SetTarget(s.damtg)
    e5:SetOperation(s.damop)
    c:RegisterEffect(e5)
    --Unaffected by targeting effects
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,1))
    e6:SetCategory(CATEGORY_DESTROY)
    e6:SetType(EFFECT_TYPE_QUICK_F)
    e6:SetCode(EVENT_CHAINING)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCondition(s.immcon)
    e6:SetTarget(s.immtg)
    e6:SetOperation(s.immop)
    c:RegisterEffect(e6)
end
function s.splimit(e,se,sp,st)
    return false
end
function s.spfilter(c,tp)
    return c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)
        and (c:IsControler(tp) or c:IsFaceup())
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.CheckReleaseGroup(tp,s.spfilter,1,false,1,true,c,tp,nil,false,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectReleaseGroup(tp,s.spfilter,1,1,false,true,true,c,nil,nil,false,nil,tp)
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    Duel.Release(g,REASON_COST)
    g:DeleteGroup()
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttackTarget()~=nil
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local bc=e:GetHandler():GetBattleTarget()
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetAttack())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc and bc:IsRelateToBattle() then
        local atk=bc:GetAttack()
        if Duel.Damage(1-tp,atk,REASON_EFFECT)~=0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #g>0 then
                Duel.Destroy(g,REASON_EFFECT)
            end
        end
    end
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    return tg and tg:IsContains(e:GetHandler())
end
function s.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetReset(RESET_CHAIN)
        e1:SetValue(function(e,te) return te==re end)
        c:RegisterEffect(e1)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end