--Performapal Joker Mage
--My favourite Card
--Scripted by Marbela
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--pendulum summon
	Pendulum.AddProcedure(c)
	--Shuffle 1 Card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Place in your Pendulum Zone 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.pctg)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
	--splimit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	c:RegisterEffect(e3)
	--Xyz Summon Part
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTarget(s.xyztg)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
end
	s.listed_series={SET_PERFORMAPAL,SET_MAGICIAN,SET_ODD_EYES}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and (chkc:IsControler(1-tp) or chkc:IsControler(tp)) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,tp) and (Duel.IsPlayerCanDraw(tp,1)
	   or Duel.IsPlayerCanDraw(1-tp,1)) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK+CATEGORY_DRAW,nil,0,PLAYER_EITHER,1)
end
function s.filter(c,tp)
	return c:GetOwner()==tp or c:GetOwner()==1-tp
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
if not tc:IsRelateToEffect(e) then return end
	if Duel.SendtoDeck(tc,nil,1,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_EXTRA) then
	    Duel.DisableShuffleCheck(true)
	     Duel.BreakEffect()
	     Duel.Draw(tc:GetControler(),1,REASON_EFFECT)		
	 else
	Duel.ShuffleDeck(tc:GetControler())
	Duel.Draw(tc:GetControler(),1,REASON_EFFECT)		
	            end
	          end
function s.perfilter(c)
	return c:IsFacedown() or not (c:IsSetCard(SET_PERFORMAPAL) or (c:IsSetCard(SET_MAGICIAN) and c:IsType(TYPE_PENDULUM)) or c:IsSetCard(SET_ODD_EYES ))
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
if chkc then return false end
	local c=e:GetHandler()
	local odd=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,1,nil,tp,c)
              and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil,tp,c) and #odd>0 and not Duel.IsExistingMatchingCard(s.perfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,0,1,1,nil,tp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,g1:GetFirst(),c)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		if Duel.Destroy(g,REASON_EFFECT)>0 then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		       end
	        end 
	     end
	function s.filter2(c)
	return c:IsSetCard(SET_PERFORMAPAL) or (c:IsSetCard(SET_MAGICIAN) and c:IsType(TYPE_PENDULUM)) or c:IsSetCard(SET_ODD_EYES )
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not s.filter2(c) and (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.filter4(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyzfilter(c,mg,tp,chk)
	return c:IsXyzSummonable(nil,mg,2,2) and (not chk or Duel.GetLocationCountFromEx(tp,tp,mg,c)>0)
end
function s.mfilter1(c,mg,exg,tp)
	return mg:IsExists(s.mfilter2,1,c,c,exg,tp)
end
function s.zonecheck(c,tp,g1)
	return Duel.GetLocationCountFromEx(tp,tp,g1,c)>0 and c:IsXyzSummonable(nil,g1)
end
function s.mfilter2(c,mc,exg,tp)
	local g=Group.FromCards(c,mc)
	return exg:IsExists(s.zonecheck,1,nil,tp,g,tp)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(s.filter4,tp,LOCATION_GRAVE,0,nil,e,tp)
	local exg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and mg:IsExists(s.mfilter1,1,nil,mg,exg,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg1=mg:FilterSelect(tp,s.mfilter1,1,1,nil,mg,exg,tp)
	local tc1=sg1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg2=mg:FilterSelect(tp,s.mfilter2,1,1,tc1,tc1,exg,tp)
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg1,2,0,0)
end
function s.filter3(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.filter3,nil,e,tp)
	if #g<2 then return end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	Duel.BreakEffect()
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g,tp,true)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,nil,g)
	end
end
