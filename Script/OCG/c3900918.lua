--Blackwing -Pathogen the chilly wind
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCountLimit(1,id)
	 e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end
s.listed_series={SET_BLACKWING}
s.listed_names={id}

function s.cfilter(c,e,tp,lv)
    return c:IsMonster() and c:IsSetCard(SET_BLACKWING) and not c:IsType(TYPE_TUNER) and c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel()+lv)
end
function s.spfilter(c,e,tp,lv)
    return c:IsSetCard(SET_BLACKWING) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv) 
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
        and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
    local c=e:GetHandler()
    local clv=c:GetLevel()
    if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil,e,tp,clv) and at:IsControler(1-tp) 
    	and at:IsRelateToBattle() end
    Duel.SendtoGrave(c,REASON_COST)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,99,nil,e,tp,clv)
    Duel.SendtoGrave(g,REASON_COST)
    e:SetLabel(c:GetLevel()+g:GetSum(Card.GetLevel))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local lv=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
    if #g>0 then
        Duel.SpecialSummon(g,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
        Duel.ChangeAttackTarget(g:GetFirst())
        --Cannot Attack
        local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
		g:GetFirst():CompleteProcedure()
			--Destroy it during end phase
		aux.DelayedOperation(g:GetFirst(),PHASE_END,id,e,tp,function(ag) Duel.Destroy(ag,REASON_EFFECT) end,nil,0)
	end
end