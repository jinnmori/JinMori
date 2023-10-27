--Aromage Mint
local s,id=GetID()
function s.initial_effect(c)
	--opponent cannot send cards from their deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(s.ntgcon)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_DECK)
	c:RegisterEffect(e1)
	--Inflict 500 Damage each time you gain LP
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EVENT_RECOVER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
function s.ntgcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end