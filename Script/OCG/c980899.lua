--Topologic Warrior
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--This Linked Card Unaffected by Card's effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.imfilter)
	c:RegisterEffect(e1)
	--Link-3 or higher Cyberse Monsters are Unaffected
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(_,c) return c:IsType(TYPE_LINK) and c:IsLinkAbove(3) end)
	e2:SetValue(function(e,te) return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() end)
	c:RegisterEffect(e2)
	--Move itself to 1 of your unused MMZ
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.seqcon)
	e3:SetCost(s.seqcost)
	e3:SetTarget(s.seqtg)
	e3:SetOperation(s.seqop)
	c:RegisterEffect(e3)
	--atk down x its Link Markers
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
function s.imcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	return c:IsLinked()
end
function s.imfilter(e,te)
  local tp=e:GetHandlerPlayer()
	return te:GetOwnerPlayer()==1-tp
end
function s.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	if tp~=p then
	return Duel.CheckLPCost(tp,1500) else return true
	end
end
function s.seqcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local p=e:GetHandler():GetControler()
    if chk==0 then
        return tp~=p and Duel.CheckLPCost(tp,1500) or true
    end
    if tp~=p then Duel.PayLPCost(tp,1500) 
	end
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local p=e:GetHandler():GetControler()
	if chk==0 then return Duel.GetLocationCount(p,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOZONE)
	local seq=Duel.SelectDisableField(p,1,LOCATION_MZONE,0,0)
	Duel.Hint(HINT_ZONE,p,seq)
	e:SetLabel(math.log(seq,2))
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp,chk)
	 local p=e:GetHandler():GetControler()
	local c=e:GetHandler()
	local seq=e:GetLabel()
	if not c:IsRelateToEffect(e) or not Duel.CheckLocation(p,LOCATION_MZONE,seq) then return end
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOZONE)
	Duel.MoveSequence(c,seq)
end
function s.atkfilter(c,self)
	local lg=c:GetLinkedGroup()
	return lg and lg:IsContains(self)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)
	return c==Duel.GetAttacker() and bc and bc:IsFaceup() and g and #g>0
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLinkMonster),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        if #g==0 then return end
        local ct=0
        for tc in g:Iter() do
            if tc:GetLinkedGroup():IsContains(c) then
                ct=ct+1
            end
        end
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetReset(RESET_PHASE|PHASE_END)
        e1:SetValue(-ct*300)
        bc:RegisterEffect(e1)
    end
end