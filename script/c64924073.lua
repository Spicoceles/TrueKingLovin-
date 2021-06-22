--True King Mudari, The Shifter by Spicoceles
local s,id=GetID()
function s.initial_effect(c)

    c:SetSPSummonOnce(id)
    Link.AddProcedure(c,s.matfilter,1,1)
    c:EnableReviveLimit()
-- Add 1 Dragonic Diagram if link summoned
local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
end

function s.matfilter(c)
    return c:IsSetCard(0xf9) and c:IsLevelBelow(3)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.thfilter(c)
return c:IsCode(13035077) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end