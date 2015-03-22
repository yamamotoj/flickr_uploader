# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))

require 'flickr_base'


def upload(flickr, dir)
  flickr.uploader.run(FileList.digg(dir), 1)
end

def uploadNew(flickr, dir)
  files = FileList.filesToUpLoad(dir)
  flickr.uploader.run(files, 5)
end

def uploadFlickr
  flickr = FlickrController.new
  uploadNew(flickr,"/Users/jumpei/Pictures/iPhoto Library/Originals")
  uploadNew(flickr,"/Users/jumpei/Pictures/iPhoto Library/Modified")
end

def delete(flickr)
  flickr.deleter.deleteByUploadDate('2010-2-9', '2010-2-15')
end

def createPhotoSets
  flickr = FlickrController.new
  flickr.setMaker.createPhotoSets
end

def setTags
  FlickrTagger.new.setModifiedTags
end

def setAlbumTags
  FlickrAlbumTagger.new.setAlbumTags
end

puts DateTime.now.to_s
uploadFlickr
puts DateTime.now.to_s



