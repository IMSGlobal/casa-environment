require 'fileutils'
require 'systemu'

module CASA
  module Bootstrap
    class Environment

      attr_reader :config

      def initialize config

        @config = config
        @packages = nil

      end

      def exists?

        Dir.exists? config.path

      end

      def make_workspace_directory!

        unless exists?
          FileUtils.mkdir_p config.path
          true
        else
          false
        end

      end

      def setup_repositories!

        packages.each do |name, package|
          package.setup_git_repository! unless package.exists?
        end

      end

      def packages

        unless @packages
          @packages = {}
          config.packages.each do |package_name, package_config|
            package_path = config.path + package_name
            @packages[package_name] = Package.new package_name, package_path, package_config, self
          end
        end
        @packages

      end

      def exec name, command

        status, stdout, stderr = exec_result name, command
        status.success?

      end

      def exec_result name, command

        systemu "#{config.exec.send name.to_sym} #{command}"

      end

    end
  end
end