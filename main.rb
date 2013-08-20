require 'gosu'
require 'linear_algebra'

class GameWindow < Gosu::Window
    attr_accessor :board
    SIZE = 50 # number of rows / cols
    RESOLUTION = 12 # number of pixels per grid space
    BG_COLOR = Gosu::Color::WHITE

    def initialize
        # Make window
        super SIZE*RESOLUTION, SIZE*RESOLUTION, false # initializes basic window
        @caption = 'HELP I\'M TRAPPED IN A SIMULACRUM OF REGISTERS'
        @step_count = 0

        # Construct camera
        @camera = Camera.new(0, 0, 800)

        # Populate world-> This could be done elsewhere for a full raytracer
    end

    # Called at 60Hz, repopulates / effects world objects
    def update
        if @step_count == 20 # 3 times / s
            @board.step!
            @step_count = 0
        else
            @step_count += 1
        end
    end

    # Does a handy-dandy 3d projection to the window
    def draw
        self.draw_quad(0, 0, BG_COLOR,
                       self.width, 0, BG_COLOR,
                       self.width, self.height, BG_COLOR,
                       0, self.height, BG_COLOR)
        @board.draw
    end
end

class Camera
    def initialize(x,y,z)
        @world_location = LinearAlgebra::Vector3d.new(x,y,z)
        @orientation = LinearAlgebra::Collection3d.new(0,0,Math::PI) # TODO: Move this
        @focal_length = 100 # This will have to be adjusted when I set the world scale
    end
end

window = GameWindow.new
window.show
