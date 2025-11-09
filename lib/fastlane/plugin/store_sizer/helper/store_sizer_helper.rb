module Fastlane
  module Helper
    class StoreSizerHelper
      def self.write_random_segments(file_path, segments)
        File.open(file_path, "rb+") do |file|
          segments.each do |segment|
            file.pos = segment[0]
            file.puts(SecureRandom.random_bytes(segment[1]))
          end
        end
      end

      def self.write_random_file(path, size)
        IO.binwrite(path, SecureRandom.random_bytes(size))
      end

      def self.xcode_export_package(archive_path, export_options_plist_path, export_path)
        command = "xcodebuild"
        command << " -exportArchive"
        command << " -exportOptionsPlist #{export_options_plist_path}"
        command << " -archivePath #{archive_path}"
        command << " -exportPath #{export_path}"
        # Run xcodebuild without Bundler's environment to avoid interfering with Xcode's Ruby tools (e.g. ipatool)
        executor = proc do
          FastlaneCore::CommandExecutor.execute(command: command, print_command: false, print_all: false)
        end
        if defined?(Bundler)
          if Bundler.respond_to?(:with_unbundled_env)
            Bundler.with_unbundled_env(&executor)
          elsif Bundler.respond_to?(:with_clean_env)
            Bundler.with_clean_env(&executor)
          else
            executor.call
          end
        else
          executor.call
        end
      end
    end
  end
end
