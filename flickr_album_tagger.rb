# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))

require 'flickr_base'
require 'file_list'
require 'album_data_parser'

class FlickrAlbumTagger
  ALBUM_DATA_PATH = '/Users/Jumpei/Pictures/iPhoto Library/AlbumData.xml'

  def getAlbums
    data = parseAlbumData
    images = data['Master Image List']
    uploaded = FileList.uploaded
    albums = Hash.new
    data['List of Albums'].each{|album|
      name = album['AlbumName']
      next if name == '修復された写真'
      next if name == '2009/12/27'
      next if name == '最後の読み込み'
      next if name == '写真'
      next if name == '修復された写真'
      next if name == '最近の 12 カ月間'
      paths = Array.new
      album['KeyList'].each{|key|
        paths << uploaded[images[key]['ImagePath']]
      }
      albums[name] = paths
    }
    albums.each{|k, v|
      puts k
    }
    albums
  end


  def photoQueue
    queue = Queue.new
#    tagged = FileList.albumTagged
    albums = getAlbums
    albums.each{|tag, arr|
      arr.each{|id|
 #       next if tagged[id + tag]
        queue.enq [id, tag]
      }
    }
    queue
  end

  def setTag(flickr, id, tag)
    photo = Flickr::Photo.new(flickr, id)
    flickr.photos.addTags(photo, [tag])
    puts id + ' ' + tag
  end

  def setAlbumTags(thread_num = 100)
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
              FileList.writeAlbumTagged(q[0], q[1])
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
