# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Entities::Supporter < Houdini::V1::Entities::SupporterStub
  expose :default_address, using: Houdini::V1::Entities::Address, documentation: {type: 'Houdini::V1::Entities::Address'}
end