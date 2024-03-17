import React, {useEffect, useRef, useState} from 'react'

const ChatBot = (props) => {
    const [messages, setMessages] = useState(props.messages || [])
    const [loading, setLoading] = useState(false)
    const [input, setInput] = useState('')

    const display_messages = [...messages]
    if (loading) {
        display_messages.push({role: 'assistant', message: 'Loading...'})
    }

    const messagesArea = useRef(null)
    useEffect(() => {
        messagesArea.current.scrollTop = messagesArea.current.scrollHeight
    }, [messages])

    const sendMessage = (e) => {
        e.preventDefault()

        setMessages(old => [...old, {role: 'user', message: input}])
        setLoading(true)
        setInput('')
        $.ajax(props.send_path, {
            method: 'POST',
            data: {message: input},
            success: (res) => {
                setMessages(old => [...old, res])
                setLoading(false)
            },
            error: () => {
                ErrorNotifier.get.show('Something went wrong.')
                setLoading(false)
            }
        })
    }

    return <div className="size-full flex flex-col">
        <div ref={messagesArea} className="flex-1 flex flex-col gap-1 overflow-y-auto p-2">
            {display_messages.map(({role, message}) => (
                <div className={`w-full flex ${role === 'user' ? 'justify-end' : 'justify-start'}`}>
                    <div
                        className={`bg-${role === 'assistant' ? 'primary-500' : 'white'} text-${role === 'assistant' ? 'white' : 'black'} max-w-64 shadow rounded-lg p-2`}>
                        {message}
                    </div>
                </div>
            ))}
        </div>
        <form onSubmit={sendMessage} className="flex justify-between w-full" style={{marginBottom: 0}}>
            <div className="flex-1">
                <input placeholder="Message..." className="w-full" type="text" value={input}
                       onChange={(e) => setInput(e.target.value)}/>
            </div>
            <button type="submit" className="bg-primary-500 text-white px-4 py-2">Send</button>
        </form>
    </div>
}

export default ChatBot
