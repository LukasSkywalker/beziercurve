module Bezier

	class ControlPoint
		# maybe replace the accessors and initialization with Struct
		attr_accessor :x, :y
		def initialize(x,y)
			@x = x
			@y = y
		end
		def - (b)
			self.class.new(self.x - b.x, self.y - b.y)
		end
		def + (b)
			self.class.new(self.x + b.x, self.y + b.y)
		end
		def inspect
			return @x, @y
		end
		def to_curve
			CurvePoint.new(self.x, self.y)
		end
	end
	class CurvePoint < ControlPoint # minimal type safety, but both class have the same functionality
		def to_control
			ControlPoint.new(self.x, self.y)
		end
	end
	class Curve
		attr_accessor :hullpoints

		def initialize(hullpoints)
			# need at least 3 control points
			if hullpoints.length < 3 then
				raise "Cannot create Bézier curve with less than 3 control points" 
			end

			# check for rogue value types
			if hullpoints.find {|p| p.class != ControlPoint} == nil
				@hullpoints = hullpoints
			end
		end

		def add(point)
			if point.class == ControlPoint
				@hullpoints << point
			else
				raise TypeError, "Point should be type of ControlPoint"
			end
		end

		def point_on_curve(t)
			
			def point_on_hull(point1, point2, t) # making this local
				if (point1.class != ControlPoint) or (point2.class != ControlPoint)
					raise TypeError, "Both points should be type of ControlPoint"
				end
				new_x = (point1.x - point2.x) * t
				new_y = (point1.y - point2.y) * t
				return ControlPoint.new(new_x, new_y)
			end

			# imperatively ugly but works, refactor later. point_on_curve and point_on_hull should be one method
			ary = @hullpoints
			return ary if ary.length <= 1 # zero or one element as argument, return unmodified

			while ary.length > 1
				temp = []
				0.upto(ary.length-2) do |index|
					memoize1 = point_on_hull(ary[index], ary[index+1], t) 
					temp << ary[index+0] - memoize1 
				end
				ary = temp
			end
			return temp[0].to_curve
		end

		def display_points # just a helper, for quickly put CotrolPOints to STDOUT in a gnuplottable format
			@hullpoints.map{|point| puts "#{point.x} #{point.y}"}
		end

		def enumerated(start_t, delta_t)
	  		Enumerator.new do |yielder|
	  			point_position = start_t.to_f
	    		number = point_on_curve(point_position)
	    		loop do
	      			yielder.yield(number)
	      			point_position += delta_t.to_f
	      			raise StopIteration if point_position > 1
	      			number = point_on_curve(point_position)
	    		end
	  		end
		end
	end
end

# class Array
#   def with_next
#     i = 0
#     until i == size-1
#       yield self[i], self[i+1]
#       i += 1
#     end
#   end
# end

bezier = Bezier::Curve.new([Bezier::ControlPoint.new(40,250), Bezier::ControlPoint.new(35,100), Bezier::ControlPoint.new(150,70), Bezier::ControlPoint.new(210,120)]) # cubic curve, 4 coordinates

puts bezier.hullpoints[0].x
#puts "#{bezier.point_on_curve(0.013).x} #{bezier.point_on_curve(0.013).y}"