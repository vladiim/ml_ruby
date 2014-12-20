class Image
  HAAR_FILEPATH = "#{ Dir.pwd }/data/haarcascade_frontalface_alt.xml"
  FACE_DETECTOR = OpenCV::CvHaarClassifierCascade::load(HAAR_FILEPATH)

  attr_reader :filepath, :face_region, :image

  def initialize(filepath)
    @filepath    = filepath
    @image       = MiniMagick::Image.open(filepath)
    @name        = File.basename(filepath)
    gray_image   = OpenCV::CvMat.load(filepath, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
    @face_region = FACE_DETECTOR.detect_objects(gray_image).first
  end

  # def self.write(filepath)
  #   yield
  #   filepath
  # end

  def to_face
    image.crop(crop_params)
    image.write(outfile)
    Face.new(outfile)
  end

  def name
    File.basename(filepath)
  end

  def outfile
    File.expand_path("#{ Dir.pwd }/public/faces/avatar_#{ name }", __FILE__)
  end

  def x_size
    face_region.bottom_right.x - face_region.top_left.x
  end

  def y_size
    face_region.bottom_right.y - face_region.top_left.y
  end

  def crop_params
    "#{ x_size - 1 }x#{ y_size - 1}+#{ face_region.top_left.x + 1 }+#{ face_region.top_left.y + 1 }"
  end

  def duplicate?(image)
    signature == image.signature
  end

  def signature
    image.signature
  end
end