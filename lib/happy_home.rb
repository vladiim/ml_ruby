require 'matrix'

class Home
  def distance(v1, v2)
    (v1 - v2).magnitude
  end

  def house_happiness
    {
      Vector[56, 2] => 'Happy',
      Vector[3, 20] => 'Not Happy',
      Vector[18, 1] => 'Happy',
      Vector[20, 14] => 'Not Happy',
      Vector[30, 30] => 'Happy',
      Vector[35, 35] => 'Happy'
    }
  end

  def find_nearest(house, k = 1)
    house_happiness.sort_by do |point, v|
      distance(point, house)
    end.first(k)
  end
end

# h1 = Vector[10, 10]
# h2 = Vector[40, 40]

# h = Home.new

# h.find_nearest(h1)
# h.find_nearest(h2)