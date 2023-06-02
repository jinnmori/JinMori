--Meklord General Genechine 
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(3,id+1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MEKLORD,SET_MEKLORD_EMPEROR}
s.listed_names={id}
function s.filter(c,tp)
	return c:IsMonster() and c:IsSetCard(SET_MEKLORD) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and not c:IsCode(id) 
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(s.filter,1,nil,tp) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(SET_MEKLORD_EMPEROR) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) 
	and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,c:GetAttribute()),tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetAttack()>=1000 then
	--Make this card lose 1000 Atk to activate 
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e0:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetValue(-1000)
	c:RegisterEffect(e0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
	if Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.splimit)
			Duel.RegisterEffect(e1,tp)
		--Limit attacks for the rest of the turn
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CANNOT_ATTACK)
			e2:SetTargetRange(LOCATION_MZONE,0)
			e2:SetLabelObject(g:GetFirst())
			e2:SetTarget(s.atktg)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
			--lizard check
aux.addTempLizardCheck(e:GetHandler(),tp)
				end
			end
		end
	end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
function s.atktg(e,c)
	return e:GetLabelObject()~=c
end