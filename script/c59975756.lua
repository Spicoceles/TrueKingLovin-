-- True King's Cataclysm
local s,id=GetID()
function s.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		c:RegisterEffect(e1)
	c:RegisterEffect(e1)

	-- Special Summon Limit
	local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)

--Special summon from deck
	local e3=Effect.CreateEffect(c)
		e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
		e3:SetRange(LOCATION_FZONE)
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		e3:SetCountLimit(1,id+2)
		e3:SetCondition(s.spcon1)
		e3:SetTarget(s.sptg1)
		e3:SetOperation(s.spop1)
	c:RegisterEffect(e3)

	-- Normal summon without tribute
	local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,0))
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_SUMMON_PROC)
		e4:SetRange(LOCATION_FZONE)
		e4:SetTargetRange(LOCATION_HAND,0)
		e4:SetCountLimit(1)
		e4:SetCondition(s.ntcon)
		e4:SetTarget(aux.FieldSummonProcTg(s.nttg))
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
		e5:SetRange(LOCATION_FZONE)
		e5:SetCategory(CATEGORY_DAMAGE)
		e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e5:SetCode(EVENT_LEAVE_FIELD)
		e5:SetCondition(s.lpcon)
		e5:SetTarget(s.lptg)
--		e5:SetOperation(s.lpop)
	c:RegisterEffect(e5)

end

	function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
		return c:GetRace()~=RACE_WYRM
	end
		-- Catalyst Field's effect
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsLevel(9) and c:IsSetCard(0xf9)
end
--
function s.TK9Filter(c,e,tp)
return c:IsLevel(9) and c:IsSetCard(0xf9) 
end

function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.TK9Filter,1,nil,e,tp) 
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.TK9Filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.TK9Filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end

function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return Duel.CheckLPCost(tp,3000) end
    Duel.PayLPCost(tp,3000)
end