class Preference < ApplicationRecord
	validates :name, presence: true

	def self.get_value(name)
		where(name: name).first.value
	end

	def self.to_hash
		h = {}
		Preference.all.order(:updated_at).each do |preference|
			h[preference.name] = preference.value
		end
		return h
	end
end
