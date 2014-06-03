
class Timer
  attr_reader :hours
  attr_reader :minutes
  attr_reader :seconds
  attr_reader :state

  def initialize
    @hours = 0
    @minutes = 0
    @seconds = 0
    @last_time = Gosu::milliseconds()
    @state = :running
  end

  def stop
    @state = :lost
  end

  def update_time
    if @state == :running
      if (Gosu::milliseconds - @last_time) / 1000 == 1
        @seconds += 1
        @last_time = Gosu::milliseconds()
      end
      if @seconds > 59
        @seconds = 0
        @minutes += 1
      end
      if @minutes > 59
        @hours += 1
        @minutes = 0
      end
    end

    if @seconds < 10
     time = "Time: "  "0"+@minutes.to_s + ":" + "0" + @seconds.to_s
    else
      time = "Time: "  "0"+@minutes.to_s + ":" + @seconds.to_s
    end

  end

end
