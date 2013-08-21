require './linearAlgebra'
require 'logging'

module Shapez
    PTS_PER_GRID = 50
    GRID_PADDING = 5
    PTS_PER_SQUARE = PTS_PER_GRID - (2 * GRID_PADDING)

    class Square
        attr_accessor :coords
        def initialize(x, y, z)
            @center = LinearAlgebra::Coord3D.new(x,y,z)
            @logger = Logging.logger[self]

            # Construct on xy plane
            @corner_ne = @center +
                LinearAlgebra::Vector3D.new(PTS_PER_SQUARE / 2.0,
                                            PTS_PER_SQUARE / 2.0,
                                            0.0)
            @corner_se = @center +
                LinearAlgebra::Vector3D.new(PTS_PER_SQUARE / 2.0,
                                            PTS_PER_SQUARE / -2.0,
                                            0.0) 
            @corner_sw = @center +
                LinearAlgebra::Vector3D.new(PTS_PER_SQUARE / -2.0,
                                            PTS_PER_SQUARE / -2.0,
                                            0.0)
            @corner_nw = @center +
                LinearAlgebra::Vector3D.new(PTS_PER_SQUARE / -2.0,
                                            PTS_PER_SQUARE / 2.0,
                                            0.0)
            @logger.info "Instance created: #{self.inspect}"
        end

        def coords
            {:center => @center, :corner_ne => @corner_ne,
             :corner_se => @corner_se, :corner_sw => @corner_sw,
             :corner_nw => @corner_nw}
        end

        # Runs 3D projection on to window
        def draw(window)
            # Project dat, probs a better way to do this
            v = coords.inject([]) do |a, v|
                unless v[0] == :center
                    a << LinearAlgebra.projection3D(
                            v[1],
                            window.camera.world_location,
                            window.camera.orientation,
                            window.camera.focal_length)
                end
                a # idk why this is needed but it is
            end
            @logger.debug "Projected coords are: #{v.inspect}"
            v # return coords
        end
    end
end
