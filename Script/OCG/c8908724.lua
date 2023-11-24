--Dragonmaid Fruhling
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
end
function s.ffilter(c,fc,sumtype,sp,sub,mg,sg)
	return c:IsSetCard(SET_DRAGONMAID,fc,sumtype,sp) and c:GetSum(Card.GetLevel,fc,sumtype,sp)==8
end