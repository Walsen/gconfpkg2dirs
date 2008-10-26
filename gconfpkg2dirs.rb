#!/usr/bin/ruby -w

=begin comments
 This script migrates package.{use, mask, unmask, keywords} to directories and files 
=end

require 'fileutils'

PROCSYM = "<>>> "
FILESPATH = "/etc/portage/"
TEMPDIR = FILESPATH + "tmp/"
BACKUPDIR = FILESPATH + "bkp/"
CFILES = [ "package.keywords", "package.mask", "package.unmask", "package.use" ]
dirFiles = Dir.entries(FILESPATH)

def directificate(name)
  # Check if the file exists e.g. package.keywords
  if File.exists?(name) 
    m = newdir = newfile = f = nil
    tempsub = TEMPDIR + name
    # Make a new directory with that name like package.keywords
    Dir.mkdir(tempsub)
    puts PROCSYM + "Created directory #{name}"
    # Opens the file in read mode
    File.open(name, "r") { |file|
      # Reads line by line
      fcount = 0
      file.each_line { |line| 
        # Matchs the '/' with a regular expression and isolate pre and post strings
	m = /(\/)/.match(line)
	# This is like /usr/portage/tmp/package.use/app-portage
	newdir = tempsub + '/' + m.pre_match
	# File name
	newfile = newdir + '/' + 'file' + fcount.to_s
	fcount += 1
	# Checks if the directory already exists
	if ! File.exists?(newdir)
	  # Creates the directory
	  Dir.mkdir(newdir)
	  puts PROCSYM + "Created directory #{newdir}"
	end
	    
	f = File.new(newfile, "w+")
	# Commenting here, trying with full atom name
	#f.puts m.post_match
	#
	f.puts line
	puts PROCSYM + "Created file #{newfile}"
      }
    } 
  end
end

if Dir.pwd != FILESPATH
  Dir.chdir(FILESPATH)
end

puts "Starting migration..."
if ! File.exists?(TEMPDIR)
  Dir.mkdir(TEMPDIR)
  puts PROCSYM + "Creating TEMPORARY directory"
end

dirFiles.each do |f|
  if CFILES.include?(f)
    if ! File.directory?(f)
      directificate(f)
    end
  end
end

# TODO Verify is all package.{*} exists as directories and handle them into the BACKUP directory.
if ! File.exists?(BACKUPDIR)
  Dir.mkdir(BACKUPDIR)
  puts PROCSYM + "Creating BACKUP directory"
end

include FileUtils
CFILES.each do |f|
  if ! File.directory?(f)
    cp(f, BACKUPDIR)
    puts PROCSYM + "Copying #{f} to the BACKUP directory"
    rm(f)
    puts PROCSYM + "Removing #{f} from the configuration directory"
  end
end
=begin
newdirs = Dir.entries(TEMPDIR)
newdirs.each do |d|
  cp(d, FILESPATH)
  puts PROCSYM + "Copying new dictories to the confguration directory"
end
=end
puts "Process finished."
