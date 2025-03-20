# frozen_string_literal: true

class RegisterNonprofitAndUser::TryToFindASlug < Actor
  input :nonprofit

  def call
    slug = ::SlugNonprofitNamingAlgorithm.new(nonprofit.state_code_slug, nonprofit.city_slug).create_copy_name(nonprofit.slug)
    nonprofit.slug = slug
    nonprofit.save!
  end
end
