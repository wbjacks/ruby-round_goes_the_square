require './linearAlgebra'
require 'logging'

# As per discussion of points in linearAlgebra.rb:
# Each shape has a central axis defined in world coordinates. It also has vertex
# data defined in reference to this frame. Thus, to get the world location of
# the vertices, one must simply transform the points by the frame.

module Shapez
    PTS_PER_GRID = 50
    GRID_PADDING = 5
    PTS_PER_SQUARE = PTS_PER_GRID - (2 * GRID_PADDING)

    class Square
        attr_accessor :coords, :center
        def initialize(x, y, z)
            @center = LinearAlgebra::Axis3D.new(x,y,z)
            @logger = Logging.logger[self]

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
            @logger.info "Instance created: #{self.inspect}"
        end

        # Returns world coords
        def coords
            {:corner_ne => @center.o + @corner_ne,
             :corner_se => @center.o + @corner_se,
             :corner_sw => @center.o + @corner_sw,
             :corner_nw => @center.o + @corner_nw}
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
            v # return coords
        end
    end
end
