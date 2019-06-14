# A simple abstracted background job wrapper.
# Pass an object plus a symbolized method name to run asynchronously:

# AbstractJob.perform_later(@vote, :sync_to_actionkit)

class AbstractJob < ApplicationJob
  queue_as :default

  def perform(object, method)
    object.try(method)
  end
end
