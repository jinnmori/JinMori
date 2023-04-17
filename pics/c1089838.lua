--Galaxy-Eyes Photon Rainbow Dragon
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,9,3,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--Cannot be used as Xyz material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--your opponent cannot activate card effects until the end of the Damage Step
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
	--Returns the ATK and DEF of your opponent's face-up monsters on the field to their original values
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.retcost)
	e3:SetTarget(s.rettg)
	e3:SetOperation(s.retop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	end
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsRank(8) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.retfilter(c)
	return c:IsFaceup() and ((c:GetBaseAttack()~=c:GetAttack()) or (c:GetBaseDefense()~=c:GetDefense()))
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.retfilter,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(s.retfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE,sg,#sg,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.retfilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(tc:GetBaseAttack())
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetBaseDefense())
		tc:RegisterEffect(e2)
	end
end