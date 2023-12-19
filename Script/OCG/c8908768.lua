--Meklord Factorio Reboot
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Equip 1 monster to 1 "Meklord" Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.eqcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--Activate the turn it is set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MEKLORD,SET_MEKLORD_EMPEROR}
function s.filter(c,e,tp)
	return c:IsSetCard(SET_MEKLORD) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==LOCATION_GRAVE and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
	end
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.eqfilter1(c,tp)
	return c:IsFaceup() and c:IsMonster() and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_MZONE,0,1,nil,c,tp)
end
function s.eqfilter2(c,ec,tp)
local eff={c:GetCardEffect(89785779)}
if not (c:IsMonster() and c:IsSetCard(SET_MEKLORD_EMPEROR)) then return false end
	for _,te in ipairs(eff) do
		if te:GetValue()(ec,c,tp) then return true end
	end
	return true
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter1(chkc,tp) end
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
	and Duel.IsExistingTarget(s.eqfilter1,tp,0,LOCATION_GRAVE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectTarget(tp,s.eqfilter1,tp,0,LOCATION_GRAVE,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g2=Duel.SelectMatchingCard(tp,s.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil,g1:GetFirst(),tp)
	e:SetLabelObject(g2:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g1,2,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc2=e:GetLabelObject()
	local tc1=Duel.GetFirstTarget()
	local te=tc2:GetCardEffect(89785779)
	if tc2:IsFaceup() and tc2:IsControler(tp) and tc1:IsControler(1-tp) then
		te:GetOperation()(tc2,te:GetLabelObject(),tp,tc1)
	end
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_MEKLORD_EMPEROR),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end