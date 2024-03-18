require 'http'

module ChatBot
  @@API = 'https://api.openai.com/v1'.freeze
  @@ASSISTANT_ID = 'asst_eyZ3NCIx1OTV57bV4MNmO4H3'.freeze

  def self.create_thread
    res = http_client.post(@@API + '/threads')

    JSON.parse(res.body)["id"]
  end

  def self.get_messages(thread_id)
    res = http_client.get(@@API + "/threads/#{thread_id}/messages")

    data = JSON.parse(res.body)["data"]
    roles = data.map { |m| m["role"] }
    messages = data.map { |m| m["content"].first["text"]["value"] }
    messages.map! { |m| decode(m) }

    messages = roles.zip(messages)
    messages.reverse!
    messages.filter! { |_, m| Message === m }
    messages.map! { |r, m| [r, m.message] }
    messages.map! { |r, m| { role: r, message: m } }
  end

  def self.send_context(context, thread_id)
    res = send(Context.new(context), thread_id)
    raise "Unexpected response type: #{res.class}" unless res.is_a?(ContextAcknowledgement)
    true
  end

  def self.send_message(message, thread_id)
    send(Message.new(message), thread_id).message
  end

  private

  def self.send(obj, thread_id)
    http_client.post(@@API + "/threads/#{thread_id}/messages", json: {
      role: "user",
      content: encode(obj)
    })

    res = http_client.post(@@API + "/threads/#{thread_id}/runs", json: {
      assistant_id: @@ASSISTANT_ID,
    })
    run = JSON.parse(res.body)

    while %w[queued in_progress cancelling].include?(run["status"])
      sleep 0.5
      res = http_client.get(@@API + "/threads/#{thread_id}/runs/#{run["id"]}")
      run = JSON.parse(res.body)
    end

    raise "Unexpected run status: #{run["status"]}" unless run["status"] == "completed"

    res = http_client.get(@@API + "/threads/#{thread_id}/messages", params: { limit: 1 })
    message = JSON.parse(res.body)["data"].first["content"].first

    raise "Unexpected response type: #{message["type"]}" unless message["type"] == "text"

    decode(message["text"]["value"])
  end

  def self.http_client
    HTTP['OpenAI-Beta' => 'assistants=v1',
         'Authorization' => "Bearer #{Rails.application.credentials.dig(:apis, :openai_key)}",
         'Content-Type' => 'application/json']
  end

  def self.encode(obj, _top_level = true)
    if obj.is_a?(Hash)
      obj.map { |k, v| [k, encode(v, false)] }.to_h
    elsif obj.is_a?(Array)
      obj.map! { |v| encode(v, false) }
    elsif obj.respond_to?(:attributes)
      objClass = obj.class.name.split('::')[1..].join('::')
      obj = obj.attributes
      obj["_type"] = objClass
      obj = encode(obj, false)
    end

    if _top_level
      obj.to_json
    else
      obj
    end
  end

  def self.decode(obj, _top_level = true)
    if _top_level
      obj = JSON.parse(obj)
    end

    obj.map { |k, v| [k, decode(v, false)] }.to_h if obj.is_a?(Hash)
    obj.map! { |v| decode(v, false) } if obj.is_a?(Array)

    return obj unless obj.is_a?(Hash) and obj.key?('_type')

    klass = Object.const_get("#{self.name}::#{obj.delete('_type')}")
    klass.from_attributes(obj)
  end

  class Message
    attr_accessor :message

    def initialize(message)
      self.message = message.to_s
    end

    def attributes
      { "message" => message }
    end

    def self.from_attributes(attributes)
      new(attributes["message"])
    end
  end

  class Context
    attr_accessor :context

    def initialize(context)
      @context = context
    end

    def attributes
      { "context" => context }
    end

    def self.from_attributes(attributes)
      new(attributes["context"])
    end
  end

  class ContextAcknowledgement
    def self.from_attributes(_)
      new
    end
  end
end