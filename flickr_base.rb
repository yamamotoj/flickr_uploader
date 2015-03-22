# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))

require 'rubygems'
gem 'flickr'
require 'flickr'
require 'flickr_uploader'
require 'flickr_deleter'
require 'flickr_make_sets'
require 'flickr_tagger'
require 'flickr_album_tagger'
require 'file_list'

class FlickrController
  attr_reader :flickr
  def initialize()
    api_key = 'f494851e4f2655b9ed453a5342cadd60'
    secret = '76fbc6c0995b7b1a'
    @flickr = Flickr.new('flickr.dat', api_key, secret)
    getToken
  end

  def getToken
    return if @flickr.auth.token
    url = @flickr.auth.login_link                                               
    puts "Webブラウザで #{url} へアクセスしてから、何かキーを押してください"
    gets
    @flickr.auth.getToken
    @flickr.auth.cache_token
  end

  def uploader() @uploader ||= FlickrUploader.new(@flickr)  end

  def deleter() @deleter ||= FlickrDeleter.new(@flickr) end

  def setMaker() @setMaker ||= FlickrSetMaker.new(@flickr) end

  def searchByUploadDate(from, to, delim = '-')
    puts fromT.to_i.to_s
    puts toT.to_i.to_s

    @flickr.photos.search(:user_id => @flickr.auth.token.user,
                          :min_upload_date => fromT,
                          :max_upload_date => toT)
  end

  def deleteByUploadDate(from, to, delim = '-')
    threads = Array.new
    while photos = searchByUploadDate(from, to)
      photos.each{|photo|
        title = photo.title
        @flickr.photos.delete(photo)
        puts title
      }
    end
    threads.each{|t| t.join}
  end

end
