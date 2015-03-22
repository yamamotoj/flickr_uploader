# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))

require 'flickr_base'
require 'file_list'

class FlickrSetMaker
  def initialize(flickr)
    @flickr = flickr
  end

  def photoMap
    sets = Hash.new
    FileList.uploaded.each{|path, id|
      s = path.split('/')
      year = s[6]
      dir = s[7]
      next if /^20\d\d:/ =~ dir
      (sets[year + ' ' + dir] ||= Array.new) << Flickr::Photo.new(@flickr, id)
    }
    sets
  end

  def createPhotoSets
    photoMap.each{|title, photos|
      puts title
      photoset = @flickr.photosets.create(title, photos[0])
      @flickr.photosets.editPhotos(photoset, photos[0], photos)
    }
  end

  def deleteAllPhotoSets
    @flickr.photosets.getList.each{|set|
      @flickr.photosets.delete(set)
    }
  end
end
