-- Primordial Burial
local id,cid=getID()
function cid.initial_effect(c)
	-- Chain
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

end