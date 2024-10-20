--Graceful Dealings
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
    --Draw during End Phase
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
    --Banish from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(aux.exccon)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.hdtg)
    e3:SetOperation(s.hdop)
    c:RegisterEffect(e3)
    if not s.global_check then
        s.global_check=true
        s.discard_count={}
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetCondition(s.handspcon)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
        local ge2=Effect.CreateEffect(c)
        ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge2:SetCode(EVENT_TURN_END)
        ge2:SetOperation(s.clear_count)
        Duel.RegisterEffect(ge2,0)
    end
end
function s.handspconfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_HAND)
end
function s.handspcon(e,tp,eg,ep,ev,re,r,rp)
	local c= e:GetHandler()
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.handspconfilter,1,c,tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local p=eg:GetFirst():GetControler()
    if not s.discard_count[p] then s.discard_count[p]=0 end
    s.discard_count[p]=s.discard_count[p]+#eg
end

function s.clear_count(e,tp,eg,ep,ev,re,r,rp)
    s.discard_count[0]=0
    s.discard_count[1]=0
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetTurnID()==Duel.GetTurnCount()
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local ct=math.min(s.discard_count[tp] or 0, 3)+1
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(ct)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end

function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.hdop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end