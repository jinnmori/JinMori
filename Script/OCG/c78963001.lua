--Blue-Eyes Shining Nova Dragon
Duel.LoadScript("Archlua.lua")
local s,id=GetID()
function s.initial_effect(c)
c:SetUniqueOnField(1,1,id)
c:EnableReviveLimit()
	--cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	--cannot release
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4)
	--Cannot be targeted by opp card effect
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
		--negate
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetCountLimit(1)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.discon)
	e6:SetTarget(s.distg)
	e6:SetOperation(s.disop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_BLUE_EYES}
function s.ultimatedragonfilter(c)
	return c:IsFaceup() and c:IsUltimatedragon() and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsReleasable()
end
function s.blueeyesfilter(c)
	return c:IsSetCard(SET_BLUE_EYES) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g1=Duel.GetMatchingGroup(s.ultimatedragonfilter,tp,LOCATION_MZONE,0,nil)
    local g2=Duel.GetMatchingGroup(s.blueeyesfilter,tp,LOCATION_GRAVE,0,nil)
    return #g1>0 and #g2>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
end
function s.rescon(sg,e,tp,mg)
    return sg:FilterCount(s.ultimatedragonfilter,nil)==1
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
    local g1=Duel.GetMatchingGroup(s.ultimatedragonfilter,tp,LOCATION_MZONE,0,nil)
    local g2=Duel.GetMatchingGroup(s.blueeyesfilter,tp,LOCATION_GRAVE,0,nil)
    local g=aux.SelectUnselectGroup(g1+g2,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
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
    local tc1,tc2=g:GetFirst(),g:GetNext()
    if tc1 and tc2 then
        if tc1:IsLocation(LOCATION_MZONE) then
            Duel.Release(tc1,REASON_COST)
            Duel.Remove(tc2,POS_FACEUP,REASON_COST)
        else
            Duel.Release(tc2,REASON_COST)
            Duel.Remove(tc1,POS_FACEUP,REASON_COST)
        end
    end
    g:DeleteGroup()
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(Card.IsRace,0,LOCATION_GRAVE,LOCATION_GRAVE,nil,RACE_DRAGON)*300
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end