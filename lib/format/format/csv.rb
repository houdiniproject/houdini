# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'csv'
require 'format/currency'

module Format
  module Csv

    # Convert an array of hashes of data into a csv
    # @param [Array<Hash>] an array of hashes. The hash keys of the first item in the array become the CSV titles
    # @return [String]
    def self.from_data(arr)
      return CSV.generate do |csv|
        csv << arr.first.keys.map{|k| k.to_s.titleize}
        arr.each{|h| csv << h.values}
      end
    end

    def self.from_vectors(vecs)
      return CSV.generate do |csv|
        csv << vecs.first.to_a.map{|k| k.to_s.titleize}
        vecs.drop(1).each{|v| csv << v.to_a}
      end
    end

    def self.from_array(arr)
      return CSV.generate do |csv|
        csv << arr.first.map{|h| h.to_s.titleize}
        arr.drop(1).each{|row| csv << (row||[])}
      end
    end

  end
end
