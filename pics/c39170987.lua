--Pot of Selfishness
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
	local ct=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
		e:SetLabel(ct)
		return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(et)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabel(ct)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,ct,REASON_EFFECT)
end
