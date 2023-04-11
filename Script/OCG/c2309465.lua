--Harpie Disciple 
local s,id=GetID()
function s.initial_effect(c)
	--Change name to "Harpie Lady"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(CARD_HARPIE_LADY)
	c:RegisterEffect(e1)
	--Copy the Card
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.copytg)
	e2:SetOperation(s.copyop)
	c:RegisterEffect(e2)
	--Activate 1 of this effects
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(s.target)
	e3:SetCountLimit(1)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_series={SET_HARPIE}
s.listed_names={CARD_HARPIE_LADY,id}
  function s.copyfilter(c)
	return (c:IsSetCard(SET_HARPIE) and c:IsLevelAbove(4) and c:IsMonster() and ((c:IsFaceup() and c:IsLocation(LOCATION_MZONE)) or c:IsLocation(LOCATION_GRAVE))) 
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.copyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.copyfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.copyfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE+CATEGORY_LVCHANGE+CATEGORY_DEFCHANGE,e:GetHandler(),1,0,0)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
	--Level change 
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	--Atk change
	local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK)
		e2:SetValue(tc:GetAttack())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e2)
	--Def Change
	local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_DEFENSE)
		e3:SetValue(tc:GetDefense())
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e3)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsSetCard(SET_HARPIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
	function s.addfilter(c)
	return c:IsSetCard(SET_HARPIE) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
		local b1=Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil)
		local b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	e:SetCategory(0)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND)
		local g=Duel.GetMatchingGroup(s.addfilter,tp,LOCATION_DECK,0,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
		elseif op==2 then
		  e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		  local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,tp,LOCATION_DECK)
		 end
	end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	elseif op==2 then
	  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,2,2,nil,e,tp)
		if #g1>0 then
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		      end
		   end
   end