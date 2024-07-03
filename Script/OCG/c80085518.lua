--Link Conflict
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return a and d and a:IsLinkMonster() and d:IsLinkMonster()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsLinkMonster,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=math.floor(g:GetSum(Card.GetLink)/4)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsLinkMonster,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=math.floor(g:GetSum(Card.GetLink)/4)
	if ct>0 then
		local dr=Duel.Draw(tp,ct,REASON_EFFECT)
		if dr>0 then
			local tc=Duel.GetAttacker()
			if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
			if tc:IsRelateToBattle() and tc:IsFaceup() then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(dr*1000)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
end