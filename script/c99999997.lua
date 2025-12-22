-- Last Will (Classic OCG)
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Register temporary trigger until end of turn
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
end

-- Condition: monster you controlled was sent from field to GY
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.cfilter(c,tp)
    return c:IsMonster()
        and c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsPreviousControler(tp)
end

-- Filter for Special Summon
function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsAttackBelow(1500)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- Operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
