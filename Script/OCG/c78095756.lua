--Performapal Odd-eyes Warrior 
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c,false)
	--synchro summon
	Synchro.AddProcedure(c,s.matfilter,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Synchro Level
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(id)
    e1:SetRange(LOCATION_EXTRA)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_SYNCHRO_LEVEL)
    e2:SetValue(function(e,c)
        local lv=e:GetHandler():GetLevel()
        return c:IsHasEffect(id) and ((1<<16)|lv) or lv
    end)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetRange(LOCATION_EXTRA)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.syntg)
    e3:SetLabelObject(e2)
    c:RegisterEffect(e3)
  --spsummon success
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.sucop)
	c:RegisterEffect(e4)
  --Special Summon 1 lvl 3 or lower "Odd-Eyes" or "Performapal" 
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetTarget(s.target)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
	--Place itself into pendulum zone
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e6:SetCondition(s.pencon)
	e6:SetTarget(s.pentg)
	e6:SetOperation(s.penop)
	c:RegisterEffect(e6)
	--Cannot be destroyed by card effects while you control a "Performapal" or "Odd-Eyes" monster in your other Pendulum zone 
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e7:SetCondition(s.incon)
	e7:SetValue(1)
	c:RegisterEffect(e7)
	--Place 1 "Performapal" or "Odd-Eyes" pendulum monster from GY or Face-up Extra Deck into pendulum zone
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,0))
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_PZONE)
	e8:SetCountLimit(1)
	e8:SetTarget(s.pctg)
	e8:SetOperation(s.pcop)
	c:RegisterEffect(e8)
end
s.material_setcode={SET_PERFORMAPAL,SET_ODD_EYES}

function s.matfilter(c,scard,sumtype,tp)
	return (c:IsSetCard(SET_PERFORMAPAL,scard,sumtype,tp) or c:IsSetCard(SET_ODD_EYES,scard,sumtype,tp))
end
function s.syntg(e,c)
	return c:IsType(TYPE_PENDULUM) and not c:IsType(TYPE_TUNER)
end
function s.sucop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	local atk=c:GetMaterial():Filter(Card.IsType,nil,TYPE_PENDULUM)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(#atk*200)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
  if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)==0 then return false end
  local notall=LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE|LOCATION_PZONE
	return (c:IsSetCard(SET_PERFORMAPAL) or c:IsSetCard(SET_ODD_EYES)) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and
	(c:IsFaceup() or notall)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local all=LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE|LOCATION_PZONE|LOCATION_EXTRA
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,all,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
  local all=LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE|LOCATION_PZONE|LOCATION_EXTRA
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,all,0,1,1,nil,e,tp)
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
function s.incfilter(c)
  return (c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_PERFORMAPAL))
  end
function s.incon(e)
  local c=e:GetHandler()
  local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.incfilter,tp,LOCATION_PZONE,0,1,c)
end
function s.pcfilter(c)
	return (c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_PERFORMAPAL)) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and 
	(c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	if Duel.CheckPendulumZones(tp) then
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
 Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	       end
		 else
		    if not Duel.CheckPendulumZones(tp) then
 	local gro=Duel.GetMatchingGroup(nil,tp,LOCATION_PZONE,0,c)
	if #gro>0 then
	 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
 local sel=gro:Select(tp,1,1,nil)
	Duel.SendtoDeck(sel,nil,2,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		     end
		 end
	 end
end
		         