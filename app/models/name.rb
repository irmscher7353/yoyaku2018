# -*- coding: utf-8 -*=
class Name < ApplicationRecord

	def self.candidates(s)
		result = []
		if s.present? and s != ''
			tokens = s.split
			if (w = tokens[-1]) != ''
				filters = []
				if tokens.length <= 1
					filters << 'is_shamei' << 'is_sei'
				else
					prev = where(value: tokens[-2]).first
					if prev
						if prev.is_sei
							filters << 'is_mei' << 'is_title'
						elsif pref.is_shamei
							filters << 'is_sitenmei' << 'is_sei'
						else
							filters << 'is_sitenmei' << 'is_sei' << 'is_mei' << 'is_title'
						end
					else
						filters << 'is_sitenmei' << 'is_sei' << 'is_mei' << 'is_title'
					end
				end
				if 0 < filters.length
					filter = ["(%s) AND value LIKE ?" % [filters.join(' OR ')], '%s%%' % [w] ]
				else
					filter = ["value LIKE ?", '%s%%' % [w] ]
				end
				result = where(filter).order(:value).each.map{|r| r.value }
			end
		end
		result
	end

end
