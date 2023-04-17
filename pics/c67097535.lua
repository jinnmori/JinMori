--Odd-Eyes Performapal Magician of Timegazing
local s,id=GetID()
function s.initial_effect(c)
  c:SetUniqueOnField(1,0,id)
  --pendulum summon
	Pendulum.AddProcedure(c)
	--change name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(20409757)
	c:RegisterEffect(e1)
 --Special summon itself from hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Make it's Atk Becomes
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.swicon)
	e3:SetOperation(s.switop)
	c:RegisterEffect(e3)
	--Add 1 "Odd-Eyes", "Performapal" or 1 "Magician" from your deck to your hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(aux.bdgcon)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
	--actlimit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_PZONE)
	e5:SetCondition(s.actcon)
	e5:SetOperation(s.actop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e6)
	--Scale become 4
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_CHANGE_LSCALE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_PZONE)
	e7:SetCondition(s.sccon)
	e7:SetValue(4)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e8)
	--to hand (deck)
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,3))
	e9:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_PZONE)
	e9:SetCountLimit(1)
	e9:SetTarget(s.addtg)
	e9:SetCost(s.addcost)
	e9:SetOperation(s.addop)
	c:RegisterEffect(e9)
end
s.listed_series={SET_ODD_EYES,SET_PERFORMAPALSET,SET_MAGICIAN}
s.listed_names={20409757}

function s.cfilter(c,tp)
	return (c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_PERFORMAPAL) or c:IsSetCard(SET_MAGICIAN)) and c:IsMonster() and c:IsAbleToRemoveAsCost() 
	 and Duel.GetMZoneCount(tp,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.swicon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=0x08 and ph<=0x80
end
function s.switop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(2400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
end
function s.filter(c)
	return (c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_PERFORMAPAL) or c:IsSetCard(SET_MAGICIAN)) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	return tc and tc:IsControler(tp) and tc:IsType(TYPE_PENDULUM)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.scfilter(c)
	return c:IsSetCard(SET_MAGICIAN) or c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_PERFORMAPAL)
end
function s.sccon(e)
	return not Duel.IsExistingMatchingCard(s.scfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end
function s.costfilter(c)
	return c:IsSpellTrap() and c:IsDiscardable()
end 
function s.addcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) 
   and Duel.IsExistingMatchingCard(s.pmfilter,tp,LOCATION_DECK,0,1,nil) end
  	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.addfilter(c)
	return (c:IsSetCard(SET_PERFORMAPAL) or c:IsSetCard(SET_MAGICIAN) or c:IsSetCard(SET_ODD_EYES)) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand() 
end 
function s.addop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.addfilter),tp,LOCATION_DECK,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc then
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
		end
	end
end