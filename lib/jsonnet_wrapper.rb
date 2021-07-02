# frozen_string_literal: true
require 'shellwords'
require 'open3'
require 'English'

class JsonnetWrapper
  REPO_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze

  JSONNET_EXECUTABLE = 'jsonnet'

  DEFAULT_LIBS = %w[libsonnet vendor dashboards services metrics-catalog].map { |dir| File.join(REPO_DIR, dir) }.freeze

  def initialize(libs: DEFAULT_LIBS, executable_name: JSONNET_EXECUTABLE)
    @libs = libs
    @executable = find_jsonnet_executable(executable_name)
  end

  def evaluate(file)
    command_for_file = build_command << file

    result = run(command_for_file)
    raise "Failed to compile #{file}\n#{result}" unless $CHILD_STATUS.success?

    result
  end

  def parse(file)
    JSON.parse(evaluate(file))
  end

  private

  attr_reader :executable, :libs

  def build_command
    [
      executable,
      *libs.map { |dir| ["-J", dir] }.flatten,
      "--ext-str",
      "dashboardPath=#{File.join(REPO_DIR, 'dashboards')}"
    ]
  end

  def find_jsonnet_executable(name)
    executable = run(['which', name]).strip

    raise "jsonnet not found" if !$CHILD_STATUS.success? || executable.empty?

    executable
  end

  def run(command)
    IO.popen(Shellwords.join(command), err: [:child, :out], &:read)
  end
end
