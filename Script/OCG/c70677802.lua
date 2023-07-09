--Mudragon Mud
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()
		--fusion substitute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(s.subcon)
	c:RegisterEffect(e1)
	--Add 1 "Polymerization" or 1 "Fusion" Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.dxmcostgen(1,1))
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--fusion summon summon
	local e3=Fusion.CreateSummonEff({handler=c,nil,matfilter=s.matfilter,extrafil=s.fextra,extraop=s.extraop,extratg=s.extratarget})
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(aux.dxmcostgen(1,1))
	e3:SetCountLimit(1,id)
	c:RegisterEffect(e3)
end
s.listed_series={SET_FUSION}

function s.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsSetCard(SET_FUSION) and c:IsSpell() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.matfilter(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK) and c:IsAbleToGrave())
		or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove())
end
function s.fextra(e,tp,mg)
	local loc=LOCATION_DECK 
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		loc=loc|LOCATION_GRAVE
	end
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove or Card.IsAbleToGrave),tp,loc,0,nil)
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end