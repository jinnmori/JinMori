--Miracle Illusion Magicians
local s,id=GetID()
function s.initial_effect(c)
local loc=LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE
	--xyz summon
	Xyz.AddProcedure(c,nil,10,3,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--Attach them as Material
	local e1=Effect.CreateEffect(c) 
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.attcon)
	e1:SetTarget(s.atttg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)
	--gain 2500 Atk
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(aux.dxmcostgen(1,1))
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--splimit
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and (c:IsRankAbove(6) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp)) or (c:IsLevelAbove(6) and c:IsType(TYPE_FUSION,xyzc,SUMMON_TYPE_XYZ,tp)) 
	and c:IsRace(RACE_SPELLCASTER,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
			if Duel.IsPlayerAffectedByEffect(1-tp,CARD_BLUEEYES_SPIRIT) then
			return Duel.IsExistingMatchingCard(Card.IsCanBeEffectTarget,tp,0,LOCATION_HAND+LOCATION_ONFIELD,1,nil,e)
		else
			return Duel.IsExistingMatchingCard(Card.IsCanBeEffectTarget,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,e)
		end
	end
	local g1=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_ONFIELD,nil,e)
	local g2=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_GRAVE,nil,e)
	local g3=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND,nil,e)
	local sg=Group.CreateGroup()
	if #g1>0 and ((#g2==0 and #g3==0) or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local sg1=Duel.SelectTarget(tp,Card.IsCanBeEffectTarget,tp,0,LOCATION_ONFIELD,1,1,nil,e)
		Duel.HintSelection(sg1)
		sg:Merge(sg1)
	end
	if #g2>0 and ((#sg==0 and #g3==0) or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local sg2=Duel.SelectTarget(tp,Card.IsCanBeEffectTarget,tp,0,LOCATION_GRAVE,1,1,nil,e)
		Duel.HintSelection(sg2)
		sg:Merge(sg2)
	end
	if #g3>0 and (#sg==0 or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local sg3=g3:Select(tp,1,1,nil)
		sg:Merge(sg3)
		Duel.SetTargetCard(sg)
	end
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local c=e:GetHandler()
	if #tg>0 then
	if c:IsRelateToEffect(e) then
		Duel.Overlay(c,tg,true)
		end
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL) and bc:IsControler(1-tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(2500)
		c:RegisterEffect(e1)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and (sumtype&SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ
end