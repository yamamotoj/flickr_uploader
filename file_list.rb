
class FileList
  @@fileName = 'uploaded.txt'
  def FileList.digg(dir_path, files = nil)
    files ||= Array.new
    dir = Dir.open(dir_path)
    dir.each{|f|
      next if f == '.' || f == '..'
      next if f == '.svn'
      fullpath = "#{dir.path}/#{f}"
      if File::directory?(fullpath)
        digg(fullpath, files)
      else
        files << fullpath  if File::extname(fullpath).downcase == '.jpg'
      end
    }
    dir.close()
    files
  end

  def FileList.uploaded
    files = Hash.new
    open(@@fileName) {|file|
      while l = file.gets
        pair = l.split("\t")
        files[pair[0]] = pair[1].split("\n")[0]
      end
    }
    files
  end

  def FileList.filesToUpLoad(dir_path)
    u = uploaded
    failed = Array.new
    digg(dir_path).each{|file|
      failed << file unless u[file] 
    }
    failed
  end

  def FileList.writeResult(file, id)
    f = File.open(@@fileName, 'a')
    f.puts file + "\t" + id
    f.close
  end

  def FileList.writeTagResult(id)
    f = File.open('tagged.txt', 'a')
    f.puts id
    f.close
  end

  def FileList.tagged
    h = Hash.new
    open('tagged.txt') {|file|
      while l = file.gets
        h[l.split("\n")[0]] = true
      end
    }
    h
  end

  def FileList.writeAlbumTagged(id, tag)
    f = File.open('album_tagged.txt', 'a+')
    f.puts id + tag
    f.close
  end

  def FileList.albumTagged
    h = Hash.new
    open('album_tagged.txt') {|file|
      while l = file.gets
        h[l.split("\n")[0]] = true
      end
    }
    h
  end


end
