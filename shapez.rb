require './linearAlgebra'
require 'logging'

# As per discussion of points in linearAlgebra.rb:
# Each shape has a central axis defined in world coordinates. It also has vertex
# data defined in reference to this frame. Thus, to get the world location of
# the vertices, one must simply transform the points by the frame.

module Shapez
    PTS_PER_GRID = 20
    GRID_PADDING = 1
    PTS_PER_SQUARE = PTS_PER_GRID - (2 * GRID_PADDING)
    OBJ_COLOR = Gosu::Color::RED
    LOGGER = Logging.logger[self]

    # Point has infintesimally small size, but gets a small amount of size for
    # drawing
    class Point
        attr_accessor :center
        VIRTUAL_SIZE = 3
        def initialize(x, y, z)
            @center = LinearAlgebra::Coord3D.new(x,y,z)
            @vir_verts = [
                LinearAlgebra::Vector3D.new(
                    Math.cos(Math::PI/2.0),
                    Math.sin(Math::PI/2.0),
                    0),
                LinearAlgebra::Vector3D.new(
                    Math.cos((5.0*Math::PI)/4.0),
                    Math.sin((5.0*Math::PI)/4.0),
                    0),
                LinearAlgebra::Vector3D.new(
                    Math.cos((7.0*Math::PI)/4.0),
                    Math.sin((7.0*Math::PI)/4.0),
                    0)]
        end

        def coords
            @vir_verts.map { |v| @center + (v * VIRTUAL_SIZE) }
        end

        def draw(w, c)
            cs = coords.inject([]) do |a, v|
                a << LinearAlgebra.projection3D(
                        v,
                        w.camera.world_location,
                        w.camera.orientation,
                        w.camera.focal_length)
                a # idk why this is needed but it is
            end
            w.draw_triangle(cs[0].to_window_coords(w).x, cs[0].to_window_coords(w).y, c,
                            cs[1].to_window_coords(w).x, cs[1].to_window_coords(w).y, c,
                            cs[2].to_window_coords(w).x, cs[2].to_window_coords(w).y, c)
        end
    end

    class Square
        attr_accessor :coords, :center
        def initialize(x, y, z)
            @center = LinearAlgebra::Axis3D.new(x,y,z)
            @logger = LOGGER

            # Construct on xy plane with reference to @center
            @corner_ne = LinearAlgebra::Vector3D.new(PTS_PER_SQUARE / 2.0,
                                                     PTS_PER_SQUARE / 2.0,
                                                     0.0)
            @corner_se = LinearAlgebra::Vector3D.new(PTS_PER_SQUARE / 2.0,
                                                     PTS_PER_SQUARE / -2.0,
                                                     0.0) 
            @corner_sw = LinearAlgebra::Vector3D.new(PTS_PER_SQUARE / -2.0,
                                                     PTS_PER_SQUARE / -2.0,
                                                     0.0)
            @corner_nw = LinearAlgebra::Vector3D.new(PTS_PER_SQUARE / -2.0,
                                                     PTS_PER_SQUARE / 2.0,
                                                     0.0)
            @logger.debug "Instance created: #{self.inspect}"
        end

        # Returns world coords
        def coords
            ne = @center.o +
                (@center.x_axis*@corner_ne.x + @center.y_axis*@corner_ne.y +
                @center.z_axis*@corner_ne.z)
            se = @center.o +
                (@center.x_axis*@corner_se.x + @center.y_axis*@corner_se.y +
                @center.z_axis*@corner_se.z)
            sw = @center.o +
                (@center.x_axis*@corner_sw.x + @center.y_axis*@corner_sw.y +
                @center.z_axis*@corner_sw.z)
            nw = @center.o +
                (@center.x_axis*@corner_nw.x + @center.y_axis*@corner_nw.y +
                @center.z_axis*@corner_nw.z)
            {:corner_ne => ne, :corner_se => se, :corner_sw => sw,
                :corner_nw => nw}
        end

        # Runs 3D projection on to window
        def draw(window, c)
            # Project dat, probs a better way to do this
            v = coords.inject([]) do |a, v|
                a << LinearAlgebra.projection3D(
                        v[1], # v is a [key,value]
                        window.camera.world_location,
                        window.camera.orientation,
                        window.camera.focal_length)
                a # idk why this is needed but it is
            end
            @logger.debug "Projected coords are: #{v.inspect}"
            window.draw_quad(
                v[0].to_window_coords(window).x, v[0].to_window_coords(window).y, OBJ_COLOR,
                v[1].to_window_coords(window).x, v[1].to_window_coords(window).y, OBJ_COLOR,
                v[2].to_window_coords(window).x, v[2].to_window_coords(window).y, OBJ_COLOR,
                v[3].to_window_coords(window).x, v[3].to_window_coords(window).y, OBJ_COLOR)
        end
    end

    class Edge
        VERT_SPACE = 5
        def initialize(p1, p2)
            @src = p1
            @dest = p2
            @dir = LinearAlgebra::Vector3D.new((p2.x - p1.x), (p2.y - p1.y), (p2.z - p1.z))
            @dir = @dir.normalize!
        end

        def draw(w, c)
            # Basic style... give the point a little space
            st = LinearAlgebra.projection3D(@src + (@dir * VERT_SPACE),
                                              w.camera.world_location,
                                              w.camera.orientation,
                                              w.camera.focal_length)
            ed = LinearAlgebra.projection3D(@dest - (@dir * VERT_SPACE),
                                               w.camera.world_location,
                                               w.camera.orientation,
                                               w.camera.focal_length)
            w.draw_line(st.to_window_coords(w).x,
                        st.to_window_coords(w).y, c,
                        ed.to_window_coords(w).x,
                        ed.to_window_coords(w).y, c)
        end
    end

    # This is currently a pretty bad ih struct, would be better to have a
    # generic shape, have grid and shape inherit from it, and take the grid shape
    # as an argument. I could do sweet dot matrices that way.
    class SqureGrid < Square
        attr_accessor :spots
        def initialize(cx, cy, cz, size)
            # Construct location and borders
            super cx, cy, cz

            # Build subsquares
            @spots = Array.new(size**2) { Square.new(0,0,0) }
            # Build top left to bottom right
            @spots.each_with_index do |s,i|
                c = LinearAlgebra::Vector2D.new((i % size) - (size / 2),
                                                (i / size) - (size / 2))
                s.center.move(LinearAlgebra::Vector3D.new(c.x * PTS_PER_GRID,
                                                          c.y * PTS_PER_GRID,
                                                          0))
                @logger.debug "Grid spot center at #{s.center.inspect}\n"
            end
            @logger = LOGGER
        end

        def draw(window, c)
            # Return all coords
            @spots.each { |x| x.draw window }
        end
    end

    class Vertex < Point
        attr_accessor :neighborhood
        def initialize(p)
            super p.x, p.y, p.z

            # Create neighborhood map
            @neighborhood = Hash.new { false }
        end
    end

    # Base mesh class
    class SquareMesh < Square
        def initialize(c, density, size)
            # Construct location and borders
            super c.x, c.y, c.z
            density = 1 #don't want to deal with this yet

            # Build vertices
            @verts = Array.new

            # Build top left to bottom right
            0.upto((size * density)**2 - 1).count do |i|
                c = LinearAlgebra::Vector2D.new((i % size) - (size / 2), (i / size) - (size / 2))
                @verts << Vertex.new(LinearAlgebra::Coord3D.new(
                    c.x * PTS_PER_GRID,
                    c.y * PTS_PER_GRID,
                    0))
            end

            # Build edges- prettier way to do this
            @edges = Array.new
            @verts.each_with_index do |v, i|
                # North
                ti = i - size
                unless ti < 0
                    dest = @verts[ti]
                    unless dest.nil? or dest.neighborhood[:s]
                        @edges << Edge.new(v.center, dest.center) 
                        dest.neighborhood[:s] = true
                    end
                end

                # South
                ti = i - size
                unless ti >= (size * density)**2
                    dest = @verts[ti]
                    unless dest.nil? or dest.neighborhood[:n]
                        @edges << Edge.new(v.center, dest.center) 
                        dest.neighborhood[:n] = true
                    end
                end

                # East- Check edge
                unless (i+1) % size == 0
                    dest = @verts[i + 1]
                    unless dest.nil? or dest.neighborhood[:w]
                        @edges << Edge.new(v.center, dest.center) 
                        dest.neighborhood[:w] = true
                    end
                end

                # West- Check edge
                unless i % size == 0
                    dest = @verts[i - 1]
                    unless dest.nil? or dest.neighborhood[:e]
                        @edges << Edge.new(v.center, dest.center) 
                        dest.neighborhood[:e] = true
                    end
                end
            end

            @logger = LOGGER
        end

        def draw(window, c)
            # Return all coords
            @verts.each { |x| x.draw(window, c) }
            @edges.each { |x| x.draw(window, Gosu::Color::RED) }
        end
    end
end
