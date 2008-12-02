
module Delayed
  class Status
    
    
    class << self
      def get(id)
        Delayed::Job.find(id, :select => "id, status, failed_at").status
      rescue ActiveRecord::RecordNotFound 
        "finished"
      end

      def update(id, status)
        Delayed::Job.update(id, {:status => status})
      rescue ActiveRecord::RecordNotFound 
        false
      end
      
    end
    
  end
end