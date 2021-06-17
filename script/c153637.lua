--True King's Memories of Calamity
local function getID()
    local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
    str=string.sub(str,1,string.len(str)-4)
    local cod=_G[str]
    local id=tonumber(string.sub(str,2))
    return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	-- Chain
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Destroy 1 card in hand, add level 3 or lower TK to hand from deck.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(cid.e2effect)
	e2:SetOperation(cid.e2effectOp)
	c:RegisterEffect(e2)
	 --Banish 2 cards from your GY, add 1 "True King's Cataclysm"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(cid.e3Gravetarg)
	e3:SetOperation(cid.e3GraveOp)
	c:RegisterEffect(e3)
		-- All "True King" monsters gain 500 ATK
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(cid.atkval) --aux.TargetBoolFunction(Card.IsSetCard,0xf9)
	e4:SetValue(500)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetValue(500)
	c:RegisterEffect(e5)
end
function cid.level3TDfilter(c,tp)
	return c:IsSetCard(0xf9) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4)
end
function cid.atkval(e,c)
	if c:IsType(TYPE_LINK) then return end 
	return c:IsSetCard(0xf9) and c:GetLevel()==9 
end
-- e2:setTarget
function cid.e2effect(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,e:GetHandler()) --] Can we activate our effect?
		and Duel.IsExistingMatchingCard(cid.level3TDfilter,tp,LOCATION_DECK,0,1,nil) end --] Do we have a level 3 or lower TK card in the deck to add?
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,e:GetHandler()) --] Defines g to allow our function to look at our hand and field, and recieve those card's info that it sees
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0) --] Destroys the card in our hand of our choice, up to 1.
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) --] Targets the card in our deck to be added, after the destruction occurs as cost.
end
-- E2:SetOperation
function cid.e2effectOp(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end --] If our card cannot detect anything to destroy or add to hand from deck, we cannot activate it. (?? I think)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY) --] The hint to destroy a card on our field or hand, shows up during the cost activation
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil) --] Allows us to select a card for our cost-destructon, up to 1 aside from itself.
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then --] If the card succesfully destroyed a card that isn't iself, search the deck for a TK
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND) --] The hint to add a lvl 3 or lower TK from deck to hand, after the destruction cost.
		local g=Duel.SelectMatchingCard(tp,cid.level3TDfilter,tp,LOCATION_DECK,0,1,1,nil) --] Targets the card in our deck, applying our custom filter, to be added to hand                                                       --] Orig.^^ was aux.ExceptThisCard(e). Because it's not a field spell anymore, i assume it needed to be nil instead. Idk why
		if g:GetCount()>0 then --] If we selected over 0 cards (which would be 1 at all times)
			Duel.SendtoHand(g,nil,REASON_EFFECT) --] We send the card we selected to our hand
			Duel.ConfirmCards(1-tp,g) --] The card is revealed to opponent, or confirmed by the system to be in our hand?
		end
	end
end
function cid.gravefilter(c)
	return c:IsAbleToRemove()
end
function cid.CataclysmFilter(c)
	return c:IsCode(59975756) and c:IsAbleToHand()
end
function cid.e3Gravetarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.gravefilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(cid.CataclysmFilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingTarget(cid.gravefilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,cid.gravefilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.e3GraveOp(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 and Duel.Remove(g,nil,0,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,cid.CataclysmFilter,tp,LOCATION_DECK,0,1,1,nil)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end