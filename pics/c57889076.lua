--Starliege Photon Paladin
local s,id=GetID()
function s.initial_effect(c) 
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),4,2,nil,nil,99)
	c:EnableReviveLimit()
	--Treat it's Level as 4
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.lvtg)
	e1:SetValue(s.lvval)
	c:RegisterEffect(e1)
	--Apply the Appropriate Effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
	s.listed_series={SET_PHOTON,SET_GALAXY}
	
function s.lvtg(e,c)
local tp=e:GetHandlerPlayer()
	return c:HasLevel() and c:GetOwner()==tp
end
function s.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc:IsCode(id) then return 4
	else return lv end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local add=s.addtg(e,tp,eg,ep,ev,re,r,rp,0) --Add 1 "Photon" or "Galaxy" Card from deck to hand
	local sp=s.sptg(e,tp,eg,ep,ev,re,r,rp,0) --Special Summon 1 "Photon" or 1 "Galaxy" monster from your deck
	local remo=s.remotg(e,tp,eg,ep,ev,re,r,rp,0) --Banish all spell/trap cards your opponent controls 
	local remo2=s.remotg2(e,tp,eg,ep,ev,re,r,rp,0) --Banish all monsters your opponent controls 
	local ct
	if add then ct = 2 end
	if sp then ct = 3 end
	if remo then ct = 4 end
	if remo2 then ct = 5 end
	if chk==0 then return (add or sp or remo or remo2) and c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
	local selections={}
	if add and c:CheckRemoveOverlayCard(tp,2,REASON_COST) then
		table.insert(selections,2)
	end
	if sp and c:CheckRemoveOverlayCard(tp,3,REASON_COST) then
		table.insert(selections,3)
	end
	if remo and c:CheckRemoveOverlayCard(tp,4,REASON_COST) then
		table.insert(selections,4)
	end
	if remo2 and c:CheckRemoveOverlayCard(tp,5,REASON_COST) then
		table.insert(selections,5)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local sel=Duel.AnnounceNumber(tp,table.unpack(selections))
	c:RemoveOverlayCard(tp,sel,sel,REASON_COST)
	if sel==2 then
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
	elseif sel==3 then
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
	elseif sel==4 then
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
		else 
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,4))
	end
	e:SetLabel(sel)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end --legality handled in cost by necessity
	local sel=e:GetLabel()
	if sel==2 then
		s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	elseif sel==3 then
		s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	elseif sel==4 then
		s.remotg(e,tp,eg,ep,ev,re,r,rp,chk)
		else 
		s.remotg2(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==2 then
		s.addop(e,tp,eg,ep,ev,re,r,rp)
	elseif sel==3 then
		s.spop(e,tp,eg,ep,ev,re,r,rp)
	elseif sel==4 then
		s.remoop(e,tp,eg,ep,ev,re,r,rp)
		else
		s.remoop2(e,tp,eg,ep,ev,re,r,rp)
	end
end
--Add 1 "Photon" or "Galaxy" card from your Deck to your hand.
function s.addfilter(c)
	return c:IsSetCard({SET_GALAXY,SET_PHOTON}) and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	function s.addop(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
--Special Summon 1 "Photon" or "Galaxy" monster from your Deck.
function s.spfilter(c,e,tp)
	return c:IsSetCard({SET_PHOTON,SET_GALAXY}) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--Banish all Spells/Traps your opponent controls.
function s.remotg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,nil) end
	local sg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
function s.remoop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
		if #sg>0 then
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
--Banish all monsters your opponent controls.
function s.remotg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
function s.remoop2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
		if #sg>0 then
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
