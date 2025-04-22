# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# InterpolationDictionary is a simple class for replacing braced variables,
# like {{NAME}}, with a different value. We use this for email templates.
class InterpolationDictionary
  attr_reader :entries

  # pass in entries with defaults
  def initialize(entries = {})
    @entries = entries
  end

  def add_entry(entry_name, value)
    if @entries.has_key?(entry_name) && full_sanitize(value).present?
      @entries[entry_name] = full_sanitize(value)
    end
  end

  def interpolate(message)
    result = Format::Interpolate.with_hash(message, @entries)
    sanitize(result) if sanitize(result).present?
  end

  private

  def full_sanitize(value)
    ActionView::Base.full_sanitizer.sanitize(value)
  end

  def sanitize(value)
    ActionView::Base.safe_list_sanitizer.sanitize(value)
  end
end
