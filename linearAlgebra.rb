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
module LinearAlgebra
    def projection3d(a, c, th, e_z)
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
            Math.sin(th.x) * (Math.cos(th.x) * (a.y-c.y) - Math.sin(th.z) *
            (a.x-c.x))
        Vector2D.new((e_z / dz) * dx, (e_z / dz) * dy)
    end

    class Collection2D
        attr_accessor :x, :y
        def initialize(x, y)
            @x = x
            @y = y
        end
    end

    class Coord2D < Collection2D; end
    class Vector2D < Collection2D; end

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
            Coord3d.new(self.x + x.x, self.y + x.y, self.z + x.z)
        end

        def -(x)
            Coord3d.new(self.x - x.x, self.y - x.y, self.z - x.z)
        end
    end

    class Vector3D < Collection3D
        def +(x)
            Vector3d.new(self.x + x.x, self.y + x.y, self.z + x.z)
        end

        def -(x)
            Vector3d.new(self.x - x.x, self.y - x.y, self.z - x.z)
        end

        def *(n)
            Vector3d.new(self.x * x.x, self.y * x.y, self.z * x.z)
        end

        def /(n)
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

        def to_a
            [self.x, self.y, self.z]
        end
    end

    class Matrix33
        def initialize(v)
            @vals = vals
        end

        # This is maybe a super inefficient way to do this
        # Also this could be generalized WAAAAY better
        # Also I don't give a flying fuck
        def *(x)
            a_r1 = Vector3D.new(*self.vals[0])
            a_r2 = Vector3D.new(*self.vals[1])
            a_r3 = Vector3D.new(*self.vals[2])
            
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
                    [0, Math.sin(p), -1*Math.cos(p)]])
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
            a = self.map {|r| r.dot(v)}
            Vector3D(*a)
        end
    end

    class Axis3D
        attr_accessor :x_axis, :y_axis, :z_axis, :o

        def initialize(x,y,z)
            @o = Coord3D.new(x,y,z)
            @x_axis = Vector3D.new(1,0,0)
            @y_axis = Vector3D.new(0,1,0)
            @z_axis = Vector3D.new(0,0,1)
        end

        def rotate(dP, dY, dR)
            r = RotationMatrix.new(dP.to_f*(Math.PI / 180.0),
                                   dY.to_f*(Math.PI / 180.0),
                                   dR.to_f*(Math.PI / 180.0) 
                                  )
            @x_axis = r.apply_to(@x_axis)
            @y_axis = r.apply_to(@y_axis)
            @z_axis = r.apply_to(@z_axis)
        end

        def move(v)
            @o += v
        end
    end
end
