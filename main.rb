require 'gosu'
require './shapez'
require './linearAlgebra'

class GameWindow < Gosu::Window
    attr_accessor :camera, :objects
    SIZE = 50 # number of rows / cols
    RESOLUTION = 12 # number of pixels per grid space
    BG_COLOR = Gosu::Color::WHITE
    OBJ_COLOR = Gosu::Color::RED

    def initialize
        # Make window
        super SIZE*RESOLUTION, SIZE*RESOLUTION, false # initializes basic window
        @caption = 'HELP I\'M TRAPPED IN A SIMULACRUM OF REGISTERS'
        @step_count = 0

        # Construct camera
        @camera = Camera.new(0, 0, 800)

        # Populate world-> This could be done elsewhere for a full raytracer
        @objects = [Shapez::Square.new(0,0,0)]
    end

    # Called at 60Hz, repopulates / effects world objects
    def update
        if @step_count == 20 # 3 times / s
            @step_count = 0
        else
            @step_count += 1
        end
    end

    # Does a handy-dandy 3d projection to the window
    def draw
        # Draw background
        self.draw_quad(0, 0, BG_COLOR,
                       self.width, 0, BG_COLOR,
                       self.width, self.height, BG_COLOR,
                       0, self.height, BG_COLOR)
        @objects.each do |obj|
            coords = obj.draw(self)
            self.draw_quad(coords[0].x, coords[0].y, OBJ_COLOR,
                           coords[1].x, coords[1].y, OBJ_COLOR,
                           coords[2].x, coords[2].y, OBJ_COLOR,
                           coords[3].x, coords[3].y, OBJ_COLOR)
        end
    end
end

class Camera
    attr_accessor :world_location, :orientation, :focal_length
    def initialize(x,y,z)
        @world_location = LinearAlgebra::Vector3D.new(x,y,z)
        @orientation = LinearAlgebra::Collection3D.new(0,0,Math::PI) # TODO: Move this
        @focal_length = 100 # This will have to be adjusted when I set the world scale
    end
end

window = GameWindow.new
window.show
