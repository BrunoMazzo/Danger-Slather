require File.expand_path('../spec_helper', __FILE__)

require "slather"

module Danger

  describe Danger::DangerSlather do
    def mock_file(name:, coverage:)
      mock("File #{name}") do
        stubs(:source_file_pathname_relative_to_repo_root).returns(name)
        stubs(:num_lines_tested).returns(coverage)
        stubs(:num_lines_testable).returns(100)
        stubs(:percentage_lines_tested).returns(coverage)
      end
    end

    it 'should be a plugin' do
      expect(Danger::DangerSlather.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.slather

        @project_mock = project_mock = Slather::Project.new("")
        @project_mock.stubs(:configure)
        @project_mock.stubs(:post)
        Slather::Project.stubs(:open).returns(@project_mock)
        @my_plugin.configure(xcodeproj_path: "iOS Project/Danger-Slather/Danger-Slather.xcodeproj", scheme: "Danger-Slather")
      end

      describe 'notify_if_modified_file_is_less_than' do
        it "Should only fails on modified files" do
          @dangerfile.git.stubs(:modified_files).returns(["AppDelegate.swift"])

          @project_mock.stubs(:coverage_files).returns([
            mock_file(name: "AppDelegate.swift", coverage: 10),
            mock_file(name: "ViewController2.swift", coverage: 20),
            mock_file(name: "ViewController.swift", coverage: 80)
          ])

          @my_plugin.notify_if_modified_file_is_less_than(minimum_coverage: 50)

          expect(@dangerfile.status_report[:errors]).to eq(["AppDelegate.swift has less than 50% code coverage"])
        end

        it "Should not fail if coverage is higher than parameter" do
          @dangerfile.git.stubs(:modified_files).returns(["AppDelegate.swift"])

          @project_mock.stubs(:coverage_files).returns([
            mock_file(name: "AppDelegate.swift", coverage: 80)
          ])

          @my_plugin.notify_if_modified_file_is_less_than(minimum_coverage: 50)

          expect(@dangerfile.status_report[:errors]).to eq([])
        end

        it "Should add warning if notify_level is warning" do
          @dangerfile.git.stubs(:modified_files).returns(["AppDelegate.swift"])

          @project_mock.stubs(:coverage_files).returns([
              mock_file(name: "AppDelegate.swift", coverage: 10)
          ])

          @my_plugin.notify_if_modified_file_is_less_than(minimum_coverage: 50, notify_level: :warning)

          expect(@dangerfile.status_report[:errors]).to eq([])
          expect(@dangerfile.status_report[:warnings]).to eq(["AppDelegate.swift has less than 50% code coverage"])
        end
      end

      describe 'notify_if_coverage_is_less_than' do
        it "Should fails if total coverage is less than minimum" do

          @project_mock.stubs(:coverage_files).returns([
            mock_file(name: "AppDelegate.swift", coverage: 10),
            mock_file(name: "ViewController2.swift", coverage: 20),
            mock_file(name: "ViewController.swift", coverage: 20)
          ])

          @my_plugin.notify_if_coverage_is_less_than(minimum_coverage: 50)

          expect(@dangerfile.status_report[:errors]).to eq(["Total coverage less than 50%"])
        end

        it "Should not fails if total coverage is greather than minimum" do

          @project_mock.stubs(:coverage_files).returns([
            mock_file(name: "AppDelegate.swift", coverage: 50),
            mock_file(name: "ViewController2.swift", coverage: 80),
            mock_file(name: "ViewController.swift", coverage: 80)
          ])

          @my_plugin.notify_if_coverage_is_less_than(minimum_coverage: 50)

          expect(@dangerfile.status_report[:errors]).to eq([])
        end

        it "Should not fails if total coverage is greather than minimum and has files with less than total minimum" do

          @project_mock.stubs(:coverage_files).returns([
            mock_file(name: "AppDelegate.swift", coverage: 20),
            mock_file(name: "ViewController2.swift", coverage: 80),
            mock_file(name: "ViewController.swift", coverage: 80)
          ])

          @my_plugin.notify_if_coverage_is_less_than(minimum_coverage: 50)

          expect(@dangerfile.status_report[:errors]).to eq([])
        end

        it "Should add warning if notify_level is warning" do
          @project_mock.stubs(:coverage_files).returns([
              mock_file(name: "AppDelegate.swift", coverage: 10)
          ])

          @my_plugin.notify_if_coverage_is_less_than(minimum_coverage: 50, notify_level: :warning)

          expect(@dangerfile.status_report[:errors]).to eq([])
          expect(@dangerfile.status_report[:warnings]).to eq(["Total coverage less than 50%"])
        end
      end

      describe 'show_coverage' do
        it "Should add warning if notify_level is warning" do
          @dangerfile.git.stubs(:modified_files).returns(["AppDelegate.swift",
                                                          "ViewController.swift",
                                                          "ViewController2.swift",
                                                          "ViewController3.swift",
                                                          "ViewController4.swift"])

          @project_mock.stubs(:coverage_files).returns([
              mock_file(name: "AppDelegate.swift", coverage: 10),
              mock_file(name: "ViewController.swift", coverage: 20),
              mock_file(name: "ViewController2.swift", coverage: 30),
              mock_file(name: "ViewController3.swift", coverage: 40),
              mock_file(name: "ViewController4.swift", coverage: 50),
              mock_file(name: "ViewController5.swift", coverage: 60)
          ])

          @my_plugin.show_coverage

          expect(@dangerfile.status_report[:markdowns][0].message).to eq("## Code coverage\nTotal coverage: 35.0\n\nFile | Coverage\n-----|-----\nAppDelegate.swift | 10.00 \nViewController.swift | 20.00 \nViewController2.swift | 30.00 \nViewController3.swift | 40.00 \nViewController4.swift | 50.00 \nViewController5.swift | 60.00 \n> Powered by [Slather](https://github.com/SlatherOrg/slather)")
        end
      end

    end
  end
end
