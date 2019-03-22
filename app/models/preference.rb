class Preference < ApplicationRecord
  validates :name, presence: true

  def self.get_area_codes
    h = to_hash
    h['短縮市外局番'].gsub(/ /, '').split(/,/)
  end

  def self.get_due_datetime
    datetime = {}
    h = to_hash
    datetime[:monthes] = (h['引渡し開始月'].to_i .. h['引渡し終了月'].to_i).map{|mm| mm}
    datetime[:days] = (h['引渡し開始日'].to_i .. h['引渡し終了日'].to_i).map{|dd| dd}
    hh0, mm0 = h['引渡し開始時間'].split(':')
    hh1, mm1 = h['引渡し終了時間'].split(':')
    datetime[:hours] = (hh0.to_i .. hh1.to_i).map{|hh| hh}
    datetime[:minutes] = [0, 30]
    datetime
  end

  def self.get_phrases()
    get_value('備考欄の常套句').split(/[\r\n]+/)
  end

  def self.get_value(name)
    where(name: name).first.value
  end

  def self.to_hash
    h = {}
    Preference.all.order(:updated_at).each do |preference|
      h[preference.name] = preference.value
    end
    h
  end
end
