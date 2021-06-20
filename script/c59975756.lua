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
	e3=Effect.CreateEffect(c)
		e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
		e3:SetRange(LOCATION_FZONE)
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		e3:SetCountLimit(1,id)
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
		e4:SetCountLimit(1,id+1)
		e4:SetCondition(s.ntcon)
		e4:SetTarget(aux.FieldSummonProcTg(s.nttg))
		e4:SetOperation(s.ntop)
	c:RegisterEffect(e4)
end

	function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
		return c:GetRace()~=RACE_WYRM
	end
		-- Metaphys Factor's Normal summon without tribute code
	function s.ntcon(e,c,minc)
			if c==nil then return true end
		return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
	end
	function s.nttg(e,c)
			return c:IsLevel(9) and c:IsSetCard(0xf9)
	end
	function s.ntop(e,tp,eg,ep,ev,re,r,rp,c)
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e4:SetCode(EVENT_PHASE+PHASE_END)
			e4:SetCountLimit(1)
			e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e4:SetLabelObject(c)
			e4:SetReset(RESET_PHASE+PHASE_END,2)
			Duel.RegisterEffect(e4,tp)
	end

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
