#
# Copyright:: Copyright (c) Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "fileutils"

name "more-ruby-cleanup"

skip_transitive_dependency_licensing true
license :project_license

source path: "#{project.files_path}/#{name}"

build do
  block "Removing additional non-code files from installed gems" do
    # find the embedded ruby gems dir and clean it up for globbing
    target_dir = "#{install_dir}/embedded/lib/ruby/gems/*/gems".tr('\\', "/")
    files = %w{
      *.blurb
      *Upgrade.md
      autotest
      autotest/*
      bench
      benchmark
      benchmarks
      design_rationale.rb
      doc
      doc-api
      docs
      ed25519.png
      example
      examples
      ext
      features
      frozen_old_spec
      Gemfile.devtools
      Gemfile.lock
      INSTALL.txt
      man
      minitest
      on_what.rb
      rakelib
      sample
      samples
      site
      test
      tests
      vendor
      VERSION
      website
      yard-template
    }

    Dir.glob(Dir.glob("#{target_dir}/*/{#{files.join(",")}}")).each do |f|
      # chef stores the powershell dlls in the ext dir
      next if File.basename(File.expand_path("..", f)).start_with?("chef-")

      puts "Deleting #{f}"
      FileUtils.rm_rf(f)
    end
  end

  block "Removing Gemspec / Rakefile / Gemfile unless there's a bin dir / not a chef gem" do
    # find the embedded ruby gems dir and clean it up for globbing
    target_dir = "#{install_dir}/embedded/lib/ruby/gems/*/gems".tr('\\', "/")
    files = %w{
      *.gemspec
      Gemfile
      Rakefile
      tasks
    }

    Dir.glob(Dir.glob("#{target_dir}/*/{#{files.join(",")}}")).each do |f|
      # don't delete these files if there's a bin dir in the same dir or we're in a chef owned gem
      next if Dir.exist?(File.join(File.dirname(f), "bin")) || File.basename(File.expand_path("..", f)).start_with?("chef-")

      puts "Deleting #{f}"
      FileUtils.rm_rf(f)
    end
  end

  block "Removing spec dirs from non-Chef gems" do
    Dir.glob(Dir.glob("#{install_dir}/embedded/lib/ruby/gems/*/gems/*/spec".tr('\\', "/"))).each do |f|
      # if we're in a chef- gem then don't remove the specs
      next if File.basename(File.expand_path("..", f)).start_with?("chef-")

      puts "Deleting #{f}"
      FileUtils.rm_rf(f)
    end
  end
end
