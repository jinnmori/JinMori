--Trickstar Neridamsel 
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,nil,3,3,s.lcheck)
	c:EnableReviveLimit()
	--Link Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(1,1)
	e1:SetOperation(s.extracon)
	e1:SetValue(s.extraval)
	c:RegisterEffect(e1)
	--Draw 1 card, then discard 1 card and inflict 200 damage 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--draw
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.condition)
    e3:SetOperation(s.DrawReduction)
    c:RegisterEffect(e3)
end
s.listed_series={SET_TRICKSTAR}
	function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsAttribute,2,nil,ATTRIBUTE_LIGHT,lc,sumtype,tp)
end
 function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return not s.curgroup or (#(sg&s.curgroup)<2 and sg:FilterCount(Card.IsSetCard,s.curgroup,SET_TRICKSTAR)==#sg-1)
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			s.curgroup=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
			s.curgroup:KeepAlive()
			return s.curgroup
		end
	elseif chk==2
		then
		if s.curgroup then
			s.curgroup:DeleteGroup()
		end
		s.curgroup=nil
	end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)  end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
	if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)>0 then
		local dc=Duel.GetOperatedGroup():GetFirst()
			if dc:IsSetCard(SET_TRICKSTAR) then
			Duel.Damage(1-tp,200,REASON_EFFECT)
				end
		end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetCurrentPhase()~=PHASE_DRAW
end
function s.DrawReduction(e,tp,eg,ep,ev,re,r,rp)
    local ex=Duel.GetOperationInfo(ev,CATEGORY_DRAW)
    local value = Duel.GetChainInfo(ev,CHAININFO_TARGET_PARAM)
    if ex then
        Duel.ChangeTargetParam(ev,value-1)
    end
end
