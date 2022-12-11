--Performapal Odd-eyes Chimera
local s,id=GetID()
function s.initial_effect(c)
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
	e1:SetTarget(s.pntg)
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
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.addcon)
	e4:SetTarget(s.addtg)
	e4:SetOperation(s.addop)
	c:RegisterEffect(e4)
	--Place itself into pendulum zone
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.pencon)
	e5:SetTarget(s.pentg)
	e5:SetOperation(s.penop)
	c:RegisterEffect(e5)
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
function s.pntg(e,c,tp,r,re)
    	return c:IsSetCard({SET_ODD_EYES,SET_PERFORMAPAL})
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