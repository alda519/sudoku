class SudokuCore

  def initialize
    init_variables
  end
  
  def open_sudoku filename
    begin
      file = File.new filename, "r"
      9.times { |i|
        @sudoku[i] = Array.new
        9.times { |j|
          char = file.getc.chr
          redo if char == "\n" || char == " " || char == "\r"
          char = char.to_i
          if char == 0
            @sudoku[i][j] = [1,2,3,4,5,6,7,8,9]
          else
            @sudoku[i][j] = [char]
          end
        }
      }
      file.close
      true
    rescue
      false
    end
  end


  def solve_sudoku
    begin
      sizep = @sudoku.flatten.size
      check_rows
      check_cols
      check_cells
    end while sizep > @sudoku.flatten.size
    return @sudoku.flatten.size == 81
  end
  
private

  def init_variables
    @cols = Array.new 9
    @cols.each_index { |i|
      @cols[i] = [1,2,3,4,5,6,7,8,9]
    }

    @rows = Array.new 9
    @rows.each_index { |i|
      @rows[i] = [1,2,3,4,5,6,7,8,9]
    }

    @cells = Array.new 3
    @cells.each_index { |i|
      @cells[i] = [ [1,2,3,4,5,6,7,8,9], [1,2,3,4,5,6,7,8,9], [1,2,3,4,5,6,7,8,9] ]
    }
    @sudoku = Array.new
  end

  def del_row row, val
    @rows[row].delete val
    9.times { |i|
      @sudoku[row][i].delete val
    }
  end
  
  def del_col col, val
    @cols[col].delete val
    9.times { |i|
      @sudoku[i][col].delete val
    }
  end
  
  def del_cell x, y, val
    locx = x / 3
    locy = y / 3
    @cells[locx][locy].delete val
    (locx*3).upto(locx*3+2) { |i|
      (locy*3).upto(locy*3+2) { |j|
         @sudoku[i][j].delete val
      }
    }
  end

  def check_rows
    9.times { |row|
      @rows[row].each { |num|
        where = Array.new
        9.times { |col|
          where += [col] if @sudoku[row][col].include? num
        }
        where.each { |col|
          if where.length == 1 or @sudoku[row][col] == [num]
            del_row row, num
            del_col col, num
            del_cell row, col, num
            @sudoku[row][col] = [num]
            break
          end
        }
      }
    }
  end

  def check_cols
    9.times { |col|
      @cols[col].each { |num|
        where = Array.new
        9.times { |row|
          where += [row] if @sudoku[row][col].include? num
        }
        where.each { |row|
          if where.length == 1 or @sudoku[row][col] == [num] 
            del_row row, num
            del_col col, num
            del_cell row, col, num
            @sudoku[row][col] = [num]
            break
          end
        }
      }
    }
  end

  def check_cells
    3.times { |i|
      3.times { |j|
        @cells[i][j].each { |num|
          a = Array.new
          b = Array.new
          3.times { |x|
            3.times { |y|
              if @sudoku[i*3+x][j*3+y].include? num
                a += [i*3+x]
                b += [j*3+y]
              end
            }
          }
          if a.length == 1
            del_row a[0], num
            del_col b[0], num
            del_cell a[0], b[0], num
            @sudoku[a[0]][b[0]] = [num]
          else
            if a.uniq.length == 1
              9.times { |q|
                next if @sudoku[a[0]][q].length == 1
                z = @sudoku[a[0]][q].delete num if not b.include? q
                if @sudoku[a[0]][q].length == 1
                  tmp = @sudoku[a[0]][q][0]
                  del_row a[0], tmp
                  del_col q, tmp
                  del_cell a[0], q, tmp
                  @sudoku[a[0]][q] = [tmp]
                end 
              }
            elsif b.uniq.length == 1
              9.times { |q|
                next if @sudoku[q][b[0]].length == 1
                @sudoku[q][b[0]].delete num if not a.include? q
                if @sudoku[q][b[0]].length == 1
                  tmp = @sudoku[q][b[0]][0]
                  del_row q, tmp
                  del_col b[0], tmp
                  del_cell q, b[0], tmp
                  @sudoku[q][b[0]] = [tmp]
                end
              }
            end
          end
        }
      }
    }
  end
  
  
  def print
    9.times { |i|
      9.times { |j|
        if @sudoku[i][j].length == 1
          STDOUT.print @sudoku[i][j].to_s.delete('[]')
        else 
          STDOUT.print '0'
        end
      }
      puts
    }
    puts "\n"
  end

  def print_verbose
    9.times { |i|
      9.times { |j|
        STDOUT.print @sudoku[i][j].to_s.delete('[, ]'), ' '
      }
      puts
    }
    puts "\n"
  end

end

=begin
s = Sudoku_core.new
s.open_sudoku "E:/Prog/Ruby/TkSudoku/lehke.sudoku"
s.print
s.solve_sudoku
s.print
=end
