require 'helper'

describe Face do
  let(:avatar_path) { "#{ Dir.pwd }/spec/fixtures/avatar.png" }
  let(:face_1)      { Face.new(avatar_path) }
  let(:face_2)      { Face.new(avatar_path) }
  let(:face_desc_1) { face_1.descriptors }
  let(:face_desc_2) { face_2.descriptors }

  it 'has the same descriptors for the same face' do
    descriptors_1 = face_desc_1.sort_by! { |row| Vector[*row].magnitude }
    descriptors_2 = face_desc_2.sort_by! { |row| Vector[*row].magnitude }

    descriptors_1.zip(descriptors_2).each do |f1, f2|
      expect(0.99..1.01).to include(cosine_similarity(f1, f2)), "Face descriptions don't match"
    end
  end

  it 'has the same keypoints for the same face' do
    face_1.keypoints.each_with_index do |kp, i|
      f1 = Vector[kp.pt.x, kp.pt.y]
      f2 = Vector[face_2.keypoints[i].pt.x, face_2.keypoints[i].pt.y]
      expect(0.99..1.01).to include(cosine_similarity(f1, f2)), "Face keypoints don't match"
    end
  end
end

def cosine_similarity(ar1, ar2)
  v1 = Vector[*ar1]
  v2 = Vector[*ar2]
  v1.inner_product(v1) / (v1.magnitude * v2.magnitude)
end