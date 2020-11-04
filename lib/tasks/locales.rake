# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
desc 'For generated locales used by the frontend'

namespace :locales do
  task generate: :environment do 
    GenerateLocales.generate
  end
end
