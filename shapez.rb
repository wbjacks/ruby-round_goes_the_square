module Shapez
    PTS_PER_GRID = 50
    GRID_PADDING = 5
    PTS_PER_SQUARE = PTS_PER_GRID - 2 * GRID_PADDING

    class Square
        attr_accessor :coords
        def initialize(x, y, z)
            @center = LinearAlgebra::Coord3D.new(x,y,z)

            # Construct on xy plane
            @corner_ne = @center +
                LinearAlgebra::Vector3D.new(PTS_PER_SQUARE / 2,
                                            PTS_PER_SQUARE / 2
                                            0)
            @corner_se = @center +
                LinearAlgebra::Vector3D.new(PTS_PER_SQUARE / 2,
                                            PTS_PER_SQUARE / 2,
                                            0) 
            @corner_sw = @center +
                LinearAlgebra::Vector3D.new(PTS_PER_SQUARE / 2,
                                            PTS_PER_SQUARE / 2,
                                            0)
            @corner_nw = @center +
                LinearAlgebra::Vector3D.new(PTS_PER_SQUARE / 2,
                                            PTS_PER_SQUARE / 2,
                                            0)
        end

        def draw
            @coords
        end
    end
end
