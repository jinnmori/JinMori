--Doris, Lady of Lament
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsMonster),2,nil,s.lcheck)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.doeffcost)
	e1:SetTarget(s.doefftg)
	e1:SetOperation(s.doeffop)
	c:RegisterEffect(e1)
	--Draw 2 Cards then discard 1 card
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--Check if it's sent to your gy by an opponent's card effect 
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.drcon2)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={SET_LADY_OF_LAMENT}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_LADY_OF_LAMENT,lc,sumtype,tp)
end
function s.effilter(c)
	return c:IsMonster() and c:IsReleasable() and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.doeffcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,effilter,1,nil,nil,nil) end
		local sg=Duel.SelectReleaseGroupCost(tp,s.effilter,1,1,nil,nil,nil)
		Duel.Release(sg,REASON_COST)
		e:SetLabelObject(sg:GetFirst())
		sg:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_LADY_OF_LAMENT) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.setfilter(c,ignore)
	return c:IsTrap() and c:IsSSetable(ignore)
end
function s.doefftg(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and ft>0 if c:GetSequence()<5 then ft=ft+1 end
		local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,false) 
		local tc=e:GetLabelObject()
		local b3=b1 and b2 and tc and tc:GetFlagEffect(id)~=0 and tc:IsSetCard(SET_LADY_OF_LAMENT)
		if chk==0 then return b1 or b2 end
		local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)},
		{b3,aux.Stringid(id,4)})
	e:SetLabel(op)
	e:SetCategory(0)
	if op==1|3 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
		 end
	end
function s.doeffop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	local op=e:GetLabel()
	local breakeff=false
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local g1=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,false)
		if #g1>0 then
		Duel.SSet(tp,g1:GetFirst())
	end
		else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g1>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local g2=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,false)
			if #g2>0 then
			Duel.SSet(tp,g2:GetFirst())
			end
		end
	end
end
function s.drcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and rp==1-tp and c:IsPreviousControler(tp) and c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		Duel.ShuffleHand(p)
		Duel.BreakEffect()
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end

