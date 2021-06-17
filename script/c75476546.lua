-- True King Herald, the Sparks
local function getID()
    local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
    str=string.sub(str,1,string.len(str)-4)
    local cod=_G[str]
    local id=tonumber(string.sub(str,2))
    return id,cod
end
local id,cid=getID()

function cid.initial_effect(c)

    local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetCode(EFFECT_ADD_ATTRIBUTE)
        e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
        e1:SetValue(ATTRIBUTE_EARTH)
        c:RegisterEffect(e1)
   

    local e2=Effect.CreateEffect(c)
        e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
        e2:SetType(EFFECT_TYPE_IGNITION)
        e2:SetRange(LOCATION_HAND)
        e2:SetCountLimit(1,id)
        e2:SetTarget(cid.sptg)
        e2:SetOperation(cid.spop)
        c:RegisterEffect(e2)

end

function cid.desfilter(c)
    return c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end

function cid.desfilter2(c)
    return c:IsFaceup() and c:GetSequence()<5
end

function cid.mzfilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and IsAttribute(ATTRIBUTE_FIRE) and c:GetSequence()<5
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
    if chk==0 then return ft>-1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
                  -- Orig. 2 ^^ 
        and g:GetCount()>=1 and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE)
              -- Orig. 2 ^^ 
        and (ft~=0 or g:IsExists(cid.mzfilter,1,nil,tp)) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
                                      -- Orig. 2 ^^ NOT the problem
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function cid.rmfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end

function cid.firefilter(c,tp)
    return c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_FIRE)
end

function cid.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local g=nil
    if ft>-1 then
        local loc=0
                                        -- V.F.D vv
        if Duel.IsPlayerAffectedByEffect(tp,88581108) then loc=LOCATION_MZONE end    --] Seems to deal with if the player is under the last effect of V.F.D
        g=Duel.GetMatchingGroup(cid.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,loc,c) --] Allows for the player to use opponent's monsters from V.F.D's effect.
    else                                                                             --] Otherwise, if V.F.D does not have its effect applied (it doesnt exist on the board)
        g=Duel.GetMatchingGroup(cid.desfilter2,tp,LOCATION_MZONE,0,c)                --] ??? Seems to allow the player to only use monsters from THEIR side unless affected by V.F.D on the board
    end
    if g:GetCount()<1 or not g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE) then return end --] Disallows activation if you have 0 fire monsters in hand other than itself (?)
        --Orig. 2 ^^
    local g1=nil 
   
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)                                     --] The message to apply for destroying a monster that flashes over your screen (1-1)
    if ft==0 then                                                                    --] Potentially bridges itself from here to be able to use monsters from your hand as well
        g1=g:FilterSelect(tp,cid.mzfilter,1,1,nil,tp)                                --] Filterselect(Group g, int player, function f, int min, int max, Card ex|nil, ...)
    else                                                                             --] Filterselect seems to deal with the monster zone functions more, need to study this potentially
        g1=g:FilterSelect(tp,cid.firefilter,1,1,nil,tp)                                                      --] Not entirely sure what this allows you to "select" but changing either numbers seems to do something helpful.
          --Originally not here ^^
    end
    
    --Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)            -------- THIS WAS THE CODE MAKING ME TARGET 2 MONSTERS. I still need to make it only destroy 1 FIRE only monster 
    --if g1:GetFirst():IsAttribute(ATTRIBUTE_FIRE) then
     --   local g2=g:Select(tp,1,1,g1:GetFirst())
        --g1:Merge(g2)
    -- end
    
    local rm=g1:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE)
                                -- Orig. 2 ^^
    if Duel.Destroy(g1,REASON_EFFECT)==1 then
        if not c:IsRelateToEffect(e) then return end                            --] If a destruction occurs that is not related to this card, ignore it while it is in hand / on field
        if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then         --] Something about special summoning this card?
            return
        end
        --local rg=Duel.GetMatchingGroup(cid.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
        --if rm and rg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(75476546,0)) then
           -- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
           --local tg=rg:Select(tp,1,1,nil)
            --Duel.HintSelection(tg)
            --Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
    end
end 