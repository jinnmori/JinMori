--Number C60:Laplace the Omincemnet
local s,id=GetID()
function s.initial_effect(c)
    -- XYZ Summon
    Xyz.AddProcedure(c,nil,5,3)
    c:EnableReviveLimit()
    -- Indestructible by battle or card effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetCondition(s.indcon)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    c:RegisterEffect(e2)
    -- Negate effects
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.negcon)
    e3:SetCost(aux.dxmcostgen(2,2,nil))
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end
s.xyz_number=60
function s.indcon(e)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
        return (Duel.IsMainPhase() and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and rp==1-tp) 
            or (Duel.IsBattlePhase() and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev) and rp==1-tp)
    end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsChainNegatable(ev) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:IsActiveType(TYPE_MONSTER) then
        Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
    else
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        if re:IsActiveType(TYPE_MONSTER) then
            Duel.Damage(1-tp,1200,REASON_EFFECT)
        elseif re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end
