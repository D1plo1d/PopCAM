module Rotatable

  attr_accessor(
    :relative_x,
    :relative_y,
    :relative_z,
    :relative_rotation,
    :inverted,
    :parent,
    :layer
  )

  # Absolute x coordinate
  def x
    absolute_coordinates[:x]
  end

  # Absolute y coordinate
  def y
    absolute_coordinates[:y]
  end

  # Absolute z coordinate
  def z
    absolute_coordinates[:z]
  end

  def rotation
    inversion = self.inverted ? 180 : 0
    parent_rotation = parent.present? ? parent.rotation : 0
    @abs_rotation = ((relative_rotation||0) + inversion + parent_rotation)%360
  end

  def rotation_without_inversions
    parent_rotation = parent.present? ? parent.rotation_without_inversions : 0
    @abs_rotation_wo_inversion = ((relative_rotation||0) + parent_rotation)%360
  end

  # Memoized sin rotation value
  def sin_r
    @sin_theta = Math::sin(relative_rotation * Math::PI / 180  || 0)
  end

  # Memoized cos rotation value
  def cos_r
    @cos_theta = Math::cos(relative_rotation * Math::PI / 180  || 0)
  end

  def relative_rotation=(val)
    @relative_rotation = val.to_f
    @cos = nil
    @sin = nil
  end

  # Move the rotatable piece and reset it's memoized values
  def set_position!(coords)
    @relative_x = coords[:x] || 0
    @relative_y = coords[:y] || 0
    @relative_z = coords[:z] || 0
    @inverted = coords[:inverted] || false
    self.layer = coords[:layer] || "Top"
    self.relative_rotation = (
      coords[:relative_rotation] || coords[:rotation] || 0
    )
    mark_as_dirty!
  end

  def mark_as_dirty!
    @abs_coords = nil
    @abs_rotation = nil
  end

  def coordinates_dirty?
    @abs_coords.blank? or (parent.present? and parent.coordinates_dirty?)
  end

  def relative_x
    @relative_x || 0
  end

  def relative_y
    @relative_y || 0
  end

  def relative_z
    @relative_z || 0
  end

  def absolute_coordinates
    return @abs_coords unless coordinates_dirty?
    if parent.present?
      @abs_coords = {
        x: parent.x + relative_x * parent.cos_r - relative_y * parent.sin_r,
        y: parent.y + relative_x * parent.sin_r + relative_y * parent.cos_r,
        z: parent.z + relative_z
      }
    else
      @abs_coords = {x: relative_x, y: relative_y, z: relative_z}
    end
    return @abs_coords
  end

end