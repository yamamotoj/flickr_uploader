# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))

require 'flickr_base'
require 'file_list'

class FlickrTagger

  def photoQueue
    queue = Queue.new
    tagged = FileList.tagged
    FileList.uploaded.each{|path, id|
      next if tagged[id]
      tag = getTagByPath(path)
      queue.enq [id, tag]
    }
    queue
  end

  def getTagByPath(path)
    path.split('/')[5] == 'Originals' ? 'Original' : 'Modified'
  end

  def setTag(flickr, id, tag)
    photo = Flickr::Photo.new(flickr, id)
    flickr.photos.addTags(photo, [tag])
    puts id + ' ' + tag
  end

  def setModifiedTags(thread_num = 100)
    queue = photoQueue
    threads = Array.new
    mutex = Mutex.new
    thread_num.times{
      threads << Thread.new{
        flickr = FlickrController.new.flickr
        loop do
          break if queue.empty?
          q = queue.deq
          begin
            setTag(flickr, q[0], q[1])
            mutex.synchronize do
              FileList.writeTagResult(q[0])
            end
          rescue
            queue.enq q
            p $!
          end
          puts queue.size.to_s
        end
      }
    }
    threads.each{|t| t.join}
    puts '--finished'
  end
end
