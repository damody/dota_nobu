modifier_amhc_make_illusion = class({})

--------------------------------------------------------------------------------

function modifier_amhc_make_illusion:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_amhc_make_illusion:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_amhc_make_illusion:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_amhc_make_illusion:OnCreated( keys )
	vlua.tableadd(self,keys)
end

--------------------------------------------------------------------------------

function modifier_amhc_make_illusion:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end

function modifier_amhc_make_illusion:GetModifierDamageOutgoing_Percentage()
	return self.DamageOutgoing or 0
end

function modifier_amhc_make_illusion:GetModifierIncomingDamage_Percentage()
	return self.IncomingDamage or 100
end

--------------------------------------------------------------------------------