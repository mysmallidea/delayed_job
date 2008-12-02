
module Delayed
  class Status
    
    
    class << self
      def get(id)
        Delayed::Job.find(id).status
      rescue ActiveRecord::RecordNotFound 
        "finished"
      end

      def update(id, status)
        job = Delayed::Job.find(id)
        job.update_attribute(:status, status)
      rescue ActiveRecord::RecordNotFound 
        false
      end
      
    end
    
  end
end