module ApplicationHelper
end

class Array
	def fold(n)
		result = Array.new
		r = nil
		self.each_index do |i|
			if (i % n) == 0
				r = Array.new
				result << r
			end
			r << self[i]
		end
		result
	end
end
