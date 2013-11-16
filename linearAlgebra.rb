# THIS IS THE ONLY FUCKING FILE K DEAL WITH IT
# Update: this is no longer the only fucking file

# Support for both camera and square axis, might override this

# BUT FIRST, a discussion of coordinates.

# World coordinates- absolute
# Square Coordinates- with reference to grid. For simplicity, making the origin
#   at the same location as the world origin
# Camera Coordinates- with reference to viewer ("camera"). Should also hold info
#   about screen?

# IMMA HOMEROLL SOME MOTHAFUCKIN LINEAR ALGEBRA UP IN HUR
# AND FUCK IMMA DO IT POORLY AS A MOTHERFUCKER BUT YOU KNOW WHAT OH WELL DEAL
# FUCK FUCK FUCK EVERYTHING IS BURNING FUCK
require 'logging'

module LinearAlgebra
    LOGGER = Logging.logger[self]
    def self.projection3D(a, c, th, e_z)
        # Calculate d_x,y,z, the vector from the camera to the given point
        # Thanks wikipedia!
        dx = Math.cos(th.y) * (Math.sin(th.z) * (a.y-c.y) + Math.cos(th.z) *
            (a.x-c.x)) - Math.sin(th.y) * (a.z-c.z)
        dy = Math.sin(th.x) * (Math.cos(th.y) * (a.z-c.z) + Math.sin(th.y) *
            (Math.sin(th.z) * (a.y-c.y) + Math.cos(th.z) * (a.x-c.x))) +
            Math.cos(th.x) * (Math.cos(th.z) * (a.y-c.y) - Math.sin(th.z) *
            (a.x-c.x))
        dz = Math.cos(th.x) * (Math.cos(th.y) * (a.z-c.z) + Math.sin(th.y) *
            (Math.sin(th.z) * (a.y-c.y) + Math.cos(th.z) * (a.x - c.x))) -
            Math.sin(th.x) * (Math.cos(th.z) * (a.y-c.y) - Math.sin(th.z) *
            (a.x-c.x))
        LOGGER.info 'Direction vector calculated at ' +
            "#{Vector3D.new(dx,dy,dz).inspect}"
        Vector2D.new((e_z / dz) * dx, (e_z / dz) * dy)
    end

    class Collection2D
        attr_accessor :x, :y
        def initialize(x, y)
            @x = x
            @y = y
        end
    end

    class Coord2D < Collection2D
        def to_window_coords(window)
            Coord2D.new((window.width / 2.0) + @x, (window.height / 2.0) - @y)
        end
    end

    class Vector2D < Collection2D
        def to_window_coords(window)
            Vector2D.new((window.width / 2.0) + @x, (window.height / 2.0) - @y)
        end
    end

    class Axis2D < Vector2D
        attr_accessor :x_axis, :y_axis
        def initialize(x, y)
            super x, y
            @x_axis = Vector2D.new(1,0)
            @y_axis = Vector2D.new(0,1)
        end
    end

    class Collection3D < Collection2D
        attr_accessor :z

        def initialize(x,y,z)
            super x, y
            @z = z
        end
    end

    class Coord3D < Collection3D
        def +(x)
            Coord3D.new(@x + x.x, @y + x.y, @z + x.z)
        end

        def -(x)
            Coord3D.new(@x - x.x, @y - x.y, @z - x.z)
        end
    end

    class Vector3D < Collection3D
        def +(n)
            if n.class == Float or n.class == Fixnum
                Vector3D.new(@x + n, @y + n, @z + n)
            else
                Vector3D.new(@x + n.x, @y + n.y, @z + n.z)
            end
        end

        def -(n)
            if n.class == Float or n.class == Fixnum
                Vector3D.new(@x - n, @y - n, @z - n)
            else
                Vector3D.new(@x - n.x, @y - n.y, @z - n.z)
            end
        end

        def *(n)
            if n.class == Float or n.class == Fixnum
                Vector3D.new(@x * n, @y * n, @z * n)
            else
                Vector3D.new(@x * n.x, @y * n.y, @z * n.z)
            end
        end

        def /(n)
            if n.class == Float or n.class == Fixnum
                Vector3D.new(@x / n, @y / n, @z / n)
            else
                Vector3D.new(@x / n.x, @y / n.y, @z / n.z)
            end
        end

        def dot(x)
            @x * x.x + @y * x.y + @z * x.z
        end

        def cross(x)
            Vector3D.new((@y * x.z - @z * x.y),
                         (@z * x.x - @x * x.z),
                         (@x * x.y - @y * x.x))
        end

        def magnitude
            Math.sqrt(@x**2 + @y**2 + @z**2)
        end

        def normalize!
            self / self.magnitude
        end

        def to_a
            [@x, @y, @z]
        end
    end

    class Matrix33
        attr_accessor :vals
        def initialize(v)
            @vals = v
        end

        # This is maybe a super inefficient way to do this
        # Also this could be generalized WAAAAY better
        # Also I don't give a flying fuck
        def *(x)
            a_r1 = Vector3D.new(*@vals[0])
            a_r2 = Vector3D.new(*@vals[1])
            a_r3 = Vector3D.new(*@vals[2])
            
            b_c1 = Vector3D.new(x.vals[0][0], x.vals[1][0], x.vals[2][0])
            b_c2 = Vector3D.new(x.vals[0][1], x.vals[1][1], x.vals[2][1])
            b_c3 = Vector3D.new(x.vals[0][2], x.vals[1][2], x.vals[2][2])

            Matrix33.new([[a_r1.dot(b_c1), a_r1.dot(b_c2), a_r1.dot(b_c3)],
                          [a_r2.dot(b_c1), a_r2.dot(b_c2), a_r2.dot(b_c3)],
                          [a_r3.dot(b_c1), a_r3.dot(b_c2), a_r3.dot(b_c3)]])
        end
    end

    class RotationMatrix
        def initialize(p, y, r)
            pitch = Matrix33.new(
                    [[1, 0, 0],
                    [0, Math.cos(p), -1*Math.sin(p)],
                    [0, Math.sin(p), Math.cos(p)]])
            yaw = Matrix33.new(
                    [[Math.cos(y), 0, Math.sin(y)],
                    [0, 1, 0],
                    [-1*Math.sin(y), 0, Math.cos(y)]])
            roll = Matrix33.new(
                    [[Math.cos(r), -1*Math.sin(r), 0],
                    [Math.sin(r), Math.cos(r), 0],
                    [0, 0, 1]])
            @R = pitch * yaw * roll
        end

        def apply_to(v)
            a = @R.vals.map {|r| Vector3D.new(*r).dot(v)}
            Vector3D.new(*a)
        end
    end

    class Axis3D
        attr_accessor :x_axis, :y_axis, :z_axis, :o

        def initialize(x,y,z)
            @o = Vector3D.new(x,y,z)
            @x_axis = Vector3D.new(1,0,0)
            @y_axis = Vector3D.new(0,1,0)
            @z_axis = Vector3D.new(0,0,1)
            @logger = LinearAlgebra::LOGGER
        end

        def rotate(dP, dY, dR)
            @logger.debug "Preparing rotation, axis at #{self.inspect}"
            r = RotationMatrix.new(dP.to_f*(Math::PI / 180.0),
                                   dY.to_f*(Math::PI / 180.0),
                                   dR.to_f*(Math::PI / 180.0) 
                                  )
            @x_axis = r.apply_to(@x_axis).normalize
            @y_axis = r.apply_to(@y_axis).normalize
            @z_axis = r.apply_to(@z_axis).normalize
            @logger.debug "Rotation applied, axis now at #{self.inspect}"
        end

        def move(v)
            @o += v
        end
    end
end
