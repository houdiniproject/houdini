# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Houdini::Ccs::GithubAdapter
  include ActiveModel::AttributeAssignment
  attr_accessor :account, :repo
  def initialize(attributes = {})
    assign_attributes(attributes) if attributes
  end

  # returns passes a url or io to the block
  def retrieve_ccs(&block)
    if !account || !repo
      raise("You must provide an account and repo for the CCS adapter for Github")
    end
    begin
      git_hash = File.read("#{Rails.root.join("CCS_HASH")}")
      yield "https://github.com/#{account}/#{repo}/tree/#{git_hash}"
    rescue
      raise "Your CCS_HASH couldn't be read. Make sure it's in your Rails root"
    end
  end
end
