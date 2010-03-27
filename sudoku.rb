#!/usr/bin/ruby

require 'tk'

def relativepath
  c = $0.split "/"
  c.pop 
  c = c.join "/"
  if not c.empty? then c + "/" else c end
end

RELATIVE_PATH = relativepath

require "#{RELATIVE_PATH}sudoku_core.rb"


class TkSudoku < Sudoku_core

  Colors=["#daeaea", "#f8e7cd"] * 2
  LColors=["#eafafa", "#fff7dd"] * 2
  DialogParams = { "defaultextension" => ".sudoku", "filetypes" => [["Sudoku", [".sudoku"]], ["All files", ["*.*"]]] }

  def initialize
    init_variables

    init_application
  end

private

  def init_application
    solve = proc { init_variables; update_sudoku; color_red; solve_sudoku; print; update_window }
    new   = proc { clear_all; color_black }
    open = proc {
      filename = Tk.getOpenFile( DialogParams.update("title"=>"Open Sudoku", "initialdir"=>"#{RELATIVE_PATH}examples"))
      if filename == "" then
        ;
      elsif open_sudoku filename then
        color_black; update_window;
      else
        msgBox = Tk.messageBox('type'=>"ok", 'icon'=>"error", 'title'=>"Error",
          'message'=>"Selected file is not in valid format" )
      end
    }
    save = proc { save_sudoku Tk.getSaveFile( DialogParams.update("title"=>"Save Sudoku") ) }

    prin = proc { begin; print; rescue; end } #toDEL
    prin_ver = proc { begin; print_verbose; rescue; end } #toDEL

    @root = TkRoot.new() { title "SUDOKU"; resizable  false, false;  geometry '306x296' }
      # ; iconbitmap "sudoku.ico" } # +-position_x+-position_y

    bar = TkMenu.new()
    sys = TkMenu.new(bar) { tearoff false }
    sys.add 'command', 'label'=>"New",  'underline'=>0, 'command' => new
    sys.add 'command', 'label'=>"Open", 'underline'=>0, 'command' => open
    sys.add 'command', 'label'=>"Save", 'underline'=>0, 'command' => save
    sys.add 'separator'
    sys.add 'command', 'label'=>"Quit", 'underline'=>0, 'command' => proc { @root.destroy }
    
    bar.add 'cascade', 'menu' => sys, 'label'=>"Menu", 'underline'=> 0
    bar.add 'command', 'label'=>"Solve", 'underline'=>0, 'command' => solve
    bar.add 'command', 'label'=>"Print", 'underline'=>0, 'command' => prin #toDEL
    bar.add 'command', 'label'=>"Print!", 'underline'=>0, 'command' => prin_ver
    @root.menu bar

    @buttons = Array.new
    @values = Array.new

    9.times { |a|
      line = TkFrame.new
      3.times { |f|
        cell = TkFrame.new(line){ background Colors[(f%2)+(a/3)] } . pack "side"=>"left"
        3.times { |g|
          @values << TkVariable.new
          @buttons << TkEntry.new(cell, 'textvariable' => @values[-1]) { width 2; justify "center";
            readonlybackground LColors[(f%2)+(a/3)]; state "readonly"; borderwidth 1;
            highlightthickness 1; highlightbackground LColors[(f%2)+(a/3)]
          }
          @buttons[-1].pack "side" => "left", "pady" => 4, "padx" => 4
          @buttons[-1].font('9x15')
        }
      }
      line.pack 
    }

    @buttons.each_index { |i|
      @buttons[i].bind("Any-KeyRelease") { |event|
        entries_any_key_event event, i
      }
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


  def entries_any_key_event event, coord
    if event.char >= "1" and event.char <= "9" then
      @buttons[coord].configure "foreground" => "#000"
      @values[coord].value = event.char
      @buttons[(coord+1)% 81].focus
    elsif event.char == " " then
      @buttons[(coord+1)% 81].focus
    elsif event.keysym == "BackSpace" or event.keysym == "Delete" then
      @values[coord].value = ""
    else
      movecursor event.keysym, coord
    end
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
  
  def color_red
    @buttons.each_index { |i|
      if @buttons[i].value.size != 1 then
        # @buttons[i].configure 'state' => 'disabled'
        @buttons[i].configure "foreground" => "#f00" 
      end
    }
  end
  
  def color_black
    @buttons.each_index { |i|   
      # @buttons[i].configure 'state' => 'normal'
      @buttons[i].configure "foreground" => "#000" 
    }
  end

end


sudoku = TkSudoku.new

Tk.mainloop
