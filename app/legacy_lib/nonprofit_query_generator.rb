class NonprofitQueryGenerator
  def initialize(id)
    @id = id.to_i
  end

  def nonprofits
    Qx.select("*").from(:nonprofits).where("id = $id", id: @id)
  end

  def supporters
    Qx.select('supporters.*')
      .from(:supporters)
      .where("supporters.nonprofit_id = $id and deleted != 'true'", id: @id )
  end

  def supporter_notes
    Qx.select("supporter_notes.*").from(:supporters).join(:supporter_notes, "supporters.id = supporter_notes.supporter_id")
  end
    

  def tag_masters
    Qx.select("*").from(:tag_masters).where("nonprofit_id = $id AND NOT deleted", id: @id)
  end
end