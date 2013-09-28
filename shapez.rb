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
        def draw(window)
            # Project dat, probs a better way to do this
            v = coords.inject([]) do |a, v|
                a << LinearAlgebra.projection3D(
                        v[1],
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

    # This is currently a pretty bad ih struct, would be better to have a
    # generic shape, have grid and shape inherit from it, and take the grid shape
    # as an argument. I could do sweet dot matrices that way.
    class Grid < Square
        attr_accessor :spots
        def initialize(cx, cy, cz, size, window)
            # Construct location and borders
            super cx, cy, cz

            # Build subsquares
            @spots = Array.new(size**2) { Square.new(0,0,0) }
            # Build top left to bottom right
            @spots.each_with_index do |s,i|
                c = LinearAlgebra::Vector2D.new((i % size) - (size / 2), (i / size) - (size / 2))
                s.center.move(LinearAlgebra::Vector3D.new(c.x * PTS_PER_GRID,
                                                          c.y * PTS_PER_GRID,
                                                          0))
                @logger.debug "Grid spot center at #{s.center.inspect}\n"
            end
            @logger = LOGGER
        end

        def draw(window)
            # Return all coords
            @spots.each { |x| x.draw window }
        end
    end
end
