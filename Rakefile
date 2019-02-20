require 'yaml'
require 'tempfile'
require 'html-proofer'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:'check:rspec') do |t|
  t.rspec_opts = "--pattern '_spec/**{,/*/**}/*_spec.rb'"
end

task default: :serve

root_dir = File.expand_path(File.dirname(__FILE__))
site_dir = File.join(root_dir, '_site')

namespace :serve do
  desc 'Serve Jekyll'
  task :dev do
    system('JEKYLL_ENV=development bundle exec jekyll serve -H 0.0.0.0', out: $stdout, err: $stderr) || exit(1)
  end

  desc 'Serve Jekyll - Production'
  task :prod do
    system('JEKYLL_ENV=production bundle exec jekyll serve -H 0.0.0.0', out: $stdout, err: $stderr) || exit(1)
  end
end

task serve: :'serve:dev'
task s:     :serve

namespace :build do
  desc 'Build Jekyll'
  task :dev do
    system('JEKYLL_ENV=development bundle exec jekyll build', out: $stdout, err: $stderr) || exit(1)
  end

  desc 'Build Jekyll - Production'
  task :prod do
    system('JEKYLL_ENV=production bundle exec jekyll build', out: $stdout, err: $stderr) || exit(1)
  end
end

task build: :'build:dev'
task b:     :build

namespace :check do
  class SpellingError < Exception; end
  desc 'Check spelling in compiled HTML files'
  task :spelling do
    puts 'Checking spelling...'

    files = Dir.glob("#{site_dir}/**/*.html")
    content = ''
    files.each do |file|
      content += File.read(file)
    end

    # FIXME this is ugly and prone to breaking
    if `aspell -v` !~ /0\.60\.7/
      content.gsub!('’',"'")
    end

    tfile = Tempfile.new('aspell')
    tfile.write(content)

    words = `cat #{tfile.path} | aspell list -d en_US --encoding utf-8 --ignore-case --extra-dicts #{root_dir}/custom.en.pws -H | sort | uniq -c | sort -r`

    tfile.close
    tfile.unlink

    retval = $?.to_i
    raise "Spellcheck failed: #{words}" if retval > 0

    wordcount = words.split("\n").length
    if wordcount > 0
      raise SpellingError, "#{wordcount} misspelled words\n#{words}"
    end
    puts "Hooray! No misspelled words."
  end

  desc 'New Spelling Check'
  task :spelling_new do
    files = Dir.glob("#{root_dir}/**/*.{html,md}")
    files.each do |file|
      Psych.parse_stream(file).select{ |doc| doc.is_a?(String) }
      IO.read_line(file).each_with_index do |i, line|
        line.split
      end
    end

  end

  desc 'Validate compiled HTML'
  task :html do
    opts = {
      allow_hash_href: true,
      assume_extension: true,
      cache: {
        timeframe: '30d'
      },
      check_external_hash: false,
      disable_external: true,
      check_favicon: true,
      check_html: true,
      check_opengraph: true,
      empty_alt_ignore: true,
      enforce_https: true,
      http_status_ignore: [ 999 ],
      internal_domains: %w{ jescholl.com },
      typhoeus: {
        ssl_verifypeer: false
      },
      url_ignore: [ /www\.stockpickssystem\.com/ ],
      validation: {
        report_missing_names: true
      },
      verbose: true,
    }
    HTMLProofer.check_directory('./_site', opts).run
  end
end

namespace :deploy do
  desc 'Deploy to github'
  task :github do
    system("_scripts/deploy.sh", out: $stdout, err: $stderr) || exit(1)
  end
end

task deploy: :'deploy:github'
