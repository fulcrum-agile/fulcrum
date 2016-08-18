require 'rails_helper'

describe UsernameParser do
  context '#parse' do
    it 'returns an array with usernames' do
      expect(UsernameParser.parse('Foo @bar @baz')).to be_eql %w(bar baz)
    end

    it 'returns an empty array' do
      expect(UsernameParser.parse('Foo bar')).to be_eql []
    end

    it 'finds usernames with dots in between' do
      expect(UsernameParser.parse('Foo @bar.123 @baz.abc.def')).to be_eql %w(bar.123 baz.abc.def)
    end

    it 'finds usernames with dashes in between' do
      expect(UsernameParser.parse('Foo @bar-123 @baz-abc.def')).to be_eql %w(bar-123 baz-abc.def)
    end
  end
end
