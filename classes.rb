# THIS IS THE ONLY FUCKING FILE K DEAL WITH IT

PIX_PER_GRID = 50
GRID_PADDING = 5
PIX_PER_SQUARE = PIX_PER_GRID - 2 * GRID_PADDING

class Square
    attr_accessor :coords
    def initialize(x, y, z)
        @coords = Coord3D.new(x,y,z)
    end

    def draw
        @coords
    end
end

#class CoordConverter2D:
#    attr_accessor :abs_coords
#
#    def initialize
#        @abs_coords = args.get(:abs_coords, nil)
#        @sq_coords = args.get(:sq_coords, nil)
#
#        unless @abs_coords.nil? and @sq_coords.nil?:
#            if not @abs_coords.nil? and not @sq_coords.nil?:
#                if (@abs_coords.get(:x, 0).to_f / PIX_PER_GRID).round != @sq_coords.get(:x, nil) or
#                    (@abs_coords.get(:y, 0).to_f / PIX_PER_GRID).round != @sq_coords.get(:y, nil):
#                    @abs_coords = @sq_coords = nil
#
#                end
#            elsif @abs_coords.nil?:
#                @abs_coords = @sq_coords.map { |c| c * PIX_PER_GRID }
#
#            elsif @sq_coords.nil?
#                @sq_coords = @abs_coords.map { |c| (c.to_f / PIX_PER_GRID).round }
#
#            end
#        end
#    end
#end

# IMMA HOMEROLL SOME MOTHAFUCKIN LINEAR ALGEBRA UP IN HUR

class Collection2D:
    attr_accessor :x, :y
    def initialize(x, y)
        @x = x
        @y = y
    end
end

class Coord2D < Collection2D end
class Vector2D < Collection2D end

class Axis2D < Vector2D
    attr_accessor :x_axis, :y_axis
    def initialize(x, y)
        super x, y
        @x_axis = Vector2D.new(1,0)
        @y_axis = Vector2D.new(0,1)
    end
end

class Collection3D < Collection3D:
    attr_accessor :z

    def initialize(x,y,z)
        super x, y
        @z = z
    end
end

class Coord3D < Collection3D
    def :+ (x)
        Coord3d.new(self.x + x.x, self.y + x.y, self.z + x.z)
    end

    def :- (x)
        Coord3d.new(self.x - x.x, self.y - x.y, self.z - x.z)
    end
end

class Vector3D < Collection3D
    def :+ (x)
        Vector3d.new(self.x + x.x, self.y + x.y, self.z + x.z)
    end

    def :- (x)
        Vector3d.new(self.x - x.x, self.y - x.y, self.z - x.z)
    end

    def :* (n)
        Vector3d.new(self.x * x.x, self.y * x.y, self.z * x.z)
    end

    def :/ (n)
        Vector3d.new(self.x / x.x, self.y / x.y, self.z / x.z)
    end

    def dot(x)
        self.x * x.x + self.y * x.y + self.z * x.z
    end

    def cross(x)
        Vector3d.new((self.y * x.z - self.z * x.y), (self.z * x.x - self.x * x.z), (self.x * x.y - self.y * x.x))
    end

    def magnitude
        Math.sqrt(self.x**2 + self.y**2 + self.z**2)
    end

    def normal
        self / self.magnitude
    end
end

class Axis3D < Vector3D
    attr_accessor :x_axis, :y_axis, :z_axis

    def initialize(x,y,z)
        super x,y,z
        @x_axis = Vector3D.new(1,0,0)
        @y_axis = Vector3D.new(0,1,0)
        @z_axis = Vector3D.new(0,0,1)
    end

    def pitch(dT)

    end

    def roll(dT)

    end

    def yaw(dT)

    end
end

# Support for both camera and square axis, might override this

# BUT FIRST, a discussion of coordinates.

# World coordinates- absolute
# Square Coordinates- with reference to grid. For simplicity, making the origin
#   at the same location as the world origin
# Camera Coordinates- with reference to viewer ("camera"). Should also hold info
#   about screen?
