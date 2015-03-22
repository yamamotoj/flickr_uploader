# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))

require 'flickr_base'

class FlickrDeleter
  def initialize(flickr)
    @flickr = flickr
  end

  def search(args)
    args[:user_id] = @flickr.auth.token.user
    args['page'] = 1
    count = 0
    loop do
      photos = @flickr.photos.search(args)
      photos.each{|p|
        @queue.push(p)
      }
      count += photos.size
      puts count.to_s
      break if photos.size == 0
      args['page'] += 1
    end
    @thread_num.times{
      @queue.enq 'END'
    }
  end

  def delete
    flickr = FlickrController.new.flickr
    loop do
      photo = @queue.deq
      break if photo == 'END'
      flickr.photos.delete(photo)
      puts photo.title
    end
    puts "finished"
  end

  def run(args, thread_num)
    @queue = Queue.new
    @thread_num = thread_num
    threads = Array.new
    search(args)
    thread_num.times{
      threads << Thread.new{delete}
    }
    threads.each{|t| t.join}
    puts "-- finished --"
  end


  def deleteByUploadDate(from, to, delim = '-')
    fromT = Time.local *from.split(delim)
    toT = Time.local *to.split(delim)
    args = Hash.new
    args[:min_upload_date] = fromT
    args[:max_upload_date] = toT
    run(args, 50)
  end
end
