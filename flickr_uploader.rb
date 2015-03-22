# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))

require 'flickr_base'
require 'file_list'

class FlickrUploader
  def initialize(flickr)
    @flickr = flickr
  end

  def run(files, thread_num)
    @mutex = Mutex.new
    @queue = Queue.new
    threads = Array.new
    files.each{|f| @queue.push(f)}
    thread_num.times{
        threads << Thread.new{uploadFiles}
    }
    threads.each{|t| t.join}
    puts "-- finished --"
  end

  def uploadFiles()
    loop{
      break if @queue.size == 0
      upload(@queue.pop)
    }
  end

  def getTagByPath(path)
    path.split('/')[5] == 'Originals' ? 'Original' : 'Modified'
  end

  def upload(file)
    begin
      tag = getTagByPath(file)
      id = @flickr.photos.upload.upload_file(file, nil, nil, [tag], false, true, true)
      writeResult(file, id)
    rescue
      @queue.enq(file)
      p $!
    end
  end

  def writeResult(file, id)
    @mutex.synchronize do
      FileList.writeResult(file, id)
      puts 'uploaded: ' + file
    end
  end

end

