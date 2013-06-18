require 'fileutils'

class Fsh
    def cmd(c)
      # parse a command line and call appropriate function, returning output
      c.match /^(\w+)\s*(.*)/   # only handles one argument
      cmd = $1 
      arg = $2

      case cmd
      when 'echo'
        return echo(arg)
      when 'ls'
        return ls(arg)
      when 'mkdir'
        return mkdir(arg)
      when 'touch'
        return touch(arg)
      else
        return cmd + ": command not found\n"
      end
    end

    def echo(arg)
      # parrot back arg
      return arg + "\n"
    end

    def ls(arg)
      # Retreive a list of files in a directory
      if (arg == nil || arg == "")
        arg = '.' # assume current directory
      end
      begin
        return Dir.entries(arg).join(' ') + "\n"
      rescue Errno::ENOENT => e
        return "ls: " + arg + ": No such file or directory\n"
      end
    end
  
    def mkdir(arg)
      # create a directory
      begin
        Dir.mkdir(arg)
        return "\n"
      rescue Errno::EACCES => e
        return "mkdir: " + arg + ": Permission denied\n"
      rescue Errno::ENOENT => e
        return "mkdir: " + arg + ": No such file or directory\n"
      end
    end

    def touch(arg)
      # create a file or update an existing file's mtime and atime
      begin
        FileUtils.touch(arg)
        return "\n"
      rescue Errno::EACCES => e
        return "touch: " + arg + ": Permission denied\n"
      rescue Errno::ENOENT => e
        return "touch: " + arg + ": No such file or directory\n"
      end
    end
end

if __FILE__ == $PROGRAM_NAME
  sh = Fsh.new()
  prompt = '(>^_^)> '
  print prompt
  while cmd = STDIN.gets
    cmd.chomp!
    print sh.cmd(cmd)
    print prompt
  end
end

