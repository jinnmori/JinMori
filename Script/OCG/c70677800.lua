--Magician of Dark Magic
Duel.LoadScript("Category.lua")
local s,id=GetID()
function s.initial_effect(c)
	--its treated as Normal monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_HAND)
	e1:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_REMOVE_TYPE)
	e2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e2)
	--Set 1 "Dark Magical Circle" or add 1 spell/trap
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--destroy 1 Random Card your opponent controls
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
s.listed_names={CARD_DARK_MAGICIAN_GIRL,CARD_DARK_MAGICIAN,47222536,28553439}
function s.sthfilter(c,mg,tp)
	if mg then
	return (c:IsCode(28553439) or (c:ListsCode(CARD_DARK_MAGICIAN) and c:IsSpellTrap()) and c:IsAbleToHand() and c:IsLocation(LOCATION_DECK))
	else
	return c:IsCode(47222536) and c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end
end
function s.mgfilter(c)
	return c:IsCode(CARD_DARK_MAGICIAN_GIRL) or (c:IsRace(RACE_SPELLCASTER) and c:IsLevel(7) and c:IsMonster())
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=Duel.IsExistingMatchingCard(s.mgfilter,tp,LOCATION_MZONE,0,1,c)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sthfilter,tp,LOCATION_DECK,0,1,nil,mg,tp) end 
	if Duel.IsExistingMatchingCard(s.sthfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,mg,tp) and mg then
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif Duel.IsExistingMatchingCard(s.sthfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,mg,tp) and not mg then
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.IsExistingMatchingCard(s.mgfilter,tp,LOCATION_MZONE,0,1,c)
	local g=Duel.SelectMatchingCard(tp,s.sthfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,mg,tp)
	if #g>0 then
		if mg then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		else
		Duel.SSet(tp,g)		
		end
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
		local hg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		if #hg>0 then
			local cg=hg:RandomSelect(tp,1)
			local cc=cg:GetFirst()
		Duel.Destroy(cc,REASON_EFFECT)
	end
end