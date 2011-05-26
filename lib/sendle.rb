require 'digest/sha1'
require 'yaml'
require 'gmail'

class Sendle
  attr_reader :last_event, :sha1_checksums_hash, :listener

  def initialize(password)
    @password = password
    @sha1_checksums_hash = {}
    @last_event = Time.now

    configure_listener
  end

  def send_to_kindle(file)
    @config ||= YAML::load(File.open("#{ENV['HOME']}/.sendle"))
    gmail       = Gmail.connect(@config["gmail"]["username"], @password)
    message     = gmail.message
    message.to  = @config["kindle"]["email"]
    message.add_file file
    message.deliver
    puts "an email with #{file} is flying on the interwebz!"
  end

  def file_added(file)
    puts "file changed: #{file}, sending now..."
    send_to_kindle(file[0]) unless file.nil? || file.empty?
  end

  private # shameless copied from: https://github.com/guard/guard/blob/master/lib/guard/listener.rb#L35-63.

  def configure_listener
    @listener = FSEvent.new
    @listener.watch Dir.pwd do |directories|
      @last_event = Time.now
      file_added(modified_files(directories))
    end
    @listener.run
  end

  def modified_files(dirs, options = {})
    files = potentially_modified_files(dirs, options).select do |path|
      File.file?(path) && file_modified?(path) && file_content_modified?(path) 
    end
    files.map! { |file| file.gsub("#{Dir.pwd}/", '') }
  end

  def potentially_modified_files(dirs, options = {})
    match = options[:all] ? "**/*" : "*"
    Dir.glob(dirs.map { |dir| "#{dir}#{match}" })
  end

  def file_modified?(path)
    # Depending on the filesystem, mtime is probably only precise to the second, so round
    # both values down to the second for the comparison.
    File.mtime(path).to_i >= last_event.to_i
  rescue
    false
  end

  def file_content_modified?(path)
    sha1_checksum = Digest::SHA1.file(path).to_s
    if sha1_checksums_hash[path] != sha1_checksum
      @sha1_checksums_hash[path] = sha1_checksum
      true
    else
      false
    end
  end

end
