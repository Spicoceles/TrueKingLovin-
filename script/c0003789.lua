-- Hello World! 
-- Effect_type_quick_f
-- Effect_change_damage

function c00037891.initial_effect(c)
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetRange(LOCATION_MZONE)
e1:SetValue(9000)
c:RegisterEffect(e1)
end
