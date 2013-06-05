require 'guard'
require 'guard/guard'

module Guard
  # Guard::Reek class, it implements an guard for reek task
  class Reek < Guard
    SUCCESS = ["Passed", { title: "Passed", image: :success }]
    FAILED = ["Failed", { title: "Failed", image: :failed }]

    attr_reader :last_result, :options

    def initialize(watchers = [], options = {})
      super
      @options = options
      @files = Dir["**/*"]
      @files.select! do |file|
        watchers.reduce(false) { |res, watcher| res || watcher.match(file) }
      end
    end

    def start
      UI.info "Guard::Reek is running"
      run_all
    end

    def run_all
      self.class.reek @files
    end

    def run_on_changes path
      self.class.reek path
    end

    def self.reek(paths)
      result = system command(paths)

      notify(result)
      @last_result = result
      result
    end

    def self.command paths
      "reek -n #{paths.uniq.join(' ')}"
    end

    def self.notify result
      if result
        Notifier.notify(*SUCCESS)
      else
        Notifier.notify(*FAILED)
      end
    end
  end
end