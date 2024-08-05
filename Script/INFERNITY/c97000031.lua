--インフェルニティ・ドワーフ
local s,id=GetID()
function s.initial_effect(c)
	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
function s.flagfilter(c)
    return c:IsFaceup() and c:GetFlagEffect(80085565)>0 and not c:IsDisabled()
end
function s.condition(e)
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_HAND,0)==0 or Duel.IsExistingMatchingCard(s.flagfilter,tp,LOCATION_MZONE,0,1,nil)
end
