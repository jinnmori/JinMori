--Elemental HERO Divine Neos Future 
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_NEOS,1,s.ffilter,4)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.fuslimit,nil,nil,false)
	--Gains effects based on material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(0)
	e1:SetCondition(s.regcon)
	e1:SetTarget(s.regtg)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NEOS,SET_NEO_SPACIAN,SET_HERO}
s.listed_names={CARD_NEOS}
s.material_setcode={SET_NEOS,SET_NEO_SPACIAN,SET_HERO}

function s.fuslimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
	function s.ffilter(c,fc,sumtype,tp)
	return (c:IsSetCard(SET_HERO,fc,sumtype,tp) or c:IsSetCard(SET_NEOS,fc,sumtype,tp) or c:IsSetCard(SET_NEO_SPACIAN,fc,sumtype,tp)) and c:IsMonster(fc,sumtype,tp)
end
if contact then sumtype=0 end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()>0
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local effs=e:GetLabel()
	if chk==0 then return ((effs&1)>0 or (effs&2)>0 or (effs&4)>0) end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local effs=e:GetLabel()
	if (effs&1)>0 then
local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetCost(s.neoscost)
	e1:SetTarget(s.neostg)
	e1:SetOperation(s.neosop)
	c:RegisterEffect(e1)
end
	if (effs&2)>0 then
	--Neo-Spacian Effect
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetTarget(s.neosptg)
		e2:SetOperation(s.neospop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
end
	if (effs&4)>0 then
	--Heros Effect
		local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetDescription(3000)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	--Hero Effect 2
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	end
end
function s.tgfilter(c)
	return c:IsMonster() and c:IsSetCard({SET_NEOS,SET_NEO_SPACIAN,SET_HERO}) and c:IsAbleToGraveAsCost()
end
function s.neoscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetBaseAttack())
end
function s.neostg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.neosop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(e:GetLabel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsMonster() and c:IsSetCard({SET_NEOS,SET_NEO_SPACIAN,SET_HERO}) and c:IsAbleToHand()
end
function s.neosptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.neospop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.neos(c)
	return c:IsMonster() and c:IsSetCard(SET_NEOS) and not c:IsCode(CARD_NEOS)
end
function s.neospacian(c)
	return c:IsMonster() and c:IsSetCard(SET_NEO_SPACIAN) and not c:IsCode(CARD_NEOS)
end
function s.hero(c)
	return c:IsMonster() and c:IsSetCard(SET_HERO) and not c:IsCode(CARD_NEOS)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local effs=0
	if g:IsExists(s.neos,1,nil) then effs=effs|1 end
	if g:IsExists(s.neospacian,1,nil) then effs=effs|2 end
	if g:IsExists(s.hero,1,nil) then effs=effs|4 end
	e:GetLabelObject():SetLabel(effs)
end