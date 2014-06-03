

#---------------------IMPLEMENTATION OF MINEFIELD CLASS-------------------------#

#Public variables made available to minesweeper.rb (main)


class Minefield
  MINE = "x"

  SURROUNDING_POSITIONS = lambda { |row, col| [[row+1,col-1],[row+1, col],[row+1,col+1],
                          [row, col-1],[row,col+1],[row-1,col-1],[row-1,col],[row-1, col+1]] }

  attr_reader :row_count, :column_count, :field, :mine_count

#---------------------CONSTRUCTOR-------------------#
  def initialize(row_count, column_count, mine_count)
    @column_count = column_count
    @row_count = row_count
    @mine_count = mine_count
    @mine_found = false

    @field = Array.new(row_count) {Array.new(column_count)}

    generate_mines
    generate_numbers

  end
#------------GENERATE FIRST BOARD WITH MINES--------------#
  def generate_mines
    mine_count.times do
       x = rand(column_count-1)
       y = rand(row_count-1)

       unless contains_mine?(x,y)
         x = rand(column_count-1)
         y = rand(row_count-1)
       end
       field[x][y] = MINE
    end
  end

#---------------GENERATE NUMBERS------------#
  def generate_numbers
    field.each_with_index do |row,r_index|
      row.each_with_index do |col,c_index|
        if field[r_index][c_index] != MINE
          field[r_index][c_index] = count_adjacent_mines(r_index, c_index)
        end
      end
    end
  end

#----------------CHECK IF CELL CLEARED----------#
  # Return true if the cell been uncovered, false otherwise.
  def cell_cleared?(row, col)
    if field[row][col] != MINE
      field[row][col] < 0 ? true : false
    end
  end

 # def clear_mines
 #    field.each_with_index do |row,r_i|
 #        row.each_with_index do |col,c_i|
 #          if contians_mine?(r_i,c_i)
 #            x = r_i
 #            y = c_i
 #          end
 #        end
 #    end

 #    x,y
 # end
#------------------CLEAR CELL----------------#
  # Uncover the given cell. If there are no adjacent mines to this cell
  # it should also clear any adjacent cells as well. This is the action
  # when the player clicks on the cell.
  def clear(row, col)
    if field[row][col] != MINE
      field[row][col] = field[row][col] * -1
      find_and_unveil(row,col)
    else
      @mine_found = true
    end
  end

#-----------------------FIND AND UNVEIL----------------#
  def find_and_unveil(row,col)
    if field[row][col] == -9
      neighbors_to_rerun_on = []


      SURROUNDING_POSITIONS.call(row, col).each do |rowcol|
        unveil_neighbors(rowcol[0],rowcol[1],neighbors_to_rerun_on)
      end

      # unveil_neighbors(row+1, col-1,neighbors_to_rerun_on)
      # unveil_neighbors(row+1, col,neighbors_to_rerun_on)
      # unveil_neighbors(row+1, col+1,neighbors_to_rerun_on)
      # unveil_neighbors(row, col-1,neighbors_to_rerun_on)
      # unveil_neighbors(row, col+1,neighbors_to_rerun_on)
      # unveil_neighbors(row-1, col-1,neighbors_to_rerun_on)
      # unveil_neighbors(row-1, col,neighbors_to_rerun_on)
      # unveil_neighbors(row-1, col+1,neighbors_to_rerun_on)
      neighbors_to_rerun_on.each do |cell_pair|
        find_and_unveil(cell_pair[0],cell_pair[1])
      end

    end
  end

#---------------------UNVEIL NEIGHBORS---------------#
  def unveil_neighbors(row,col,neighbors_to_rerun_on)
    if in_board?(row,col)
      if field[row][col] != MINE
        if field[row][col] > 0
          if field[row][col] == 9
            neighbors_to_rerun_on << [row,col]
          end
          field[row][col] = field[row][col] * -1
        end
      end
    end
  end

#----------------ANY_MINES_DETONATED--------------#
  # Check if any cells have been uncovered that also contained a mine. This is
  # the condition used to see if the player has lost the game.
  def any_mines_detonated?
    @mine_found
  end


#-----------------CHECK IF ALL_CELLS_CLEARED-------------#
  # Check if all cells that don't have mines have been uncovered. This is the
  # condition used to see if the player has won the game.
  def all_cells_cleared?
    total_cells = row_count * column_count
    cells_cleared = 0
    field.each_with_index do |row,r_i|
      row.each_with_index do |col,c_i|
        if field[r_i][c_i] != MINE
          if (field[r_i][c_i] < 0)
            cells_cleared += 1
          end
        end
      end
    end
    cells_cleared + 38 == total_cells ? (return true) : (return false)
  end

#-------------------CHECK IF CONTAINS MINE------------------#
  def contains_mine?(row, col)
    if field[row][col] == MINE
      return true
    end
  end


#-------------------COUNT_ADJACENT MINES---------------------#
  def count_adjacent_mines(row, col)
    num = 0

    SURROUNDING_POSITIONS.call(row, col).each do |rowcol|
      num += check_tile(rowcol[0],rowcol[1])
    end
    # num += check_tile(row-1, col-1)
    # num += check_tile(row-1, col)
    # num += check_tile(row-1, col+1)
    # num += check_tile(row, col-1)
    # num += check_tile(row, col+1)
    # num += check_tile(row+1, col-1)
    # num += check_tile(row+1, col)
    # num += check_tile(row+1, col+1)

    num == 0 ? (num = 9) : num

    num
  end

#--------------------ADJACENT MINES------------------#
  def adjacent_mines(row, col)
    value_to_display = (field[row][col]).abs
    if value_to_display == 9
      value_to_display = 0
    end
    value_to_display

  end

#---------------CHECK TILE---------------#
  def check_tile(row,col)
    if in_board?(row,col)
      if @field[row][col] == MINE
        return 1
      end
    end
    return 0
  end
#---------------CHECK IF IN BOARD--------------#
  def in_board?(row, col)
    (row >= 0 && col >= 0) && (row <= row_count-1 && col <= column_count-1)
  end

end
