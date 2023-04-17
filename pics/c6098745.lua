--Fortune Lady Guide
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),2)
	--Atk gain
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Cannot attack directly
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(3207)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	--pierce
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	--Activate 1 of these effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.doefftg)
	e4:SetOperation(s.doeffop)
	c:RegisterEffect(e4)
end
	s.listed_series={SET_FORTUNE_LADY}
	s.listed_names={id}
function s.atkfilter(c,xc)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_FORTUNE_LADY)
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil,nil)
	return g:GetSum(Card.GetLevel)*200
end
function s.cfilter(c,g)
	return g:IsContains(c) and not c:IsLevel(12)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_FORTUNE_LADY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.doefftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
		local lg=e:GetHandler():GetLinkedGroup()
		local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,lg)
		local b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	e:SetCategory(0)
	if op==1 then
		e:SetCategory(CATEGORY_LVCHANGE)
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,lg)
		Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g,1,tp,0)
		elseif op==2 then
		  e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		  local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,tp,LOCATION_DECK+LOCATION_HAND)
		 end
	end
function s.doeffop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
		local lg=e:GetHandler():GetLinkedGroup()
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,lg)
		if #g>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(12)
			g:GetFirst():RegisterEffect(e1)
			 end
	elseif op==2 then
	  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		if #g1>0 then
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		      end
		   end
   end