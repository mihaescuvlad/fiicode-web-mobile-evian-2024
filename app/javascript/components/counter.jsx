import React, {useState} from 'react'

const Counter = () => {
    const [count, setCount] = useState(0);

    return <div className="w-full bg-white text-3xl shadow rounded-lg p-4 flex justify-between">
        <button onClick={() => setCount(count - 1)}>-</button>
        <p>{count}</p>
        <button onClick={() => setCount(count + 1)}>+</button>
    </div>
}

export default Counter