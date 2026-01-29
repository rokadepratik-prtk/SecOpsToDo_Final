const express = require("express");
const cors = require("cors");
const path = require("path");

const app = express();
const PORT = 5000;

app.use(cors());
app.use(express.json());

let todos = [];

/* API */

// Get all todos
app.get("/api/todos", (req, res) => res.json(todos));

// Add new todo
app.post("/api/todos", (req, res) => {
  const todo = { id: Date.now(), text: req.body.text };
  todos.push(todo);
  res.json(todo);
});

// Delete todo
app.delete("/api/todos/:id", (req, res) => {
  todos = todos.filter(t => t.id != req.params.id);
  res.json({ success: true });
});

/* Serve React build */

app.use(express.static(path.join(__dirname, "../frontend/build")));

app.get("*", (_, res) =>
  res.sendFile(path.join(__dirname, "../frontend/build/index.html"))
);

/* Start Server */

app.listen(PORT, () =>
  console.log(`Backend running on http://192.168.56.115:${PORT}`)
);
