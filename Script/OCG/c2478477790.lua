--Synchro Determination
Duel.LoadScript("SP_CARDS.lua") 
local s,id=GetID()
function s.initial_effect(c)
c:EnableCounterPermit(COUNTER_DETERMINATION)
	aux.AddPersistentProcedure(c,0,aux.FaceupFilter(Card.IsType,TYPE_SYNCHRO),nil,nil,0x1c0,0x1c1,nil,nil,nil)
	--Activate 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e1)
--Substitute destruction once for the targeted monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	--self destroy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADD_COUNTER+COUNTER_DETERMINATION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.counter_place_list={COUNTER_DETERMINATION}
function s.repfilter(c,e)
	return aux.PersistentTargetFilter(e,c) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable(e) and eg:IsExists(s.repfilter,1,nil,e)
		and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) end
		return e:GetHandler():IsCanAddCounter(COUNTER_DETERMINATION,1)
end
function s.repval(e,c)
	return s.repfilter(c,e)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
   local ct=c:GetCounter(COUNTER_DETERMINATION)
	e:GetHandler():AddCounter(COUNTER_DETERMINATION,1)
	if c:GetCounter(COUNTER_DETERMINATION)>ct then
		Duel.RaiseEvent(c,EVENT_ADD_COUNTER+COUNTER_DETERMINATION,e,REASON_EFFECT,tp,tp,1)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(COUNTER_DETERMINATION)>=3
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if Duel.Destroy(c,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
	--That targeted synchro monster atk is doubled
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(tc:GetAttack())
	tc:RegisterEffect(e1)
	end
end
