import React, { useEffect, useRef, useState } from "react";

const ChatBot = (props) => {
  const [messages, setMessages] = useState(props.messages || []);
  const [loading, setLoading] = useState(false);
  const [input, setInput] = useState("");

  const loading_message = () => {
    return (
      <div>
        <div className="flex justify-center items-center">
          <i className="mdi mdi-loading text-white text-2xl animate-spin"></i>
        </div>
      </div>
    );
  };

  const display_messages = [...messages];
  if (loading) {
    display_messages.push({ role: "assistant", message: loading_message() });
  }

  const messagesArea = useRef(null);
  useEffect(() => {
    messagesArea.current.scrollTop = messagesArea.current.scrollHeight;
  }, [messages]);

  const sendMessage = (e) => {
    e.preventDefault();

    setMessages((old) => [...old, { role: "user", message: input }]);
    setLoading(true);
    setInput("");
    $.ajax(props.send_path, {
      method: "POST",
      data: { message: input },
      success: (res) => {
        setMessages((old) => [...old, res]);
        setLoading(false);
      },
      error: () => {
        ErrorNotifier.get.show("Something went wrong.");
        setLoading(false);
      },
    });
  };

  return (
    <div className="size-full flex flex-col">
      <div className="bg-primary-500 text-white p-4">
        Your personal assistant
      </div>
      <div
        ref={messagesArea}
        className="flex-1 flex flex-col gap-1 overflow-y-auto p-2"
      >
        {display_messages.map(({ role, message }, idx) => (
          <div
            className={`w-full flex ${
              role === "user" ? "justify-end" : "justify-start"
            }`}
            key={idx}
          >
            <div
              className={`${
                role === "assistant" ? "bg-primary-400" : "bg-white"
              } text-${
                role === "assistant" ? "white" : "black"
              } max-w-64 shadow-md rounded-lg p-2`}
            >
              {message}
            </div>
          </div>
        ))}
      </div>
      <form
        onSubmit={sendMessage}
        className="flex justify-between w-full"
        style={{ marginBottom: 0 }}
      >
        <div className="flex-1 flex flex-col justify-center items-center">
          <input
            placeholder="Message..."
            className="w-11/12 rounded-full mb-2"
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
          />
        </div>
      </form>
    </div>
  );
};

export default ChatBot;
