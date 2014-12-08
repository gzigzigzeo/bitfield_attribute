class TestBitfield < BitfieldAttribute::Base
  bits :first, :second, :last
end

module BitField
  class User
    class NotificationSettings < BitfieldAttribute::Base
      bits :second
    end
  end
end
