module Minke
  module Helpers
    class Rake
      ##
      # invoke a rake task
      def invoke_task task
        Rake::Task[task].invoke
      end
    end
  end
end