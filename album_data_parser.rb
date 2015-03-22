# -*- coding: utf-8 -*-
require 'rexml/parsers/streamparser' 
require 'rexml/parsers/baseparser' 
require 'rexml/streamlistener' 

ALBUM_DATA_PATH = '/Users/Jumpei/Pictures/iPhoto Library/AlbumData.xml'


class ListenerBase < Hash
  include REXML::StreamListener 
  attr_accessor :child
  attr_accessor :parent
  attr_reader :name

  def initialize name=nil
    @name = name
  end

  def tag_start(name, attrs)
    return @child.tag_start(name, attrs) if @child
    case name
    when 'dict'
      @child = DictListener.new(name)
    when 'array'
      @child = ArrayListener.new(name)
    when 'plist'
      @child = ArrayListener.new(name)
    else
      @child = ListenerBase.new(name)
    end
    @child.parent = self
  end

  def tag_end name
    return @child.tag_end name if @child
    raise unless @name == name
    return unless @parent
    @parent.addChildValue(name, value)
    @parent.child = nil
  end 

 def text text
   return @child.text text if @child
   @value = text
 end

 def value
   @value
 end

end

class DictListener < ListenerBase
  def initialize(name)
    @hash = Hash.new
    super name
  end

  def value
    @hash
  end

  def addChildValue(name, val)
    case name
    when 'key'
      @currentKey = val
    else
      @hash[@currentKey] = val
    end
  end
end

class ArrayListener < ListenerBase
  def initialize name=nil
    super name
    @arr = Array.new
  end

  def addChildValue(name, val)
    @arr << val
  end

  def value
    @arr
  end

end

def parseAlbumData
  source = File.read ALBUM_DATA_PATH
  listener = ArrayListener.new 
  REXML::Parsers::StreamParser.new(source, listener).parse
  listener.value[0][0]
end

