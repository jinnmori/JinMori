--Galaxy Elite 
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),4,2)
	c:EnableReviveLimit()
		-- Check materials on Xyz Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--Add 1 "Photon" or "Galaxy" card from your deck to your hand 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Target 1 Photon or Galaxy monster in GY, special summon it
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
 s.listed_series={SET_GALAXY,SET_PHOTON}

 function s.xmatfilter(c)
   return (c:IsSetCard(SET_GALAXY) or c:IsSetCard(SET_PHOTON)) and c:IsMonster()
  end
	function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.xmatfilter,1,nil) then
		local reset=RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END
		c:RegisterFlagEffect(id,reset,0,1)
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:GetFlagEffect(id)>0
end
function s.thfilter(c)
  return (c:IsSetCard(SET_PHOTON) or c:IsSetCard(SET_GALAXY)) and c:IsAbleToHand()
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
function s.spfilter(c,e,tp)
  return (c:IsSetCard(SET_GALAXY) or c:IsSetCard(SET_PHOTON)) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
 local c=e:GetHandler()
 local tc=Duel.GetFirstTarget()
 if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		if tc:IsCode(93717133) then 
		--This card cannot be destroyed by battle or card effects until the end of next turn 
		  local e1=Effect.CreateEffect(c)
		  e1:SetType(EFFECT_TYPE_SINGLE)
		  e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		  e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		  e1:SetRange(LOCATION_MZONE)
		  e1:SetValue(1)
		  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		  c:RegisterEffect(e1)
		  local e2=e1:Clone()
		  e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		  c:RegisterEffect(e2)
		  end
	end
end