require 'helper'

describe Neighborhood do
  let(:files) { [ "#{ Dir.pwd }/spec/fixtures/avatar.png" ] }
  let(:n)     { Neighborhood.new(files) }
  let(:json_attrs) { JSON.parse(File.read("#{ Dir.pwd }/spec/fixtures/attributes.json")) }

  it 'finds the nearest id for a given face' do
    n.nearest_feature_ids(files.first, 1).each do |id|
      expect(n.file_from_id(id)).to eql files.first
    end
  end

  it 'returns attributes from given files' do
    attrs = { 'fixtures' => json_attrs }
    expect(n.attributes).to eq attrs
  end

  it 'finds the nearest face which is itself' do
    descriptor_count = Face.new(files.first).descriptors.length
    attrs = json_attrs
    expectation = {
      'glasses' => {
        attrs.fetch('glasses') => descriptor_count,
        !attrs.fetch('glasses') => 0
      },
      'facial_hair' => {
        attrs.fetch('facial_hair') => descriptor_count,
        !attrs.fetch('facial_hair') => 0
      }
    }

    expect(n.attributes_guess(files.first)).to eql expectation
  end

  it 'returns the proper face class' do
    file = "#{ Dir.pwd }/public/att_faces/s1/1.png"
    attrs = JSON.parse(File.read("#{ Dir.pwd }/public/att_faces/s1/attributes.json"))
    expectation = { 'glasses' => false, 'facial_hair' => false }
    attributes = %w(glasses facial_hair)
    expect(Neighborhood.face_class(file, attributes)).to eql expectation
  end

  describe 'cross-validation' do
    let(:files) { Dir["#{ Dir.pwd }/public/att_faces/**/*.png"] }
    let(:file_folds) do
      {
        'fold1' => files.each_with_index.select { |f, i| i.even? }.map(&:first),
        'fold2' => files.each_with_index.select { |f, i| i.odd? }.map(&:first)
      }
    end
    let(:neighborhoods) do
      {
        'fold1' => Neighborhood.new(file_folds.fetch('fold1')),
        'fold2' => Neighborhood.new(file_folds.fetch('fold2')),
      }
    end

    # %w(fold1 fold2).each_with_index do |fold, i|
    #   other_fold = "fold#{ (i + 1) % 2 + 1 }"
    #   it "cross validates #{ fold } against #{ other_fold }" do
    #     print "\n|k\t| Error rate\t| Ave time\t|\n"
    #     (1..7).each do |k_exp|
    #       k = 2 ** k_exp -1
    #       errors = 0
    #       successes = 0
    #       dist = measure_x_times(2) do
    #         file_folds.fetch(fold).each do |vf|
    #           face_class = Neighborhood.face_class(vf, %w(glasses facial_hair))
    #           actual = neighborhoods.fetch(other_fold).attributes_guess(vf, k)

    #           face_class.each do |k, v|
    #             if actual[k][v] > actual[k][!v]
    #               successes += 1
    #             else
    #               errors += 1
    #             end
    #           end
    #         end
    #       end

    #       error_rate = errors / (errors + successes).to_f

    #       avg_time = dist.reduce(Rational(0, 1)) do |sum, bm|
    #         sum += bm.real * Rational(1, 2)
    #       end

    #       print "|#{ k }\t| #{ error_rate }\t| #{ avg_time }\t|\n"
    #     end
    #   end
    # end
  end
end