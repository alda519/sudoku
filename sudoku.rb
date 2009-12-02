#!/usr/bin/ruby

require 'sudoku_core.rb'

require 'tk'

class TkSudoku < Sudoku_core

  Colors=["#daeaea", "#f8e7cd"] * 2
  DialogParams = { "defaultextension" => ".sudoku", "filetypes" => [["Sudoku", [".sudoku"]], ["All files", ["*.*"]]] }

  def initialize
    init_variables

    solve = proc { init_variables; update_sudoku; lockscreen; solve_sudoku; print; update_window }
    new   = proc { clear_all; unlockscreen }
    open  = proc {
      unlockscreen
      if open_sudoku Tk.getOpenFile( DialogParams.update("title"=>"Open Sudoku") ) then
        update_window
      else
        puts "error"
        # todo: mozna nejaky error dialog?
      end
    }
    save = proc {
      if not save_sudoku Tk.getSaveFile( DialogParams.update("title"=>"Save Sudoku") ) then
        puts "error"
        # todo: mozna nejaky error dialog?
      end
    }

    # toto odstranit potom
    prin = proc { begin; print; rescue; end }
    prin_ver = proc { begin; print_verbose; rescue; end }

    @root = TkRoot.new() { title "SUDOKU"; resizable  false, false } #;  geometry '306x312' } # ; iconbitmap "sudoku.ico" } # +-position_x+-position_y

    bar = TkMenu.new()
    sys = TkMenu.new(bar) { tearoff false }
    sys.add 'command', 'label'=>"New",  'underline'=>0, 'command' => new
    sys.add 'command', 'label'=>"Open", 'underline'=>0, 'command' => open
    sys.add 'command', 'label'=>"Save", 'underline'=>0, 'command' => save
    sys.add 'separator'
    sys.add 'command', 'label'=>"Quit", 'underline'=>0, 'command' => proc { @root.destroy }
    
    bar.add 'cascade', 'menu' => sys, 'label'=>"Menu", 'underline'=> 0
    bar.add 'command', 'label'=>"Solve", 'underline'=>0, 'command' => solve
    bar.add 'command', 'label'=>"Print", 'underline'=>0, 'command' => prin
    bar.add 'command', 'label'=>"Print!", 'underline'=>0, 'command' => prin_ver
    @root.menu bar

    @buttons = Array.new
    @values = Array.new

    9.times { |a|
      line = TkFrame.new#.pack 'expand'=>true
      3.times { |f|
        cell = TkFrame.new(line){ background Colors[(f%2)+(a/3)] } . pack "side"=>"left", 'expand'=>true
        3.times { |g|
          @values << TkVariable.new
          @buttons << TkEntry.new(cell, 'textvariable' => @values[-1]) { width 2; justify "center" }
          @buttons[-1].pack "side" => "left", 'expand' => true, "pady" => 5, "padx" => 4
          @buttons[-1].font('9x15')

          @buttons[-1].bind("Any-ButtonRelease") {
            @buttons[9*a+3*f+g].cursor = 1
          }
          @buttons[-1].bind("Any-KeyRelease") { |event|
            entries_any_key_event event, 9 * a + 3 * f + g
            puts "anyrelease"
          }
          #@buttons[-1].bind("Any-KeyPress") { |event|
          #   if @values[9 * a + 3 * f + g].value.size > 1 then
          #     @values[9 * a + 3 * f + g].value = "R"
          #   end
          #}
        }
      }
      line.pack# 'expand'=>true
    }
  end
  
  def clear_all
    @values.each { |a|
      a.value = ""
    }
  end

  def update_window
    9.times { |a|
      9.times { |b|
        if @sudoku[a][b].size == 1
          @values[9*a+b].value = @sudoku[a][b][0]
        else
          @values[9*a+b].value = ""
        end
      }
    }
  end
  
  def update_sudoku
    9.times { |a|
      @sudoku[a] = Array.new
      9.times { |b|
        if @values[9*a+b].value != "" then
          @sudoku[a][b] = [@values[9*a+b].value.to_i]
        else
          @sudoku[a][b] = [1,2,3,4,5,6,7,8,9]
        end
      }
    }
  end

  def save_sudoku filename
    begin
      file = File.new filename, "w"
      @values.each_index { |i|
        if @values[i].value != "" then
          file.write @values[i].value
        else
          file.write "0"
        end
        file.write "\n" if i % 9 == 8
      }
      file.close
      true
    rescue
      false
    end
  end


  private

  def entries_any_key_event event, coord
  if event.char >= "1" and event.char <= "9" then
    @buttons[coord+1].focus
    @buttons[coord+1].cursor = 1
    if @values[coord].value.size > 0 then
    @values[coord].value = @values[coord].value[-1].chr
    end
  elsif event.char.downcase != "" and event.char != "\t" then
    @buttons[coord].value = ""
  else
    movecursor event.keysym, coord  #event a souradnice
  end
  #p event.mode
  end

  def movecursor keysym, coord
  case keysym
    when "Left"
    @buttons[coord-1].focus
    @buttons[coord-1].cursor = 1
    when "Right"
      coord -= 81 if coord+1 > 80
    @buttons[coord+1].focus
    @buttons[coord+1].cursor = 1
    when "Down"
      coord -= 81 if coord+9 > 80
    @buttons[coord+9].focus
    @buttons[coord+9].cursor = 1
    when "Up"
    @buttons[coord-9].focus
    @buttons[coord-9].cursor = 1
  end
  end
  
  def lockscreen
    @buttons.each_index { |i|
      if @buttons[i].value.size == 1 then
        # @buttons[i].configure 'state' => 'disabled'
        @buttons[i].configure "foreground" => "#000" 
      end
    }
  end
  
  def unlockscreen
    @buttons.each_index { |i|   
      # @buttons[i].configure 'state' => 'normal'
      @buttons[i].configure "foreground" => "#f00" 
    }
  end

end


sudoku = TkSudoku.new

#p Tk.bindinfo_all
#p TkSudoku.methods

Tk.mainloop



# puvodni button bind:
=begin
          @buttons[-1].bind("Any-KeyRelease") {
            if @values[9*a+3*f+g].value.size > 1 then
              @values[9*a+3*f+g].value = @values[9*a+3*f+g].value[-1].chr
            end
            if @values[9*a+3*f+g].value < "1" || @values[9*a+3*f+g].value > "9" then
              @values[9*a+3*f+g].value = ""
              #@buttons[9*a+3*f+g].configure 'state' => 'disabled'
            end
            if 9*a+3*f+g+1 < 81 and @values[9*a+3*f+g].value != "" then
              @buttons[9*a+3*f+g+1].focus
            end
          }
=end
