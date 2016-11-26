require "slather"

module Danger
  # Show code coverage of the project and by file. Add warnings or fail the Build
  # if a minimum coverage are not achieved.
  # It uses Slather Framework for calculate coverage, so it's required to configurate
  # the slather object before using it.
  #
  # @example Require a minimum file coverage of 30%, a project coverage of 60% and show all modified files coverage
  #       slather.configure(xcodeproj_path: "Path/to/my/project.xcodeproj", scheme: "MyScheme")
  #       slather.notify_if_coverage_is_less_than(minimum_coverage: 60)
  #       slather.notify_if_modified_file_is_less_than(minimum_coverage: 30)
  #       slather.show_coverage
  #
  #
  # @see  Bruno Mazzo/danger-slather
  # @tags slather, code coverage
  #
  class DangerSlather < Plugin

    # Total coverage of the project
    #
    # @return   [Float]
    #
    def total_coverage
      if @project != nil
        @total_coverage ||= begin

          total_project_lines = 0
          total_project_lines_tested = 0
          @project.coverage_files.each do |coverage_file|
            lines_tested = coverage_file.num_lines_tested
            total_lines = coverage_file.num_lines_testable

            total_project_lines_tested += lines_tested
            total_project_lines += total_lines
          end
          @total_coverage = (total_project_lines_tested / total_project_lines.to_f) * 100.0
        end
      end
    end

    # Required method to configure slather. It's required at least the path
    # to the project and the scheme used with code coverage enabled
    #
    # @return  [void]
    #
    def configure(xcodeproj_path:,
        scheme:,
        workspace: nil,
        build_directory: nil,
        ignore_list: nil,
        ci_service: nil,
        coverage_access_token: nil,
        coverage_service: :terminal,
        source_directory: nil,
        output_directory: nil,
        input_format: nil,
        binary_file: nil,
        decimals: nil,
        post: true)
      @project = Slather::Project.open(xcodeproj_path)
      @project.scheme = scheme
      @project.workspace = workspace
      @project.build_directory = build_directory
      @project.ignore_list = ignore_list
      @project.ci_service = ci_service
      @project.coverage_access_token = coverage_access_token
      @project.coverage_service = coverage_service
      @project.source_directory = source_directory
      @project.output_directory = output_directory
      @project.input_format = input_format
      @project.binary_file = binary_file
      @project.decimals = decimals
      @project.configure
      @project.post if post
    end

    # Method to check if the coverage of the project is at least a minumum
    #
    # @param notify_level [Symbol] the level of notification
    # @param minimum_coverage [Float] the minimum code coverage required
    # @return [Array<String>]
    #
    def notify_if_coverage_is_less_than(notify_level: :fail, minimum_coverage:)
      if total_coverage < minimum_coverage
        notify_message = "Total coverage less than #{minimum_coverage} code coverage"
        if notify_level == :fail
          fail notify_message
        else
          warn notify_message
        end
      end
    end

    # Method to check if the coverage of modified files is at least a minumum
    #
    # @param notify_level [Symbol] the level of notification
    # @param minimum_coverage [Float] the minimum code coverage required for a file
    # @return [Array<String>]
    #
    def notify_if_modified_file_is_less_than(notify_level: :fail, minimum_coverage:)
        modified_files_coverage = @project.coverage_files.select { |file|
          git.modified_files.include? file.source_file_pathname_relative_to_repo_root.to_s
        }

        if modified_files_coverage.count > 0
          modified_files_coverage.each{ |file|
            if file.percentage_lines_tested < minimum_coverage
              notify_message = "#{file.source_file_pathname_relative_to_repo_root.to_s} has less than #{minimum_coverage} code coverage"
              if notify_level == :fail
                fail notify_message
              else
                warn notify_message
              end
            end
          }
        end
    end

    # Show a header with the total coverage of the project
    #
    # @return [Array<String>]
    def show_total_coverage
      if @project != nil
        markdown "# Coverage #{@project.decimal_f([total_coverage])}%"
      end
    end


    # Build a coverage markdown table of the modified files coverage
    #
    # @return [String]
    def modified_files_coverage_table
      if @project != nil
        line = "File | Coverage\n"
        line << "-----|-----\n"
        @project.coverage_files.each do |coverage_file|
          file_name = coverage_file.source_file_pathname_relative_to_repo_root.to_s
          percentage = @project.decimal_f([coverage_file.percentage_lines_tested])
          line << "#{file_name} | #{percentage} \n"
        end

        return line
      end
    end

    # Show the table build by modified_files_coverage_table
    #
    # @return [Array<String>]
    def show_modified_files_coverage
      if @project != nil
        markdown modified_files_coverage_table
      end
    end

    # Show a header with the total coverage and coverage table
    #
    # @return [Array<String>]
    def show_coverage
      if @project != nil
        line = "## Code coverage\n"
        line << "Total coverage: #{total_coverage}\n\n"
        line << modified_files_coverage_table
        line << "> Powered by [Slather](https://github.com/SlatherOrg/slather)"
        markdown line
      end
    end

  end
end
