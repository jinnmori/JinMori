--Rank-Down-Magic Purified Barian's Force
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Return to Extra Deck and search
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end
s.Listed_series={SET_BARIANS,SET_NUMBER,SET_NUMBER_C,SET_RANK_UP_MAGIC,SET_SEVENTH}
function s.cfilter(c,e,tp)
	local m=c:GetMetatable(true)
	if not m then return false end
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then
		return false
	end
	local no=m.xyz_number
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and no and no>=101 and no<=107 and c:IsSetCard(SET_NUMBER_C)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (aux.CheckSummonGate(tp,2) or c:IsLocation(LOCATION_GRAVE))
	and Duel.IsExistingMatchingCard(s.nfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,no,pg)
end
function s.nfilter(c,e,tp,mc,no,pg)
	return c.xyz_number==no and c:IsSetCard(SET_NUMBER) and mc:IsCanBeXyzMaterial(c,tp) and Duel.GetLocationCountFromEx(tp,tp,mc,nil)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    	if Duel.GetFlagEffect(tp,id)~=0 then return end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_GRAVE end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.cfilter),tp,loc,0,1,1,nil,e,tp)
	local tc1=g1:GetFirst()
	if tc1 and Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc1),tp,nil,nil,REASON_XYZ)
		local m=tc1:GetMetatable(true)
		if not m then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,s.nfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc1,m.xyz_number,pg)
		if #g2>0 then
            local sc=g2:GetFirst()
			sc:SetMaterial(tc1)
			Duel.Overlay(sc,tc1)
            Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
        end
    end
    --Cannot Special Summon from Extra Deck except Xyz
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
end
function s.splimit(e,c)
    return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
function s.tdfilter(c)
    return c:IsSetCard(SET_NUMBER_C) and c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
end
function s.thfilter(c)
    return ((c:IsSetCard(SET_SEVENTH) and c:IsSpellTrap()) or (c:IsSetCard(SET_RANK_UP_MAGIC) and c:IsType(TYPE_QUICKPLAY) and c:IsSpell()) 
	or (c:IsSetCard(SET_BARIANS) and c:IsSpellTrap() and not c:IsCode(id))) and c:IsAbleToHand()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            else
                Duel.ShuffleDeck(tp)
                Duel.MoveSequence(g:GetFirst(),0)
            end
        end
    end
end