--Performapal Odd-eyes Chimera
local s,id=GetID()
function s.initial_effect(c)
   --pendulum summon
	Pendulum.AddProcedure(c,false)
	--Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,s.mfilter,2,2)
	--Performapal and Odd-eyes Gains 500 atk/def
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetTarget(s.atktg)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Target 1 face-up monster on the field; change it's battle Position
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.swichtg)
	e3:SetOperation(s.swichop)
	c:RegisterEffect(e3)
	--Add 1 "Smile", "Performapal" or "Odd-eyes" spell/Trap card from your deck to your hand.
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.addcon)
	e4:SetTarget(s.addtg)
	e4:SetOperation(s.addop)
	c:RegisterEffect(e4)
	--Place itself into pendulum zone
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.pencon)
	e5:SetTarget(s.pentg)
	e5:SetOperation(s.penop)
	c:RegisterEffect(e5)
	--Destroy 1 card in your Pendulum zone, place 1 Lvl 5 or lower "Performapal" or "Odd-eyes" from hand, Deck or GY
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetRange(LOCATION_PZONE)
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetCountLimit(1)
	e6:SetCost(s.pncost)
	e6:SetTarget(s.pntg)
	e6:SetOperation(s.pnop)
	c:RegisterEffect(e6)
	--Discard 1 card, to prevent destruction for "Odd-Eyes" and "Performapal" monsters this turn.
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_PZONE)
	e7:SetCost(s.incost)
	e7:SetTarget(s.intg)
	e7:SetOperation(s.inop)
	c:RegisterEffect(e7)
	end
s.material_setcode={SET_PERFORMAPAL,SET_ODD_EYES}
s.listed_series={SET_PERFORMAPAL,SET_ODD_EYES}

function s.mfilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(SET_PERFORMAPAL,fc,sumtype,tp) or c:IsSetCard(SET_ODD_EYES,fc,sumtype,tp) 
	   and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,sumtype,tp,code) and not c:IsHasEffect(511002961)
end
function s.atktg(e,c,tp,r,re)
    	return c:IsSetCard({SET_ODD_EYES,SET_PERFORMAPAL}) and c:IsMonster()
end
function s.swichtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and (chkc:IsControler(tp) or chkc:IsControler(1-tp)) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,PLAYER_EITHER,0)
end
function s.swichop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if not tc:IsRelateToEffect(e) then return end
  Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return #eg==1 and tc:IsControler(tp) and tc:IsSetCard({SET_PERFORMAPAL,SET_ODD_EYES}) and tc:IsMonster()
	  and bc:IsReason(REASON_BATTLE) and bc:IsLocation(LOCATION_GRAVE)
end
function s.addfilter(c,e,tp)
  return c:IsSetCard({SET_SMILE,SET_PERFORMAPAL,SET_ODD_EYES}) and c:IsSpellTrap() and c:IsAbleToHand()
  end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
if #g>0 then
 Duel.SendtoHand(g,tp,REASON_EFFECT)
 Duel.ConfirmCards(1-tp,g)
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
function s.pncost(e,tp,eg,ep,ev,re,r,rp,chk)
   local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,c) end
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_PZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,LOCATION_PZONE)
	Duel.Destroy(g,REASON_COST+REASON_EFFECT)
	e:SetLabel(g:GetFirst():GetCode())
end
function s.pnfilter(c,code)
   return c:IsSetCard({SET_ODD_EYES,SET_PERFORMAPAL}) and c:IsLevelBelow(5) and c:IsType(TYPE_PENDULUM) and not c:IsCode(code)
end
function s.pntg(e,tp,eg,ep,ev,re,r,rp,chk)
   local all=LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE 
	if chk==0 then return Duel.IsExistingMatchingCard(s.pnfilter,tp,all,0,1,nil,e:GetLabel()) end
end
function s.pnop(e,tp,eg,ep,ev,re,r,rp)
   local all=LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE 
   if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pnfilter,tp,all,0,1,1,nil,e:GetLabel())
	if #g>0 then
 Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
 end
 function s.incost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
function s.infilter(c)
 return c:IsSetCard({SET_PERFORMAPAL,SET_ODD_EYES}) and c:IsMonster()
end
function s.intg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.infilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.inop(e,tp,eg,ep,ev,re,r,rp)
 	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	e1:SetValue(1)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(s.infilter))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	Duel.RegisterEffect(e2,tp)
end
