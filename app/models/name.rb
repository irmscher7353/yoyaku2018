# -*- coding: utf-8 -*=
class Name < ApplicationRecord

  paginates_per 15

  def self.add(name)
    tokens = name.split
    (0...(n = tokens.length)).each do |i|
      next if where(value: tokens[i]).first
      create(value: tokens[i],
        is_shamei: (n == 3 && i == 0),
        is_sitenmei: (0 < i && tokens[i].match(/テン$/)),
        is_sei: ((n - i) == 2),
        is_mei: (2 <= n && (n - i) == 1),
        is_title: ((n - i) == 1 && tokens[i].match(/チョウ$/)),
      )
    end
  end

  def self.candidates(s)
    result = Hash.new{|h,k| h[k] = [] }
    if s.present? and s != ''
      tokens = s.split
      if (w = tokens[-1]) != ''
        filters = []
        if tokens.length <= 1
          filters << 'is_shamei' << 'is_sei'
        else
          prev = where(value: tokens[-2]).first
          if prev
            if prev.is_sei
              filters << 'is_mei' << 'is_title'
            elsif prev.is_shamei
              filters << 'is_sitenmei' << 'is_sei'
            else
              filters << 'is_sitenmei' << 'is_sei' << 'is_mei' << 'is_title'
            end
          else
            filters << 'is_sitenmei' << 'is_sei' << 'is_mei' << 'is_title'
          end
        end
        if 0 < filters.length
          filter = ["(%s) AND value LIKE ?" % [filters.join(' OR ')], '%s%%' % [w] ]
        else
          filter = ["value LIKE ?", '%s%%' % [w] ]
        end
        where(filter).order(:value).each do |name|
          if name.value.length <= w.length
            k = ''
          else
            k = name.value[w.length]
          end
          result[k] << name
        end
      end
    end
    result
  end

  def self.stats
    stats = {}

    stats[:invalid] = {
      :caption => 'カタカナとスペース以外を含む名前．',
      :names => [],
    }
    Name.all.each do |name|
      if not name.value.match(/^[ア-ンァ-ォ　（）ー ]+$/)
        stats[:invalid][:names] << name
      end
    end

    stats[:tokens] = Hash.new{|h,k| h[k] = {:orders => []} }
    Order.select(:name).distinct.each do |order|
      tokens = order.name.split
      n = tokens.length
      stats[:tokens][n][:orders] << order
    end

    stats
  end

  def is_last?
    is_title or not (is_shamei or is_sitenmei or is_sei)
  end

  def text
    value + (is_last? ? '' : ' ')
  end

end
