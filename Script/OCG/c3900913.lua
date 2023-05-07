--Remains of the Golden Land 
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE))
	--cannot target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetValue(aux.tgoval)
	e1:SetCondition(s.tgocon)
	c:RegisterEffect(e1)
	--indes
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
	--Draw 1 Card
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.dracon)
	e3:SetTarget(s.dratg)
	e3:SetOperation(s.draop)
	c:RegisterEffect(e3)
end
function s.tgocon(e,c)
	local et=e:GetHandler():GetEquipTarget()
	return et:IsType(TYPE_NORMAL) and et:IsMonster() 
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
function s.dracon(e,tp,eg,ep,ev,re,r,rp)
	local et=e:GetHandler():GetEquipTarget()
	return ep==e:GetOwnerPlayer() and et==re:GetHandler() and re:IsActivated() and et:IsSetCard(SET_ELDLICH) and et:IsMonster() 
end
function s.dratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.draop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end