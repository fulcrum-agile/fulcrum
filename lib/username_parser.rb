class UsernameParser
  USERNAME_REGEX = /@([a-z0-9_\.-]+)/i

  def self.parse(text)
    new(text).parse
  end

  def initialize(text)
    @text = text
  end

  def parse
    text.scan(USERNAME_REGEX).flatten
  end

  private

  attr_reader :text
end
