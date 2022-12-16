--Number C95: Neo Galaxy-Eyes Dark Matter Dragon
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),10,3,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--Cannot be used as Xyz material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--attach 1 Dragon monster from your Extra Deck, field or GY to this card as material; then banish 1 card face-down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.attcost)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
	--Can Make Up to 3 Attacks
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.atkcon)
	e3:SetCost(s.atkcost)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end
s.xyz_number=95
s.listed_series={SET_GALAXY_EYES}

	function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard(SET_GALAXY_EYES,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) 
	 and not c:IsSummonCode(xyzc,SUMMON_TYPE_XYZ,tp,id)
end
function s.costfilter(c,lv)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
end
function s.attcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.attfilter(c)
 return c:IsRace(RACE_DRAGON)	and c:IsMonster()
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local all=LOCATION_MZONE|LOCATION_EXTRA|LOCATION_GRAVE 
	if chk==0 then return Duel.IsExistingMatchingCard(s.attfilter,tp,all,0,1,c) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE+LOCATION_GRAVE)
 end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local all=LOCATION_MZONE|LOCATION_EXTRA|LOCATION_GRAVE 
	if c:IsFaceup() then
	local g=Duel.SelectMatchingCard(tp,s.attfilter,tp,all,0,1,1,c)
	local tc=g:GetFirst()
	Duel.Overlay(c,tc)
	local rem=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	Duel.Remove(rem,POS_FACEDOWN,REASON_EFFECT)
	end
end
function s.ovfilter(c)
 return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) 
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() 
	  and e:GetHandler():GetOverlayGroup():IsExists(s.ovfilter,1,nil) and Duel.IsAbleToEnterBP()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0
		and e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK_MONSTER)==0 end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
