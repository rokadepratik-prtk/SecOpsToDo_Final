import { useEffect, useState } from "react";

const API = "http://192.168.56.115:5000/api/todos";

export default function App() {
  const [todos, setTodos] = useState([]);
  const [text, setText] = useState("");

  useEffect(() => {
    fetch(API).then(r => r.json()).then(setTodos);
  }, []);

  const addTodo = async () => {
    if (!text.trim()) return;
    const res = await fetch(API, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text })
    });
    const todo = await res.json();
    setTodos([...todos, todo]);
    setText("");
  };

  const removeTodo = async (id) => {
    await fetch(`${API}/${id}`, { method: "DELETE" });
    setTodos(todos.filter(t => t.id !== id));
  };

  return (
    <div className="bg">
      <div className="glass">
        <h1>Glass Todo</h1>

        <div className="input-row">
          <input
            placeholder="What’s your focus today?"
            value={text}
            onChange={e => setText(e.target.value)}
          />
          <button onClick={addTodo}>Add</button>
        </div>

        <ul>
          {todos.map(todo => (
            <li key={todo.id}>
              <span>{todo.text}</span>
              <button onClick={() => removeTodo(todo.id)}>✕</button>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
