import React, { useEffect, useState } from 'react';
import { getTasks, updateTaskStatus, deleteTask } from '../api/api';

// Page 2: shows created tasks. No editing — only "mark completed" and
// "delete" for now, as requested.
export default function TaskList() {
  const [tasks, setTasks] = useState([]);
  const [error, setError] = useState('');

  const loadTasks = async () => {
    try {
      const data = await getTasks();
      setTasks(data);
    } catch (err) {
      setError(err.message);
    }
  };

  useEffect(() => {
    loadTasks();
  }, []);

  const handleComplete = async (id) => {
    try {
      await updateTaskStatus(id, 'completed');
      loadTasks();
    } catch (err) {
      setError(err.message);
    }
  };

  const handleDelete = async (id) => {
    try {
      await deleteTask(id);
      loadTasks();
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="container">
      <h2>Your Tasks</h2>
      {error && <div className="error">{error}</div>}

      {tasks.length === 0 && <p>No tasks yet — add one from the Add Task page.</p>}

      {tasks.map((task) => (
        <div className="task-card" key={task.id}>
          <div>
            <div className="title">#{task.id} {task.title}</div>
            {task.description && <div className="desc">{task.description}</div>}
            <div className={`status-badge status-${task.status}`}>{task.status}</div>
          </div>
          <div>
            {task.status !== 'completed' && (
              <button onClick={() => handleComplete(task.id)}>Complete</button>
            )}
            <button className="danger" onClick={() => handleDelete(task.id)} style={{ marginLeft: 8 }}>
              Delete
            </button>
          </div>
        </div>
      ))}
    </div>
  );
}
