# Danger-slather

A [Danger](http://danger.systems/) plugin that show code coverage of a Xcode project and file by file using [Slather](https://github.com/SlatherOrg/slather). Add warnings or fail the build if a minimum coverage are not achieved. It uses Slather Framework for calculate coverage, so it's required to configure the slather object before using it.

## How does it look?
<table>
  <thead>
    <tr>
      <th width="50"></th>
      <th width="100%">
          1 Error
      </th>
     </tr>
  </thead>
  <tbody>
    <tr>
      <td><g-emoji alias="no_entry_sign" fallback-src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f6ab.png">🚫</g-emoji></td>
      <td>
Total coverage less than 80%
</td>
    </tr>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th width="50"></th>
      <th width="100%">
          1 Warnings
      </th>
     </tr>
  </thead>
  <tbody>
    <tr>
      <td><g-emoji alias="warning" fallback-src="https://assets-cdn.github.com/images/icons/emoji/unicode/26a0.png">⚠️</g-emoji></td>
      <td>AppDelegate.swift has less than 50% code coverage
</td>
    </tr>
  </tbody>
</table>

## Code coverage
Total coverage: 35.0

File | Coverage
-----|-----
AppDelegate.swift | 10.00
ViewController.swift | 20.00
ViewController2.swift | 30.00
ViewController3.swift | 40.00
ViewController4.swift | 50.00
ViewController5.swift | 60.00
> Powered by [Slather](https://github.com/SlatherOrg/slather)

## Installation

    $ gem install danger-slather

## Usage

First configure the slather object:

    slather.configure("Path/to/my/project.xcodeproj", "MyScheme")

For a more complex case:

    slather.configure("Path/to/my/project.xcodeproj", "MyScheme", options: {
      workspace: 'Path/to/my/workspace.xcworkspace',
      build_directory: 'Path/to/my/build_directory',
      ignore_list: ['ignore file 1', 'ignore file 2'],
      ci_service: :travis,
      coverage_access_token: 'acc123123123123',
      coverage_service: :terminal,
      source_directory: 'Path/to/my/source_directory',
      output_directory: 'Path/to/my/output_directory',
      input_format: 'profdata',
      binary_file: 'Path/to/my/output_directory',
      decimals: 2
      post: false      
    })

For a more complete documentation of all support configuration see [Slather](https://github.com/SlatherOrg/slather)

Than just add this line to your `Dangerfile`:

    slather.notify_if_coverage_is_less_than(minimum_coverage: 80)
    slather.notify_if_modified_file_is_less_than(minimum_coverage: 60)
    slather.show_coverage

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
