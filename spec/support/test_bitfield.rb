class TestBitfield < BitfieldAttribute::Base
  define_bits :first, :second, :last
end

module BitField
  class User
    class NotificationSettings < BitfieldAttribute::Base
      define_bits :second
    end
  end
end
