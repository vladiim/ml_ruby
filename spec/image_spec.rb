require 'helper'

describe Image do
  let(:image)  { Image.new("#{ Dir.pwd }/spec/fixtures/raw.png") }
  let(:face)   { image.to_face }
  let(:avatar) { Image.new("#{ Dir.pwd }/spec/fixtures/avatar.png") }
  let(:test_avatar) { Image.new(face.filepath) }

  it 'tries to convert to a face avatar using the haar classifier' do
    expect(avatar).to be_duplicate(test_avatar)
  end
end