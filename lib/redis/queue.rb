class Redis
  class Queue
    VERSION = "0.0.1"
    def initialize(queue_name, process_queue_name, options = {})
      raise ArgumentError, 'First argument must be a non emmpty string'  if !queue_name.is_a?(String) || queue_name.empty?
      raise ArgumentError, 'Second argument must be a non emmpty string' if !process_queue_name.is_a?(String) || process_queue_name.empty?
      raise ArgumentError, 'Queue and Process queue have the same name'  if process_queue_name == queue_name 

      @redis = options[:redis] || Redis.current
      @queue_name = queue_name
      @process_queue_name = process_queue_name
      @last_message = nil
    end

    def length
      @redis.llen @queue_name
    end

    def clear(clear_process_queue = false)
      @redis.del @queue_name
      @redis.del @process_queue_name if clear_process_queue
    end

    def empty?
      !(length > 0)
    end

    def push(obj)
      @redis.lpush(@queue_name, obj)
    end

    def pop(non_block=false)
      if non_block
        @last_message = @redis.rpoplpush(@queue_name,@process_queue_name)
      else
        @last_message = @redis.brpoplpush(@queue_name,@process_queue_name)
      end
      @last_message
    end

    def commit
      @redis.lrem(@process_queue_name, 0, @last_message)
    end

    alias :size  :length
    alias :dec   :pop
    alias :shift :pop
    alias :enc   :push
    alias :<<    :push
  end
end