require 'fsh'

describe Fsh do
  let(:sh) {Fsh.new()}
  describe '#cmd' do  

    it "returns and error for a bad command" do
      expect(sh.cmd("blenderize foo.txt")).to eq("blenderize: command not found\n")
    end

    it "echos with no arguments" do
      expect(sh.cmd("echo")).to eq("\n")
    end

    it "echos arguments" do
      expect(sh.cmd("echo This is a thing")).to eq("This is a thing\n")
    end

    it "lists the content of the current directory with no arguments" do
      current = ['.', '..', 'foo.txt', 'bar.txt']
      Dir.should_receive(:entries).with('.').and_return(current)
      expect(sh.cmd("ls")).to eq(current.join(' ') + "\n")
    end

    it "lists the content of the argument directory" do
      other = ['.', '..', 'include', 'lib', 'local', 'sbin', 'share']
      Dir.should_receive(:entries).with('/usr').and_return(other)
      expect(sh.cmd("ls /usr")).to eq(other.join(' ') + "\n")
    end

    it "gives an error for a non-existent dir" do
      Dir.should_receive(:entries).with('/No/Such').and_raise(Errno::ENOENT)
      expect(sh.cmd("ls /No/Such")).to eq("ls: /No/Such: No such file or directory\n")
    end

    it "creates a directory" do
      Dir.should_receive(:mkdir).with('my_files').and_return(0)
      expect(sh.cmd("mkdir my_files")).to eq("\n")
    end

    it "gives an error when directory cannot be created" do
      Dir.should_receive(:mkdir).with('/root/secret_stuff').and_raise(Errno::EACCES)
      expect(sh.cmd("mkdir /root/secret_stuff")).to eq("mkdir: /root/secret_stuff: Permission denied\n")
    end

    it "gives an error for a non-existent containing dir" do
      Dir.should_receive(:mkdir).with('/No/Such/mydir').and_raise(Errno::ENOENT)
      expect(sh.cmd("mkdir /No/Such/mydir")).to eq("mkdir: /No/Such/mydir: No such file or directory\n")
    end

    it "creates a file" do
      FileUtils.should_receive(:touch).with('my_file.md')
      expect(sh.cmd("touch my_file.md")).to eq("\n")
    end
    it "gives an error when file cannot be accessed" do
      FileUtils.should_receive(:touch).with('/stuff.doc').and_raise(Errno::EACCES)
      expect(sh.cmd("touch /stuff.doc")).to eq("touch: /stuff.doc: Permission denied\n")
    end

    it "gives an error for a non-existent containing dir" do
      FileUtils.should_receive(:touch).with('/No/Such/stuff.doc').and_raise(Errno::ENOENT)
      expect(sh.cmd("touch /No/Such/stuff.doc")).to eq("touch: /No/Such/stuff.doc: No such file or directory\n")
    end
  end
end
