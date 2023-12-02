--Morphtronic Roomba
local s,id=GetID()
function s.initial_effect(c)
	--Destroy all monsters your opponent controls as the same column as the targeted monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.conda)
	e1:SetTarget(s.tga)
	e1:SetOperation(s.opa)
	c:RegisterEffect(e1)
end
function s.conda(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
function s.cfilter(c,e,g)
	return c:IsSetCard(SET_MORPHTRONIC) and c:HasLevel() and c:IsCanBeEffectTarget(e) and g:IsContains(c)
end
function s.cfilter1(c,e,g)
	for tc in g:Iter() do
	local column=tc:GetColumnGroup()
	return c:IsSetCard(SET_MORPHTRONIC) and c:HasLevel() and c:IsCanBeEffectTarget(e) and column:IsContains(c)
	end
end
function s.desfilter(c,g)
	return g:IsContains(c)
end
function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLevel)==#sg
end
function s.tga(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,e,tc:GetColumnGroup())
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,99,s.spcheck,0) end
end
local g=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_MZONE,0,nil,e,cg)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,99,s.spcheck,1,tp,HINTMSG_TARGET)
	
	for tc in g:Iter() do
	local des=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetColumnGroup())
end
	Duel.SetTargetCard(sg)
end
function s.opa(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if #g==0 then return end
    local cg=Group.CreateGroup()
    for tc in g:Iter() do
        cg:Merge(tc:GetColumnGroup())
    end
    local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,cg)
    if #dg>0 then
        Duel.Destroy(dg,REASON_EFFECT)
    end
end
