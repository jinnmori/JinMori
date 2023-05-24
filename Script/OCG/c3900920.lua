--Fluffal Fox
local s,id=GetID()
function s.initial_effect(c)
	--Search 1 "Polymerization" and apply effects in sequence
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_FLUFFAL,SET_EDGE_IMP,SET_FRIGHTFUR}
s.listed_names={70245411,id}

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.thfilter(c)
	return c:IsCode(CARD_POLYMERIZATION) and c:IsAbleToHand()
end
function s.filter(c)
	local fl=c:IsSetCard(SET_FLUFFAL) and c:IsMonster()
	local ei=c:IsSetCard(SET_EDGE_IMP) and c:IsMonster()
	local fritfur=c:IsSetCard(SET_FRIGHTFUR) and c:IsType(TYPE_FUSION) and c:IsMonster()
	local toyv= c:IsCode(70245411)
	return c:IsFaceup() and (fl or ei or fritfur or toyv)
end
function s.fusfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_FRIGHTFUR) and c:IsType(TYPE_FUSION) and c:IsMonster()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	local des=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	local sp=c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return #g>0
		and ((g:IsExists(s.fusfilter,1,nil) and des) 
		or (g:IsExists(Card.IsCode,1,nil,70245411) and sp)) or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	if g:IsExists(Card.IsSetCard,1,nil,SET_FLUFFAL) then 
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
if g:IsExists(Card.IsSetCard,1,nil,SET_EDGE_IMP) then 
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
if g:IsExists(s.fusfilter,1,nil) then 
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
if g:IsExists(Card.IsCode,1,nil,70245411) then 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	--apply the following effects in sequence
	if fg:IsExists(Card.IsSetCard,1,nil,SET_FLUFFAL) then 
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
	if fg:IsExists(Card.IsSetCard,1,nil,SET_EDGE_IMP) then 
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
	if fg:IsExists(s.fusfilter,1,nil) then 
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if #dg>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local sg=dg:Select(tp,1,1,nil)
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
			local sp=c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			if fg:IsExists(Card.IsCode,1,nil,70245411) and sp then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end