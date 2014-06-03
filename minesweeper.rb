

#TO RUN GAME: $> ruby minesweeper.rb

require 'gosu'
require_relative 'minefield'
require_relative 'timer'


class Minesweeper < Gosu::Window
  SCREEN_WIDTH = 1028
  SCREEN_HEIGHT = 720

  attr_reader :field, :mine_font, :large_font, :state, :timer, :time_to_display

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false)

    @field = Minefield.new(15, 15, 38)
    @mine_font = Gosu::Font.new(self, "Arial", (cell_size / 1.2).to_i)
    @large_font = Gosu::Font.new(self, "Arial", screen_height / 6)
    @state = :running
    @timer = Timer.new
  end

  def button_down(key)
    case key
    when Gosu::MsLeft
      if state == :running
        if within_field?(mouse_x, mouse_y)
          row, col = screen_coord_to_cell(mouse_x, mouse_y)
          field.clear(row, col)

          if field.any_mines_detonated?
            @state = :lost

          elsif field.all_cells_cleared?
            @state = :cleared
          end
        end
      end
    when Gosu::KbEscape
      close
    when Gosu::KbSpace
      if state != :running
        reset
      end
    end
  end

  def reset
    @field = Minefield.new(20, 20, 50)
    @state = :running
  end

  def draw_timer
    @time_to_display = @timer.update_time

    if @state == :running
     draw_text(5,50, @time_to_display, mine_font)
    end

  end

  def draw
    draw_rect(0, 0, screen_width, screen_height, Gosu::Color::GREEN)
    draw_rect(start_x, start_y, field_width, field_height, Gosu::Color::BLACK)
    draw_timer

    dark_gray = Gosu::Color.new(50, 50, 50)
    gray = Gosu::Color.new(127, 127, 127)
    light_gray = Gosu::Color.new(200, 200, 200)

    (0...field.row_count).each do |row|
      (0...field.column_count).each do |col|
        x = start_x + (col * cell_size)
        y = start_y + (row * cell_size)

        adjacent_mines = 0

        if field.contains_mine?(row, col) && state == :lost
          color = Gosu::Color::RED
        elsif !field.cell_cleared?(row, col)
          color = gray
        else
          adjacent_mines = field.adjacent_mines(row, col)
          color = light_gray
        end

        draw_rect(x, y, cell_size, cell_size, dark_gray)
        draw_rect(x + 2, y + 2, cell_size - 4, cell_size - 4, color)

        if adjacent_mines > 0
          text_x = x + (cell_size - mine_font.text_width(adjacent_mines)) / 2
          text_y = y + (cell_size - mine_font.height) / 2

          draw_text(text_x, text_y, adjacent_mines, mine_font)
        end
      end
    end

    case state
    when :lost
      draw_text_centered("game over", large_font)
      draw_text_side("#{@time_to_display}", mine_font)

      @timer.stop

    when :cleared
      draw_text_centered("cleared!", large_font)
    end
  end

  def cell_size
    max_cell_width = (screen_width * 0.90) / field.column_count
    max_cell_height = (screen_height * 0.90) / field.row_count

    if max_cell_width > max_cell_height
      max_cell_height
    else
      max_cell_width
    end
  end

  def field_width
    cell_size * field.column_count
  end

  def field_height
    cell_size * field.row_count
  end

  def start_x
    (screen_width - field_width) / 2.0
  end

  def start_y
    (screen_height - field_height) / 2.0
  end

  def needs_cursor?
    true
  end

  def draw_rect(x, y, width, height, color)
    draw_quad(x, y, color,
      x + width, y, color,
      x + width, y + height, color,
      x, y + height, color)
  end

  def draw_text(x, y, text, font)
    font.draw(text, x, y, 1, 1, 1, Gosu::Color::BLACK)
  end

  def draw_text_centered(text, font)
    x = (screen_width - font.text_width(text)) / 2
    y = (screen_height - font.height) / 2

    draw_text(x, y, text, font)

  end

  def draw_text_side(text, font)
    x = 5
    y = 50

    draw_text(x,y, text, font)
  end

  def within_field?(x, y)
    x >= start_x && x < (start_x + field_width) &&
      y >= start_y && y < (start_y + field_height)
  end

  def screen_coord_to_cell(x, y)
    col = ((x - start_x) / cell_size).to_i
    row = ((y - start_y) / cell_size).to_i

    [row, col]
  end

  def screen_width
    width
  end

  def screen_height
    height
  end
end

game = Minesweeper.new
game.show
