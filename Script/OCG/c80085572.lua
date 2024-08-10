--Number C32: Shark Drake Full Armor Veiss
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
   Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),5,3,s.ovfilter,aux.Stringid(id,0))
    --Second attack
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_BATTLE_DESTROYING)
    e1:SetCondition(s.atcon)
    e1:SetOperation(s.atop)
    c:RegisterEffect(e1)
    --Attach destroyed monsters
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.atcon2)
    e2:SetCost(aux.dxmcostgen(1,1,nil))
    e2:SetTarget(s.attg)
    e2:SetOperation(s.atop2)
    c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
    --Indestructible
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetCondition(s.indcon)
    e3:SetValue(1)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e4)
end
s.xyz_number=32
s.listed_names={65676461} --Number 32: Shark Drake
function s.ovfilter(c,tp,xyzc)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsAttribute(ATTRIBUTE_WATER,xyzc,SUMMON_TYPE_XYZ,tp) and rk==4
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
    return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():CanChainAttack()
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
    Duel.ChainAttack()
end
function s.atcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetBattledGroup():GetCount()>0
end
function s.atfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
        and c:GetTurnID()==Duel.GetTurnCount() and c:IsAbleToChangeControler()
end

function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.atfilter,tp,0,LOCATION_GRAVE,1,nil) end
end

function s.atop2(e,tp,eg,ep,ev,re,r,p)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.atfilter,tp,0,LOCATION_GRAVE,nil)
    if #g>0 then
        Duel.Overlay(c,g)
    end
end
function s.indcon(e)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,65676461)
end