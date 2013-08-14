require 'gosu'

# puts "Please enter size of board: "
# size = gets.chomp.to_i
# size
# b = GameOfLife::Board.new(size)
# b.populate_random!
# b.print

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

        # Populate world
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

window = GameWindow.new
window.show
