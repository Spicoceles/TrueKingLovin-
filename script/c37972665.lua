-- True King Baharistes, The Torrential
local function getID()
    local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
    str=string.sub(str,1,string.len(str)-4)
    local cod=_G[str]
    local id=tonumber(string.sub(str,2))
    return id,cod
end
local id,cid=getID()

function cid.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
    	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    	e1:SetType(EFFECT_TYPE_IGNITION)
    	e1:SetRange(LOCATION_HAND)
    	e1:SetCountLimit(1,id)
    	e1:SetTarget(cid.sptg)
    	e1:SetOperation(cid.spop)
    	c:RegisterEffect(e1)
    -- Attribute
	local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e2:SetCode(EFFECT_ADD_ATTRIBUTE)
        e2:SetRange(LOCATION_MZONE+LOCATION_HAND)
        e2:SetValue(ATTRIBUTE_FIRE)
        c:RegisterEffect(e2)
   
    -- Search
    local e3=Effect.CreateEffect(c)
        e3:SetCategory(CATEGORY_TOHAND)
        e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
        e3:SetProperty(EFFECT_FLAG_DELAY)
        e3:SetCode(EVENT_DESTROYED)
        e3:SetCountLimit(1,id+100)
        e3:SetCondition(cid.thcon)
        e3:SetTarget(cid.thtg)
        e3:SetOperation(cid.thop)
        c:RegisterEffect(e3)
end

function cid.desfilter(c)
    return c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end

function cid.desfilter2(c)
    return c:IsFaceup() and c:GetSequence()<5
end

function cid.mzfilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and IsAttribute(ATTRIBUTE_WATER) and c:GetSequence()<5
end

function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local g=nil
    if ft>-1 then
        local loc=0
        if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc=LOCATION_MZONE end
        g=Duel.GetMatchingGroup(cid.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,loc,c)
    else
        g=Duel.GetMatchingGroup(cid.desfilter2,tp,LOCATION_MZONE,0,c)
    end
    if chk==0 then return ft>-1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) --and Duel.IsExistingMatchingCard(cid.TKspellsearchfilter,tp,LOCATION_DECK,0,1,nil)
                  -- Orig. 2 ^^ 
        and g:GetCount()>=1 and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER)
              -- Orig. 2 ^^ 
        and (ft~=0 or g:IsExists(cid.mzfilter,1,nil,tp)) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
                                      -- Orig. 2 ^^ NOT the problem
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    --Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function cid.rmfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end

function cid.waterfilter(c,tp)
    return c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_WATER)
end

function cid.spop(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        local g=nil
            if ft>-1 then
            local loc=0
            if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc=LOCATION_MZONE end    --] Seems to deal with if the player is under the last effect of V.F.D
            g=Duel.GetMatchingGroup(cid.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,loc,c) --] Allows for the player to use opponent's monsters from V.F.D's effect.
        else                                                                             --] Otherwise, if V.F.D does not have its effect applied (it doesnt exist on the board)
            g=Duel.GetMatchingGroup(cid.desfilter2,tp,LOCATION_MZONE,0,c)                --] ??? Seems to allow the player to only use monsters from THEIR side unless affected by V.F.D on the board
        end
 if g:GetCount()<1 or not g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER) then return end --] Disallows activation if you have 0 fire monsters in hand other than itself (?)
        --Orig. 2 ^^
        local g1=nil   
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)                                     --] The message to apply for destroying a monster that flashes over your screen (1-1)
        if ft==0 then                                                                    --] Potentially bridges itself from here to be able to use monsters from your hand as well
            g1=g:FilterSelect(tp,cid.mzfilter,1,1,nil,tp)                                --] Filterselect(Group g, int player, function f, int min, int max, Card ex|nil, ...)
        else                                                                             --] Filterselect seems to deal with the monster zone functions more, need to study this potentially
            g1=g:FilterSelect(tp,cid.waterfilter,1,1,nil,tp)                                                      --] Not entirely sure what this allows you to "select" but changing either numbers seems to do something helpful.
              --Originally not here ^^
        end   
        local rm=g1:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE)
                                    -- Orig. 2 ^^
        if Duel.Destroy(g1,REASON_EFFECT)==1 then
            if not c:IsRelateToEffect(e) then return end                            --] If a destruction occurs that is not related to this card, ignore it while it is in hand / on field
            if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then         --] Something about special summoning this card?
            return        
        end
    end  
end

function cid.TKstF(c)
    return c:IsAbleToHand() and c:IsType(TYPE_SPELL) and c:IsSetCard(0xf9) or c:IsType(TYPE_TRAP) and c:IsSetCard(0xf9)
end

function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
end

function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cid.TKstF,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,cid.TKstF,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end