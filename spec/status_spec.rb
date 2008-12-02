require File.dirname(__FILE__) + '/database'

class SimpleJob
  cattr_accessor :runs; self.runs = 0
  def perform; @@runs += 1; end
end

class ComplexJob < Struct.new(:text, :job_id)
  cattr_accessor :runs; self.runs = 0
  def perform
    @@runs += 1
    Delayed::Status.update(job_id, "foobar")
    
    fail
  end    
end

describe Delayed::Job do
  before  do               
    Delayed::Job.max_priority = nil
    Delayed::Job.min_priority = nil      
    
    Delayed::Job.delete_all
  end
  
  before(:each) do
    SimpleJob.runs = 0
  end
  
  context "get" do
    it "should get the 'status' of a job" do
      @job = Delayed::Job.enqueue SimpleJob.new
      Delayed::Status.get(@job.id).should == "pending"
    end
    
    it "should return 'finished' if a job is not found" do
      Delayed::Status.get(2).should == "finished"
    end
    
    it "should return 'failed' if a job is failed" do
      @job = Delayed::Job.create :payload_object => SimpleJob.new, :attempts => 50, :failed_at => Time.now
      Delayed::Status.get(@job.id).should == "failed"
    end
  end
  
  context "update" do
    it "should update the job's status" do
      @job = Delayed::Job.enqueue SimpleJob.new
      Delayed::Status.update(@job.id, "almost done")
      Delayed::Status.get(@job.id).should == "almost done"
    end
    
    it "should be able to update its own status" do
      @job = Delayed::Job.enqueue ComplexJob.new
      Delayed::Job.work_off
      
      Delayed::Status.get(@job.id).should == "foobar"
    end
  end
  
end