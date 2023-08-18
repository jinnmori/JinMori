--Chaos Emperor Dragon - Super Emperor Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--Banish that opponent monster that battles with this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(s.bttlremtg)
	e1:SetOperation(s.bttlremop)
	c:RegisterEffect(e1)
end
function s.bttlremtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsFaceup() and bc:IsAttributeExcept(ATTRIBUTE_WIND) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function s.bttlremop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end