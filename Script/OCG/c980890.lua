--Blooming Rose Dragon
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Banish 1 Card your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--special summon the Revealed Monster From Your EX
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ROSE,SET_ROSE_DRAGON}
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.tgfilter(c)
	return c:IsMonster() and (c:IsSetCard(SET_ROSE_DRAGON) and c:IsMonster() or c:IsRace(RACE_PLANT)) and c:IsAbleToGraveAsCost()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.rescon(lv,self)
	return function(sg,e,tp,mg)
		return sg:GetSum(Card.GetLevel)==lv and Duel.GetLocationCountFromEx(tp,tp,self,TYPE_SYNCHRO)>0
	end
end
function s.rmfilter1(c)
	return c:IsMonster() and (c:IsSetCard(SET_ROSE_DRAGON) and c:IsMonster() or c:IsRace(RACE_PLANT)) and c:IsAbleToRemoveAsCost()
end
function s.revfilter(c,e,tp,g,self)
	return c:IsSetCard(SET_ROSE) and c:IsType(TYPE_SYNCHRO) and not c:IsPublic() 
	and aux.SelectUnselectGroup(g,e,tp,nil,5,s.rescon(math.abs(self:GetLevel()-c:GetLevel()),self),0) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,self,TYPE_SYNCHRO)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.rmfilter1,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,0,LOCATION_EXTRA,1,nil,e,tp,g,c) 
	and e:GetHandler():IsReleasable() end
	if Duel.Release(e:GetHandler(),REASON_COST)>0 then
	local sc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g,c)
	e:SetLabelObject(sc)
	e:SetLabel(math.abs(sc:GetFirst():GetLevel()-c:GetLevel()))
	sc:KeepAlive()
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.rmfilter1,tp,LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,nil,5,s.rescon(e:GetLabel(),c),1,tp,HINTMSG_SELECT,s.rescon(e:GetLabel(),c))
	if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 then
	 Duel.SpecialSummon(e:GetLabelObject():GetFirst(),SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	e:GetLabelObject():DeleteGroup()
	 end
end