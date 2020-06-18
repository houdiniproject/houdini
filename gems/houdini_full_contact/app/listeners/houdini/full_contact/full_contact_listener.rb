module Houdini::FullContact::FullContactListener
    def supporter_create(supporter)
        Houdini::FullContact::InsertInfos.enqueue(supporter.id)
    end
end