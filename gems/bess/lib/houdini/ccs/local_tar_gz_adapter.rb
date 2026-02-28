# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Houdini::Ccs::LocalTarGzAdapter
  def initialize(**options)
    @options = options
  end

  # returns passes a url or io to the block
  def retrieve_ccs(&block)
    temp_file = Tempfile.new
    result = Kernel.system("git archive --format=tar.gz -o #{temp_file.path} HEAD")
    begin
      if result
        yield block(file)
      else
        raise "We couldn't create a CCS from the git archive. Is git available?"
      end
    ensure
      temp_file.close
      temp_file.unlink
    end
  end
end
