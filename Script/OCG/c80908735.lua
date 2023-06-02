--Pendulum Dragoon Special Wizardry
local s,id=GetID()
function s.initial_effect(c)
   c:SetUniqueOnField(1,0,id)
   --pendulum summon
	Pendulum.AddProcedure(c,false)
	--fusion material
	c:EnableReviveLimit()
   Fusion.AddProcMixRepUnfix(c,true,true,{aux.FilterBoolFunctionEx(Card.IsSetCard,SET_MAGICIAN),1,99},{aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ODD_EYES),1,99}
   ,{aux.FilterBoolFunctionEx(Card.IsSetCard,SET_PERFORMAPAL),1,99})
   --you can target cards on the field up to the number of fusion materials for this card's summon
   local e1=Effect.CreateEffect(c)
   e1:SetCategory(CATEGORY_DISABLE)
   e1:SetDescription(aux.Stringid(id,0))
   e1:SetType(EFFECT_TYPE_IGNITION)
   e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
   e1:SetCountLimit(1)
   e1:SetRange(LOCATION_MZONE)
   e1:SetLabelObject(e4)
   e1:SetTarget(s.ngtg)
   e1:SetOperation(s.ngop)
   c:RegisterEffect(e1)
--Special Summon 1 lvl 7 or lower Face-up Pendulum monster from face-up extra deck or from Pendulum zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
		--Place itself into pendulum zone
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
	--Destroy 1 card in your Pendulum zone, monsters you control are unaffected by opponent's card effects this turn
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCost(s.imncost)
	e4:SetTarget(s.imntg)
	e4:SetOperation(s.imnop)
	c:RegisterEffect(e4)
	--Place 1 lvl 7 or lower "Performapal" ,"Odd-Eyes" or "Magician" pendulum monster into pendulum zone
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_PZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.pctg)
	e5:SetOperation(s.pcop)
	c:RegisterEffect(e5)
end
s.material_setcode={SET_MAGICIAN,SET_PERFORMAPAL,SET_ODD_EYES}

function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
   local c=e:GetHandler()
   local mat=c:GetMaterialCount()
   if chkc then return (chkc:IsControler(tp) or chkc:IsControler(1-tp)) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsNegatable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,mat,c)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,mat,0,0)
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetTargetCards(e)
    tc:KeepAlive()
    for gc in aux.Next(tc) do
        if gc and ((gc:IsFaceup() and not gc:IsDisabled()) or gc:IsType(TYPE_TRAPMONSTER)) and gc:IsRelateToEffect(e) then
            Duel.NegateRelatedChain(gc,RESET_TURN_SET)
            e:SetLabelObject(tc)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
            gc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
            gc:RegisterEffect(e2)
            if gc:IsType(TYPE_TRAPMONSTER) then
                local e3=Effect.CreateEffect(c)
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
                gc:RegisterEffect(e3)
            end
        end
    end
    local gt=tc:GetFirst()
    --Destroy each target During the end phase
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetCountLimit(1)
    e4:SetRange(LOCATION_MZONE)
    e4:SetReset(RESET_EVENT+RESETS_STANDARD)
    e4:SetLabelObject(tc)
    e4:SetCondition(s.descon)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
   local g=c:GetMaterial()
   local gc=e:GetLabelObject()
for tc in aux.Next(gc) do
   if not g then return false end
   local ct=g:FilterCount(Card.IsType,nil,TYPE_PENDULUM)
    return c:IsSummonType(SUMMON_TYPE_FUSION) and ct==#g and tc:IsLocation(LOCATION_ONFIELD)
    end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
local gc=e:GetLabelObject()
local c=e:GetHandler()
if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
 Duel.Destroy(gc,REASON_EFFECT)
   end
end
function s.spfilter(c,e,tp)
  if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)==0 then return false end
	return c:IsType(TYPE_PENDULUM) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and
	(c:IsFaceup() or c:IsLocation(LOCATION_PZONE))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA+LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA+LOCATION_PZONE,0,1,1,nil,e,tp)
	if #g>0 then
	  Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.imncost(e,tp,eg,ep,ev,re,r,rp,chk)
   local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_PZONE,0,1,c) end
	local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_PZONE,0,1,1,c)
	Duel.Destroy(g,REASON_COST+REASON_EFFECT)
end
function s.imntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,TYPE_PENDULUM) end
end
function s.imnop(e,tp,eg,ep,ev,re,r,rp)
 	local c=e:GetHandler()
 			local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_PENDULUM)
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
		   local e1=Effect.CreateEffect(c)
         e1:SetDescription(3110)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetOwnerPlayer(tp)
			tc:RegisterEffect(e1)
			end
     end
   function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.pcfilter(c)
   local notall=LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE|LOCATION_PZONE
	return (c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_PERFORMAPAL)) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and 
	(c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
     local all=LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE|LOCATION_PZONE|LOCATION_EXTRA
	if chk==0 then return Duel.IsExistingMatchingCard(s.pcfilter,tp,all,0,1,nil) and Duel.CheckPendulumZones(tp) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
   local all=LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE|LOCATION_PZONE|LOCATION_EXTRA
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,all,0,1,1,nil)
	if #g>0 then
 Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
local c=e:GetHandler()
 if c:IsFaceup() and c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
   local op=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
      if op==0 and c:GetLeftScale()>1 then
			e1:SetValue(1)
		else
			e1:SetValue(10)
		end
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		c:RegisterEffect(e2)
	end
		--monsters cannot attack except Pendulum monsters
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.ftarget)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetTargetRange(1,0)
	Duel.RegisterEffect(e4,tp)
end
function s.ftarget(e,c)
	return not c:IsType(TYPE_PENDULUM)
end
		         