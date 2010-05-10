class RemoteRequest < ActiveRecord::Base
  belongs_to :requestable, :polymorphic => :true
  belongs_to :remote_host
end
