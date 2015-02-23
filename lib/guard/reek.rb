require 'guard'

module Guard
  # Guard::Reek class, it implements an guard for reek task
  class Reek < Plugin
    SUCCESS = ["Reek passed", { title: "Reek passed", image: :success }]
    FAILED = ["Reek failed", { title: "Reek failed", image: :failed }]

    attr_reader :last_result, :options

    def initialize(options = {})
      super
      @options = { run_all: true }.merge options
      @files = Dir["**/*"]
      watchers = options[:watchers] || []
      @files.select! do |file|
        watchers.reduce(false) { |res, watcher| res || watcher.match(file) }
      end
    end

    def start
      UI.info('Guard::Reek is starting')
      run_all
    end

    def run_all
      if @options[:run_all]
        UI.info('Guard::Reek is running on all files')
        self.class.reek @files
      else
        UI.info('Guard::Reek is not allowed to run on all files')
      end
    end

    def run_on_modifications path
      UI.info("Guard::Reek is running on #{path.to_s}")
      self.class.reek path
    end

    def self.reek(paths)
      result = system command(paths)

      result ? Notifier.notify(*SUCCESS) : Notifier.notify(*FAILED)
      @last_result = result
      result
    end

    def self.command paths
      "reek -n #{paths.uniq.join(' ')}"
    end
  end
end
