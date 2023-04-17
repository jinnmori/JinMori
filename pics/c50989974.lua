--Borreload Punish Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum atributes
	Pendulum.AddProcedure(c)
	--Actlimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
	--This card gains Atk equl to the targeted Link Monster 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--special summon up to 3 level 9 or lower "Borreload" and "Rokket" ignoring its Summonig conditions.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_ROKKET,SET_BORREL}

	function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_LINK) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_GRAVE,0,1,1,nil,TYPE_LINK)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0)
	Duel.SetChainLimit(s.chainlm)
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,tp,1,REASON_EFFECT)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function s.spcon(e,c)
	local tp=e:GetHandlerPlayer() 
	return not Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_ONFIELD,0,1,nil) and not
	Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
function s.spfilter(c,e,tp)
	return c:IsSetCard({SET_BORREL,SET_ROKKET}) and c:IsLevelBelow(9) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,true,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),3)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
			local sp=Duel.SpecialSummon(g,SUMMON_TYPE_PENDULUM,tp,tp,true,false,POS_FACEUP_DEFENSE)
			Duel.PayLPCost(tp,sp*500)
			end
	end