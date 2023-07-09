--Chalice, Lady of Lament
Duel.LoadScript("Effects.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Either add 1 normal trap or Set it on the field 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.cfilter(c,ignore)
	return c:IsNormalTrap() and (c:IsAbleToHand() or c:IsSSetable(ignore))
end
function s.filter(c)
	return c:IsMonster() and c:IsReleasable() and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,filter,2,true,nil,nil) and Duel.IsExistingMatchingCard(cfilter,tp,LOCATION_DECK,0,1,nil,false) end
		local sg=Duel.SelectReleaseGroupCost(tp,s.filter,2,2,true,nil,nil)
		Duel.Release(sg,REASON_COST)
	end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,false) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil,false):GetFirst()
	aux.ToHandOrSet(tc,tp)
	--it can be activated this turn 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetDescription(aux.Stringid(id,3))
		tc:RegisterEffect(e1)
	end