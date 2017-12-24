class Preference < ApplicationRecord

	def self.to_hash
		h = {}
		Preference.all.order(:updated_at).each do |preference|
			h[preference.name] = preference.value
		end
		return h
	end
end
