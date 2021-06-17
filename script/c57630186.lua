--True King Kerinalos
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf9),2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
--Destroy
e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
--Remove all spells traps
--local e2=Effect.CreateEffect(c)
--	e2:SetDescription(aux.Stringid(id,0))
--	e2:SetCategory(CATEGORY_REMOVE)
--	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
--	e2:SetCode() --(EVENT_SPSUMMON_SUCCESS)
--	e2:SetProperty(EFFECT_FLAG_DELAY)
--	e2:SetCondition(s.rmcon)
--	e2:SetTarget(s.rmtg)
--	e2:SetOperation(s.rmop)
--	c:RegisterEffect(e2)

--e3=Effect.CreateEffect(c)

--c:RegisterEffect(e3)
end


function s.contactfil(tp)
	return Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_MONSTER) and c:IsLevel(9) end,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
Duel.Destroy(g,REASON_COST+REASON_MATERIAL,LOCATION_GRAVE)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then
		Duel.Destroy(tg,REASON_EFFECT)
	end
end

--function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
--	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x105)
--end
--function s.rmfilter(c)
--	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
--end
--function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
--	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
--	if chk==0 then return #g>0 end
--	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
--end
--function s.rmop(e,tp,eg,ep,ev,re,r,rp)
--	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
--	if #g>0 then
--		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
--	end
--end