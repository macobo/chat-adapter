require_relative('../../_lib')

class Base < Critic::Test
  def stubbed_object(method, expectations=[])
    stub = Object.new
    stub.expects(method).with(*expectations)
    stub
  end

  describe 'Simple adapter' do
    class SimpleAdapter < ChatAdapter::Base
      def initialize; end
    end

    it 'should call the block passed to on_message when processing a message' do
      adapter = SimpleAdapter.new

      stub = stubbed_object(:method, ['abc', {:b => 5}])

      adapter.on_message do |message, event|
        stub.method(message, event)
      end
      answer = adapter.process_message('abc', :b => 5)
    end

    it 'should return the same answer returned by on_message block' do
      adapter = SimpleAdapter.new

      adapter.on_message do |message, event|
        message.capitalize + "!!!"
      end
      answer = adapter.process_message('really')
      assert_equal('Really!!!', answer)
    end

    it 'should raise an error if need to process message and on_message not called' do
      assert_raises(RuntimeError) do
        SimpleAdapter.new.process_message('abc', {})
      end
    end
  end

  describe 'Simple validation' do
    class SillyValidatingAdapter < ChatAdapter::Base
      def initialize; end

      # don't do this in a real chat system, please!
      def validate(event_data)
        event_data[:token] == '555'
      end
    end
    it 'should pass messages which pass test' do
      adapter = SillyValidatingAdapter.new

      adapter.on_message { |message, event| message }
      assert_equal('a message', adapter.process_message('a message', :token => '555'))
    end

    it 'should not pass messages which do not pass test' do
      adapter = SillyValidatingAdapter.new

      adapter.on_message { |message, event| message }
      assert_nil(adapter.process_message('a message', :token => 'wrong'))
    end
  end
end
