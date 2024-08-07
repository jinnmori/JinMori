--EFFECT_OBELISK_DISCIPLE
EFFECT_OBELISK_DISCIPLE = 566 -- Choose an unused effect number

-- Global variable to store the added monster's code
local OBELISK_DISCIPLE_ADDED_MONSTER = {}

function Auxiliary.AddObeliskDiscipleEffect()
    local e = Effect.GlobalEffect()
    e:SetType(EFFECT_TYPE_FIELD)
    e:SetCode(EFFECT_DECREASE_TRIBUTE)
    e:SetTargetRange(LOCATION_HAND,0)
    e:SetTarget(Auxiliary.ObeliskDiscipleTarget)
    e:SetValue(Auxiliary.ObeliskDiscipleValue)
    Duel.RegisterEffect(e,0)
end

function Auxiliary.ObeliskDiscipleTarget(e,c)
    local tp = c:GetControler()
    return c:IsAttribute(ATTRIBUTE_DIVINE) and 
           Duel.GetFlagEffect(tp, EFFECT_OBELISK_DISCIPLE) > 0 and 
           c:GetCode() == OBELISK_DISCIPLE_ADDED_MONSTER[tp]
end

function Auxiliary.ObeliskDiscipleValue(e,c)
    return 1
end

Auxiliary.AddObeliskDiscipleEffect()

function Auxiliary.AddNormalSummonProcedureDIVINE(c,ns,opt,min,max,val,desc,f,sumop)
    val = val or SUMMON_TYPE_TRIBUTE
    local e1=Effect.CreateEffect(c)
    if desc then e1:SetDescription(desc) end
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    if ns and opt then
        e1:SetCode(EFFECT_SUMMON_PROC)
    else
        e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
    end
    if ns then
        e1:SetCondition(Auxiliary.NormalSummonCondition1(min,max,f,opt))
        e1:SetTarget(Auxiliary.NormalSummonTarget(min,max,f))
        e1:SetOperation(Auxiliary.NormalSummonOperation(min,max,sumop))
    else
        e1:SetCondition(Auxiliary.NormalSummonCondition2())
    end
    e1:SetValue(val)
    c:RegisterEffect(e1)
    return e1
end

function Auxiliary.NormalSummonCondition1(min,max,f,opt)
    return function (e,c,minc,zone,relzone,exeff)
        if c==nil then return true end
        local tp=c:GetControler()
        local mg=Duel.GetTributeGroup(c):Match(Auxiliary.IsZone,nil,relzone,tp)
        if f then
            mg:Match(f,nil,tp)
        end
        local tributes=maplevel(c:GetLevel())
        if c:IsAttribute(ATTRIBUTE_DIVINE) and c:GetCode() == OBELISK_DISCIPLE_ADDED_MONSTER[tp] and Duel.GetFlagEffect(tp,EFFECT_OBELISK_DISCIPLE)>0 then
            return Duel.CheckTribute(c,2,2,mg,tp,zone)
        elseif c:IsAttribute(ATTRIBUTE_DIVINE) then
            return Duel.CheckTribute(c,3,3,mg,tp,zone)
        end
        return (not opt or (tributes>0 and tributes~=max)) and minc<=tributes and Duel.CheckTribute(c,min,max,mg,tp,zone)
    end
end
function Auxiliary.NormalSummonTarget(min,max,f)
      return function (e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
        local mg=Duel.GetTributeGroup(c):Match(Auxiliary.IsZone,nil,relzone,tp)
        if f then
            mg:Match(f,nil,tp)
        end
        local tributes=maplevel(c:GetLevel())
        if c:IsAttribute(ATTRIBUTE_DIVINE) and c:GetCode() == OBELISK_DISCIPLE_ADDED_MONSTER[tp] and Duel.GetFlagEffect(tp,EFFECT_OBELISK_DISCIPLE)>0 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
                local opt=Duel.SelectOption(tp,
                    aux.Stringid(7899550,0),  -- "Summon with 2 tributes"
                    aux.Stringid(7899550,1))  -- "Summon with 3 tributes"
                tributes = (opt==0) and 2 or 3
            else
                tributes=3
            end
        local g=Duel.SelectTribute(tp,c,tributes,tributes,mg,tp,zone,Duel.IsSummonCancelable())
        if g and #g>0 then
            g:KeepAlive()
            e:SetLabelObject(g)
            return true
        end
        return false
    end
end
-- Function to be called when Obelisk's Disciple adds a monster to hand
function Auxiliary.SetObeliskDiscipleAddedMonster(tp, code)
    OBELISK_DISCIPLE_ADDED_MONSTER[tp] = code
    Duel.RegisterFlagEffect(tp, EFFECT_OBELISK_DISCIPLE, RESET_PHASE+PHASE_END, 0, 1)
end