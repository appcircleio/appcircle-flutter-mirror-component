require 'colored'

def get_env_variable(key)
  ENV[key].nil? || ENV[key] == '' ? nil : ENV[key]
end

def abort_with1(message)
  puts "@@[error] #{message}".red
  exit 1
end

def get_info_msg(message)
  puts " \n#{message.green}"
end

def get_warning_msg(message)
  puts "@@[warning] #{message}".yellow
end

# The URL without user info, for the log.
def shown_url(url)
  url.sub(%r{\A(https?://)[^/@]*@}, '\1')
end

# Flutter appends paths to FLUTTER_STORAGE_BASE_URL ("<base>/flutter_infra_release/..."), and pub to
# PUB_HOSTED_URL, so a trailing slash would give "//" in every URL.
def mirror_url(key)
  url = get_env_variable(key)
  return nil if url.nil?

  abort_with1("#{key} must be an http or https URL.") unless url.match?(%r{\Ahttps?://\S+\z})
  url.chomp('/')
end

pub = mirror_url('AC_MIRROR_PUB')
storage = mirror_url('AC_MIRROR_FLUTTER')
if pub.nil? && storage.nil?
  puts 'AC_MIRROR_PUB and AC_MIRROR_FLUTTER are empty: Flutter and pub use their public hosts.'
  exit 0
end

env_file = get_env_variable('AC_ENV_FILE_PATH')
abort_with1('AC_ENV_FILE_PATH is not set.') if env_file.nil?

# Values for the later steps of this build only: nothing is written to the runner, so a runner that keeps
# its state between builds does not keep them.
lines = []
lines << "PUB_HOSTED_URL=#{pub}" if pub
lines << "FLUTTER_STORAGE_BASE_URL=#{storage}" if storage
File.open(env_file, 'a') { |f| lines.each { |line| f.puts(line) } }

puts "Flutter Mirror: pub packages -> #{pub ? shown_url(pub) : 'pub.dev (AC_MIRROR_PUB is empty)'}"
puts "Flutter Mirror: Flutter storage -> #{storage ? shown_url(storage) : 'storage.googleapis.com (AC_MIRROR_FLUTTER is empty)'}"
get_info_msg('Flutter Mirror is configured.')
