class Neighborhood
  def initialize(files)
    @ids = {}
    @files = files
    setup!
  end

  def attributes
    @files.inject({}) do |attrs, file|
      attr_file = File.join(File.dirname(file), 'attributes.json')
      attr_name = attr_file.split('/')[-2]
      attrs[attr_name] = JSON.parse(File.read(attr_file))
      attrs
    end
  end

  def attributes_guess(file, k = 4)
    ids = nearest_feature_ids(file, k)
    ids.inject(votes) do |votes, id|
      resp = self.class.face_class(@ids[id], %w(glasses facial_hair))
      resp.each { |k, v| votes[k][v] += 1 }
      votes
    end
  end

  def self.face_class(filename, subkeys)
    base = File.basename(filename, '.png')
    json = read_file_attributes(filename)
    hash = json.is_a?(Array) ? array_to_hash(json, base) : json
    hash.select { |k, v| subkeys.include?(k) }
  end

  def file_from_id(id)
    @ids.fetch(id)
  end

  def nearest_feature_ids(file, k)
    desc = Face.new(file).descriptors
    desc.inject([]) do |ids, d|
      ids.concat(@kd_tree.find_nearest(d, k).map(&:last))
      ids.uniq
    end
  end

  private

  def setup!
    kdtree_hash = face_descriptors_hash
    @kd_tree = Containers::KDTree.new(kdtree_hash)
  end

  def face_descriptors_hash
    counter = 0
    kdtree_hash = {}

    @files.each do |file|
      desc = Face.new(file).descriptors
      desc.each do |d|
        @ids[counter] = file
        kdtree_hash[counter] = d
        counter += 1
      end
    end
    kdtree_hash
  end

  def self.array_to_hash(json, base)
    json.find do |hh|
      hh.fetch('ids').include?(base.to_i)
    end or
    raise "Cannot find #{ base.to_i } inside of #{ json } for file #{ filename }"
  end

  def self.read_file_attributes(filename)
    attributes_path = File.expand_path('../attributes.json', filename)
    JSON.parse(File.read(attributes_path))
  end

  def votes
    { 'glasses' => { false => 0, true => 0 },
      'facial_hair' => { false => 0, true => 0 } }
  end
end
