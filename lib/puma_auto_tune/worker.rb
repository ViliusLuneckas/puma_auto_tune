module PumaAutoTune
  class Worker

    def initialize(worker)
      @worker     = worker
      @restarting = false
    end

    def memory
      @memory || get_memory
    end
    alias :mb :memory

    def get_memory
      return 0 if restarting?

      @memory = ::GetProcessMem.new(self.pid).mb
    end

    def restarting?
      @restarting
    end

    def restart
      @restarting = true
      @worker.term
    end

    def pid
      @worker.pid
    end
  end
end
